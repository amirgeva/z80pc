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
        self.fill_workspace()
        self.load_settings()

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

    def fill_workspace(self):
        if self.directory:
            files = os.listdir(self.directory)
            w = self.workspace.get_widget()
            w.clear()
            w.addItems(files)

    def on_dir_open(self):
        res = QFileDialog.getExistingDirectory(caption='Select Directory', directory=self.directory)
        if res:
            self.directory = res
            self.cfg.set('directory',self.directory)
            self.fill_workspace()

    def on_file_save(self):
        self.code.on_save()

    def on_make(self):
        if run('make', self.directory, self.output.get_widget()):
            self.locations = parse_program(self.directory)

    def on_program(self):
        pass

    def on_output_selected(self):
        text = self.output.get_widget().toPlainText().split('\n')
        c = self.output.get_widget().textCursor()
        y = c.blockNumber()
        current = text[y]
        parts = current.split(':')
        try:
            line=int(parts[1])
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


def main():
    app = QApplication(sys.argv)
    QApplication.setOrganizationName("MLGSoft")
    QApplication.setOrganizationDomain("mlgsoft.com")
    QApplication.setApplicationName("z80 IDE")
    w = MainWindow()
    w.show()
    app.exec_()


if __name__ == "__main__":
    main()
