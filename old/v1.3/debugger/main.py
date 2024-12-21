#!/usr/bin/env python3
import sys
import os
import subprocess
from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from PyQt5.Qsci import QsciScintilla
from mega import Mega
from config import Config

FLAG_NAMES = ['BUSREQ', 'WAIT', 'BUSACK', 'WR', 'RD', 'IORQ', 'MREQ', 'CLEAR']
BUSREQ = 0x01
WAIT = 0x02
BUSACK = 0x04
WR = 0x08
RD = 0x10
IORQ = 0x20
MREQ = 0x40
CLEAR = 0x80


def flag_text(flags):
    res = ''
    for i in range(8):
        prefix = ' ' if (flags & (1 << i)) != 0 else '!'
        res += f' {prefix}{FLAG_NAMES[i]}'
    return res


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()  # flags=0
        self.code = QsciScintilla()
        # self.code.setTabStopWidth(4)
        self.code.setTabWidth(4)
        self.code.setMarginWidth(1, 100)
        self.code.setMarginLineNumbers(1, True)
        self.code.setAutoIndent(True)
        self.font = QFont('Courier New', 18)
        self.code.setFont(self.font)
        self.code.setMinimumSize(1024, 768)
        self.locations = {}
        self.debug_mode = False
        self.setCentralWidget(self.code)
        self.pane_output = QDockWidget('Output', self)
        self.output = QTextEdit(self.pane_output)
        self.pane_memory = QDockWidget('Memory', self)
        self.memory_list = QListWidget(self.pane_memory)
        self.memory = [0] * 65536
        self.setup_menu()
        self.setup_panes()
        self.cfg = Config()
        self.directory = self.cfg.get('directory')
        self.filename = self.cfg.get('filename')
        if self.filename:
            self.open_file(self.filename)
        self.mega = Mega()
        self.update_memory_list()
        self.load_settings()

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

    def setup_panes(self):
        self.pane_output.setObjectName('Output')
        self.pane_output.setAllowedAreas(Qt.BottomDockWidgetArea)
        self.output.setTextInteractionFlags(Qt.TextSelectableByMouse)
        self.output.setFont(self.font)
        self.pane_output.setWidget(self.output)
        self.addDockWidget(Qt.BottomDockWidgetArea, self.pane_output)

        self.pane_memory.setObjectName('Memory')
        self.pane_memory.setAllowedAreas(Qt.LeftDockWidgetArea | Qt.RightDockWidgetArea)
        self.pane_memory.setWidget(self.memory_list)
        self.memory_list.setFont(self.font)
        self.addDockWidget(Qt.RightDockWidgetArea, self.pane_memory)

    def setup_menu(self):
        mb = self.menuBar()
        m = mb.addMenu('&File')

        dir_open = QAction('Open &Dir', m)
        dir_open.triggered.connect(self.on_dir_open)
        m.addAction(dir_open)

        file_open = QAction('&Open', m)
        file_open.triggered.connect(self.on_file_open)
        file_open.setShortcut('Ctrl+O')
        m.addAction(file_open)

        file_save = QAction('&Save', m)
        file_save.triggered.connect(self.on_file_save)
        file_save.setShortcut('Ctrl+S')
        m.addAction(file_save)

        m = mb.addMenu('&Build')
        assemble = QAction('&Assemble', m)
        assemble.triggered.connect(self.on_assemble)
        assemble.setShortcut('F7')
        m.addAction(assemble)

        program = QAction('&Program', m)
        program.triggered.connect(self.on_program)
        program.setShortcut('F9')
        m.addAction(program)

        m = mb.addMenu('&Debug')

        start = QAction('&Mode', m)
        start.triggered.connect(self.on_toggle_debug)
        start.setShortcut('F5')
        m.addAction(start)

        clock = QAction('&Clock', m)
        clock.triggered.connect(self.on_clock)
        clock.setShortcut('F11')
        m.addAction(clock)

        clock = QAction('&AutoClock', m)
        clock.triggered.connect(self.on_auto_clock)
        m.addAction(clock)

        ram = QAction('&RAM Update', m)
        ram.triggered.connect(self.on_update_memory)
        ram.setShortcut('F6')
        m.addAction(ram)

    def on_dir_open(self):
        res = QFileDialog.getExistingDirectory(caption='Select Directory', directory=self.directory)
        print(res)

    def open_file(self, filename):
        try:
            self.code.setText(open(filename).read())
            self.cfg.set('filename', filename)
        except IOError:
            QMessageBox.warning(self, title='Error', text=f'Cannot open {filename}')

    def on_file_open(self):
        res = QFileDialog.getOpenFileName(caption='Open', filter='*.asm')
        filename = res[0]
        if filename:
            self.open_file(filename)

    def on_file_save(self):
        if self.filename:
            code = self.code.text()
            with open(self.filename, 'w') as f:
                f.write(code)

    def set_output(self, text, default=''):
        if not text:
            text = default
        self.output.setText(text)

    def on_assemble(self):
        work_dir = os.path.dirname(self.filename)
        filename = os.path.basename(self.filename)
        try:
            res = subprocess.run(['zasm', filename, '0', '0'], capture_output=True, cwd=work_dir, check=True, shell=True)
            self.set_output(res.stdout.decode('utf-8'), 'Done')
        except subprocess.CalledProcessError:
            self.set_output('Assembler failed')

    def on_program(self):
        bin_name = self.filename.replace('.asm', '.bin')
        try:
            data = open(bin_name, 'rb').read()
            self.mega.write_memory(0, data)
        except IOError:
            QMessageBox.warning(parent=self, title='Error', text='Failed to open binary')

    def on_toggle_debug(self):
        if self.debug_mode:
            self.on_stop_debug()
        else:
            self.on_start_debug()

    def on_stop_debug(self):
        self.debug_mode = False
        try:
            self.code.setText(open(self.filename).read())
            self.code.setReadOnly(False)
        except IOError:
            QMessageBox.warning(parent=self, title="Error", text=f'File "{self.filename}" not found')

    def on_start_debug(self):
        self.debug_mode = True
        lst_name = self.filename.replace('.asm', '.lst')
        try:
            listing = open(lst_name).read()
            self.code.setText(listing)
            self.code.setReadOnly(True)
            i = 0
            for line in listing.split('\n'):
                parts = line.split()
                if parts:
                    address = int(parts[0], 0)
                    self.locations[address] = i
                i += 1
        except IOError:
            QMessageBox.warning(parent=self, title='Error', text='No listing found.  Try assemble')

    def on_clock(self):
        count = 0
        print("------------------------------------------------------")
        while True:
            address, data, flags = self.mega.clock_read_bus()
            print(f'{address:04x}:{data:02x}  {flags:02x} {flag_text(flags)}')
            if (flags & (MREQ | RD)) == 0:
                count += 1
                if count >= 2:
                    if address in self.locations:
                        y = self.locations.get(address)
                        self.code.setSelection(y, 0, y + 1, 0)
                    break

    def on_auto_clock(self):
        self.mega.auto_clock()

    def update_memory_list(self):
        self.memory_list.clear()
        for address in range(0, 8192, 16):
            line = f'{address:04x}'
            for i in range(16):
                line = line + f' {self.memory[address + i]:02x}'
            self.memory_list.addItem(QListWidgetItem(line))

    def update_memory(self, address: int, length: int):
        if address < 0 or (address + length) > len(self.memory):
            QMessageBox.warning(parent=self, title='Error', text='Invalid memory range')
            return
        data = self.mega.read_memory(address, length)
        self.memory[address:(address + length)] = data
        self.update_memory_list()

    def on_update_memory(self):
        self.update_memory(0, 10000)


def main():
    app = QApplication(sys.argv)
    QApplication.setOrganizationName("MLGSoft")
    QApplication.setOrganizationDomain("mlgsoft.com")
    QApplication.setApplicationName("z80 Debugger")
    w = MainWindow()
    w.show()
    app.exec_()


if __name__ == "__main__":
    main()
