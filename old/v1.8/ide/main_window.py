import importlib
import os
import time
import subprocess as sp
from typing import Tuple

from PyQt5 import QtWidgets, QtGui
from PyQt5.QtCore import QSettings
from PyQt5.QtWidgets import QFileDialog, QMessageBox, QInputDialog

import utils
from code_widget import CodeWidget
from dock_output import OutputDock
from pane_widget import PaneWidget
from project import Project, CodeLine
from utils import create_menu_bar
from protocol import create_protocol


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
            self.project = Project()
            self.project.load_addresses(self.root_folder)
        self.setMinimumSize(1600, 1000)
        self.setup_menu()
        self.docks = {}
        self.code = CodeWidget()
        self.code.setReadOnly(True)
        self.setCentralWidget(self.code)
        self.protocol = create_protocol()
        self.open_file = ''
        self.open_all_docks()
        self.docks['Workspace'].set_root_folder(self.root_folder)
        self.docks['Workspace'].add_callback(self.on_open_file)
        self.docks['Output'].add_callback(self.on_output_code_line)
        self.docks['Input'].add_callback(self.on_input_key)
        self.load_docks()
        self._uploaded_data: Tuple[int, bytes] = 0, bytes()

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
        self.project = Project()
        self.project.load_addresses(self.root_folder)
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

    def on_input_key(self, text: str):
        self.protocol.send_input(text)

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

    def _upload_data(self, data: bytes, address: int):
        i = 0
        while i < len(data):
            ni = min(i + 100, len(data))
            print(f"Writing {i}:{ni}")
            sub = data[i:ni]
            self.protocol.write_data(address + i, sub)
            time.sleep(0.1)
            i = ni

    def on_actions_upload_app(self):
        folder = "C:\\prg\\github\\z80pc\\v1.6\\tetris"
        filename = os.path.join(folder, "tetris.bin")
        data = open(filename, 'rb').read()
        if data:
            address = 0x1000
            self._upload_data(data, address)
            self.project.load_addresses(folder)

    def on_actions_clear_memory(self):
        data = bytes([0] * 1024)
        self._upload_data(data, 0)

    def on_actions_upload(self):
        files = [f for f in os.listdir(self.root_folder) if f.endswith('.bin')]
        if len(files) != 1:
            QMessageBox.critical(self, 'Error', 'Single .bin file expected')
            return
        path = os.path.join(self.root_folder, files[0])
        data = open(path, 'rb').read()
        print(f"Uploading {len(data)} bytes from file {path}")
        address, valid = QInputDialog.getInt(self, f'Upload {len(data)} bytes', 'Base Address', 0, 0, 32000)
        if valid:
            self._uploaded_data = address, data
            self._upload_data(data, address)

    def on_actions_verify_memory(self):
        n = len(self._uploaded_data[1])
        mismatches = []
        if n > 0:
            data = self.docks['Memory'].get_data(self._uploaded_data[0], n)
            for i in range(n):
                if data[i] != self._uploaded_data[1][i]:
                    mismatches.append(hex(i))
            if len(mismatches) == 0:
                QMessageBox.information(self, 'Success', f'Data matches {n} bytes')
            else:
                QMessageBox.critical(self, 'Error', f'{len(mismatches)} Data mismatches found')
                print(mismatches)
        else:
            QMessageBox.critical(self, 'Error', 'No uploaded data found')

    def on_actions_read_memory(self):
        if 'Memory' not in self.docks:
            self.on_dock_window('Memory')
        addr = 0
        limit = 4200
        while addr < limit:
            n = min(limit - addr, 248)
            print(f"Reading {addr}:{addr + n}")
            data = self.protocol.read_data(addr, n)
            # print(list(data))
            self.docks['Memory'].set_data(addr, data)
            # time.sleep(0.01)
            addr += n

    def on_actions_trigger_interrupt(self):
        self.protocol.trigger_interrupt()

    def on_actions_trigger_reset(self):
        print("RESET")
        self.protocol.trigger_reset()

    def on_actions_auto_clock(self):
        self.protocol.auto_clock()

    def update_registers(self, address: int, data):
        if 'Registers' in self.docks:
            self.docks.get('Registers').set_data(address, data)

    def on_actions_step_over(self):
        # while True:
        data = self.protocol.single_step()
        # if data[1] != 0:
        # break
        self.update_status(data)
        return True

    def on_actions_run_to_address(self):
        addr, ok = QInputDialog.getInt(self, 'Run to address', 'Address', 4096, 0, 65535, 1)
        if ok:
            data = self.protocol.run_to(addr)
            self.update_status(data)

    def on_actions_run_here(self):
        addr = self.project.find_address_for_line(self.open_file, self.get_current_line())
        if addr < 0:
            QMessageBox.critical(self, 'Error', 'Address not found')
            return
        data = self.protocol.run_to(addr)
        if len(data) > 0:
            self.update_status(data)

    def on_actions_single_step(self):
        data = self.protocol.single_step()
        # print(' '.join([f'{x:02x}' for x in data]))
        if False:
            flags = data[4] & 0x19
            sflags = ''
            if (flags & 0x10) == 0:
                sflags += ' M1'
            if (flags & 0x08) == 0:
                sflags += ' WR'
            if (flags & 0x04) == 0:
                sflags += ' RD'
            if (flags & 0x02) == 0:
                sflags += ' MREQ'
            if (flags & 0x01) == 0:
                sflags += ' IORQ'

            print(f'{data[0]:02x} {data[1]:02x} {data[2]:02x} {data[3]:02x} {sflags}')
            # print(list(data))
        else:
            if not self.update_status(data):
                for i in range(8):
                    if self.on_actions_refresh():
                        return True
            return False

    def get_current_line(self):
        return self.code.get_current_line()

    def update_status(self, data):
        if len(data) >= 16:
            # print(data)
            address = (data[1] << 8) | data[0]
            self.update_registers(address, data[2:])
            # self.docks['Registers'].
            cl: CodeLine = self.project.get_code_line(address)
            if cl:
                if cl.lst_file != self.open_file:
                    self.load_file(cl.lst_file, True)
                self.code.select_line(cl.line + 1)
            # print(f'0x{address:04X}')
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
                "Verify Memory\\tF3",
                "Run Here\\tF4",
                "Run To Address",
                "Clear Memory",
                "Trigger Interrupt\\tF12",
                "Trigger Reset\\tF8",
                "Single Step\\tF11",
                "Step Over\\tF10",
                "Auto Clock\\tF2",
                "Upload App\\tF1",
                "Enhanced Mode"]
            ]
        ]
        ''')
