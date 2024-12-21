#!/usr/bin/env python3
import sys
import os
import subprocess
from code_widget import CodeWidget
from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from PyQt5.Qsci import QsciScintilla
from mega import Mega
from structs import *
from config import *
from pane_widget import *
from utils import *
from sdcc_parser import parse_program
from mega import Mega

FLAG_NAMES = ['BUSREQ', 'WAIT', 'BUSACK', 'WR', 'RD', 'IORQ', 'MREQ', 'CLEAR']
BUSREQ = 0x01
WAIT = 0x02
BUSACK = 0x04
WR = 0x08
RD = 0x10
IORQ = 0x20
MREQ = 0x40
CLEAR = 0x80


class MainWindow(QMainWindow):
    def __init__(self):
        # noinspection PyArgumentList
        super().__init__()
        self.cfg = Config()
        self.setup_menu()
        self.directory = self.cfg.get('directory')
        self.locations = {}
        self.code = CodeWidget()
        self.setCentralWidget(self.code)
        self.output = self.add_dock(PaneWidget('Output', QTextEdit, Qt.BottomDockWidgetArea))
        self.output.get_widget().setTextInteractionFlags(Qt.TextSelectableByMouse)
        self.output.get_widget().selectionChanged.connect(self.on_output_selected)
        self.workspace = self.add_dock(PaneWidget('Workspace', QListWidget, Qt.LeftDockWidgetArea))
        self.workspace.get_widget().itemDoubleClicked.connect(self.open_workspace_file)
        self.pane_memory = self.add_dock(PaneWidget('Memory', QListWidget, Qt.RightDockWidgetArea))
        self.pane_memory.widget.setFont(QFont('Courier New', 18))
        self.memory = [0] * 65536
        self.mega = Mega()
        self.fill_workspace()
        self.load_settings()
        self.last_stop = '', -1

    def shutdown(self):
        self.mega.shutdown()

    def add_dock(self, pane):
        self.addDockWidget(pane.get_dock_area(), pane)
        return pane

    def load_settings(self):
        geom = self.cfg.get('geometry')
        if not isinstance(geom, str):
            self.restoreGeometry(geom)
        state = self.cfg.get('state')
        if not isinstance(state, str):
            self.restoreState(state)

    def closeEvent(self, e: QCloseEvent) -> None:
        self.cfg.set('geometry', self.saveGeometry())
        self.cfg.set('state', self.saveState())

    def setup_menu(self):
        mb = self.menuBar()

        m = mb.addMenu('&File')
        dir_open = QAction('Open &Dir', m)
        dir_open.triggered.connect(self.on_dir_open)
        m.addAction(dir_open)
        file_save = QAction('&Save', m)
        file_save.triggered.connect(self.on_file_save)
        file_save.setShortcut('Ctrl+S')
        m.addAction(file_save)

        m = mb.addMenu('&Build')
        make = QAction('&Make', m)
        make.triggered.connect(self.on_make)
        make.setShortcut('F7')
        m.addAction(make)

        program = QAction('&Program', m)
        program.triggered.connect(self.on_program)
        program.setShortcut('F9')
        m.addAction(program)

        update_mem = QAction('&Update Memory', m)
        update_mem.triggered.connect(self.on_update_memory)
        update_mem.setShortcut('F6')
        m.addAction(update_mem)

        clock = QAction('&Clock', m)
        clock.triggered.connect(self.on_clock)
        clock.setShortcut('F11')
        m.addAction(clock)

    def fill_workspace(self):
        if self.directory:
            files = os.listdir(self.directory)
            w = self.workspace.get_widget()
            w.clear()
            w.addItems(files)

    def on_dir_open(self):
        res = QFileDialog.getExistingDirectory(parent=self, caption='Select Directory', directory=self.directory,
                                               options=QFileDialog.ShowDirsOnly)
        if res:
            self.directory = res
            self.cfg.set('directory', self.directory)
            self.fill_workspace()

    def on_file_save(self):
        self.code.on_save()

    def on_make(self):
        if run('make', self.directory, self.output.get_widget()):
            self.locations = parse_program(self.directory)

    def on_clock(self):
        for i in range(1000):
            address, data, flags = self.mega.clock_read_bus()
            if (flags & (RD | MREQ)) == 0:
                continue
            if address in self.locations:
                module, line = self.locations.get(address)
                if module == self.last_stop[0] and line == self.last_stop[1]:
                    continue
                self.last_stop = module, line
                print(f'{address:04x} -> {module}:{line}')
                filename = os.path.join(self.directory, module + ".c")
                if os.path.exists(filename):
                    if self.code.path != filename:
                        self.code.open_file(filename)
                    self.code.select_line(line)
                break
            else:
                print(f'Address: {address:04x}')

    def on_program(self):
        files = [f for f in os.listdir(self.directory) if f.endswith('.bin')]
        if len(files) != 1:
            QMessageBox.critical(self, "Program Error", "Only a single .bin is supported")
        else:
            filename = os.path.join(self.directory, files[0])
            data = open(filename, 'rb').read()
            self.mega.write_memory(0, data)
            self.on_update_memory()

    def on_output_selected(self):
        text = self.output.get_widget().toPlainText().split('\n')
        c = self.output.get_widget().textCursor()
        y = c.blockNumber()
        current = text[y]
        parts = current.split(':')
        try:
            line = int(parts[1])
        except ValueError:
            return
        filename = parts[0]
        path = os.path.join(self.directory, filename)
        if os.path.exists(path):
            self.code.open_file(path)
            self.code.select_line(line)

    def open_workspace_file(self, item):
        filename = item.text()
        path = os.path.join(self.directory, filename)
        if os.path.exists(path):
            self.code.open_file(path)

    def update_memory_list(self):
        self.pane_memory.widget.clear()
        for address in range(0, 8192, 16):
            line = f'{address:04x}'
            for i in range(16):
                line = line + f' {self.memory[address + i]:02x}'
            self.pane_memory.widget.addItem(QListWidgetItem(line))

    def update_memory(self, address: int, length: int):
        if address < 0 or (address + length) > len(self.memory):
            QMessageBox.warning(parent=self, title='Error', text='Invalid memory range')
            return
        data = self.mega.read_memory(address, length)
        self.memory[address:(address + length)] = data
        self.update_memory_list()

    def on_update_memory(self):
        self.update_memory(0, 1024)


def main():
    app = QApplication(sys.argv)
    QApplication.setOrganizationName("MLGSoft")
    QApplication.setOrganizationDomain("mlgsoft.com")
    QApplication.setApplicationName("z80 IDE")
    w = MainWindow()
    w.show()
    app.exec_()
    w.shutdown()


if __name__ == "__main__":
    main()
