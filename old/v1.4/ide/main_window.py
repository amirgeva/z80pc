import importlib
import os
import time
import subprocess as sp

from PyQt5 import QtWidgets, QtGui
from PyQt5.QtCore import QSettings
from PyQt5.QtWidgets import QFileDialog, QMessageBox, QInputDialog

import utils
from code_widget import CodeWidget
from dock_output import OutputDock
from pane_widget import PaneWidget
from project import Project, CodeLine
from utils import create_menu_bar
from protocol import Protocol


class MainWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__(None)
        self.settings = QSettings()
        self.root_folder = self.settings.value('root', '')
        if not self.root_folder:
            if not self.on_file_source_directory():
                QMessageBox.critical(None, 'Error', 'Must select project folder')
                raise RuntimeError("Invalid project folder")
        else:
            self.project = Project(self.root_folder)
        self.setMinimumSize(1600, 1000)
        self.setup_menu()
        self.docks = {}
        self.code = CodeWidget()
        self.code.setReadOnly(True)
        self.setCentralWidget(self.code)
        self.protocol = Protocol()
        self.open_file = ''
        self.open_all_docks()
        self.docks['Workspace'].set_root_folder(self.root_folder)
        self.docks['Workspace'].add_callback(self.on_open_file)
        self.docks['Output'].add_callback(self.on_output_code_line)
        self.load_docks()

    def open_all_docks(self):
        docks, items = utils.get_dock_names()
        for item in items:
            self.on_dock_window(item)

    def on_dock_window(self, name: str):
        if name not in self.docks:
            module_name = f'dock_{name.lower()}'
            full_name = f'{name}Dock'
            module = importlib.import_module(module_name)
            class_object = getattr(module, full_name)
            dw: PaneWidget = class_object()
            self.docks[name] = dw
            self.addDockWidget(dw.dock_area, dw)
        w = self.docks.get(name)
        w.show()

    def on_file_source_directory(self) -> bool:
        res = QFileDialog.getExistingDirectory(None, 'Project Folder', '')
        if not res:
            return False
        self.root_folder = res
        self.settings.setValue('root', self.root_folder)
        self.project = Project(self.root_folder)
        return True

    def closeEvent(self, a0: QtGui.QCloseEvent) -> None:
        self.save_docks()
        self.protocol.shutdown()
        for dock_name in self.docks:
            self.docks.get(dock_name).close()
        super().closeEvent(a0)

    def load_docks(self):
        try:
            if self.settings.contains('geometry'):
                self.restoreGeometry(self.settings.value('geometry'))
                self.restoreState(self.settings.value('windowState'))
        except TypeError:
            pass

    def save_docks(self):
        self.settings.setValue('geometry', self.saveGeometry())
        self.settings.setValue('windowState', self.saveState())

    def on_file_exit(self):
        self.close()

    def on_output_code_line(self, filename: str, line_number: int):
        path = os.path.join(self.root_folder, filename)
        if path != self.open_file:
            self.load_file(path, False)
            self.code.select_line(line_number)

    def on_build_make(self):
        if self.code.isModified():
            self.code.on_save()
        output: OutputDock = self.docks['Output']
        output.clear()
        p = sp.Popen(['make'], stdout=sp.PIPE, stderr=sp.STDOUT, cwd=self.root_folder)
        while True:
            line = p.stdout.readline()
            if not line:
                break
            output.append_line(line.decode('utf-8').strip())

    def on_actions_upload(self):
        files = [f for f in os.listdir(self.root_folder) if f.endswith('.bin')]
        if len(files) != 1:
            QMessageBox.critical(None, 'Error', 'Single .bin file expected')
            return
        path = os.path.join(self.root_folder, files[0])
        data = open(path, 'rb').read()
        address, valid = QInputDialog.getInt(self, f'Upload {len(data)} bytes', 'Base Address', 0, 0, 32000)
        if valid:
            i = 0
            while i < len(data):
                ni = min(i + 100, len(data))
                print(f"Writing {i}:{ni}")
                sub = data[i:ni]
                self.protocol.write_data(address + i, sub)
                time.sleep(0.5)
                i = ni

    def on_actions_read_memory(self):
        if 'Memory' not in self.docks:
            self.on_dock_window('Memory')
        data = self.protocol.read_data(0, 250)
        self.docks['Memory'].set_data(0, data)
        time.sleep(0.1)
        data = self.protocol.read_data(250, 250)
        self.docks['Memory'].set_data(250, data)

    def on_actions_trigger_interrupt(self):
        self.protocol.trigger_interrupt()

    def update_registers(self, data):
        if 'Registers' in self.docks:
            self.docks.get('Registers').set_data(data)

    def on_actions_single_step(self):
        data = self.protocol.single_step()
        if not self.update_status(data):
            for i in range(8):
                if self.on_actions_refresh():
                    return True
        return False

    def update_status(self, data):
        if len(data) >= 16:
            # print(data)
            address = (data[1] << 8) | data[0]
            self.update_registers(data[2:])
            # self.docks['Registers'].
            cl: CodeLine = self.project.get_code_line(address)
            if cl:
                if cl.lst_file != self.open_file:
                    self.load_file(cl.lst_file, True)
                self.code.select_line(cl.line + 1)
            print(f'0x{address:04X}')
            return True
        return False

    def on_actions_enhanced_mode(self):
        self.protocol.send_payload([4, 1])

    def on_actions_refresh(self):
        data = self.protocol.refresh()
        return self.update_status(data)

    def on_open_file(self, filename):
        self.load_file(os.path.join(self.root_folder, filename), False)

    def load_file(self, path: str, read_only: bool):
        self.code.open_file(path)
        self.code.setReadOnly(read_only)
        self.open_file = path

    def setup_menu(self):
        create_menu_bar(self, self.menuBar(), f'''
        [
            ["File", [
                "Source Directory",
                "Exit\\tCtrl+Q" ]
            ],
            ["Build", [
                "Make\\tF7" ]
            ],
            ["Actions", [
                "Upload\\tF9",
                "Refresh\\tF5",
                "Read Memory\\tF6",
                "Trigger Interrupt\\tF12",
                "Single Step\\tF11",
                "Enhanced Mode"]
            ]
        ]
        ''')
