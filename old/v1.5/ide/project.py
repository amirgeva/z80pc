import os
import re
from dataclasses import dataclass
from typing import Dict, Optional

from PyQt5.QtWidgets import QMessageBox


@dataclass
class Symbol:
    module: str
    symbol: str
    address: int


@dataclass
class CodeLine:
    module: str
    lst_file: str
    line: int
    src_file: str
    src_line: int


class Project:
    def __init__(self, root_folder):
        self.root_folder = root_folder
        self.areas: Dict[str, int] = {}
        self.symbols: Dict[str, Symbol] = {}
        self.addresses: Dict[int, CodeLine] = {}
        self.load_addresses()

    def get_code_line(self, address: int) -> Optional[CodeLine]:
        if address in self.addresses:
            return self.addresses.get(address)
        return None

    def load_addresses(self):
        map_files = [os.path.join(self.root_folder, f) for f in os.listdir(self.root_folder) if f.endswith('.map')]
        bin_files = [os.path.join(self.root_folder, f) for f in os.listdir(self.root_folder) if f.endswith('.bin')]
        if len(map_files) != 1 or len(bin_files) != 1:
            QMessageBox.critical(None, 'Error', 'Project folder must have 1 map and 1 bin')
            return
        in_table = False
        map_lines = open(map_files[0]).readlines()
        i = 0
        while i < len(map_lines):
            line = map_lines[i]
            if line.startswith('Area'):
                parts = map_lines[i + 2].split()
                i = i + 3
                area_name = parts[0]
                try:
                    address = int(parts[1], 16)
                    self.areas[area_name] = address
                except ValueError:
                    pass
            else:
                i = i + 1
        sub = os.path.join(self.root_folder, 'intermediate')
        lst_files = [os.path.join(sub, f) for f in os.listdir(sub) if f.endswith('.lst')]
        code_line_pattern = r'\W*([0-9A-F]{6})\W+((?:[0-9A-F]{2}\W)+)\W+\[\W?\d+\]'
        src_line_pattern = r'\W*\d+\W+;(\w+\.c):(\d+):'
        area_pattern = r'\W+\d+\W+.area (\w+)'
        # label_line_pattern = r'\W*([0-9A-F]{6})\W+\d+\W+(\w+)::'
        for lst_file in lst_files:
            print(f'Loading list file {lst_file}')
            offset = -1
            module = ''
            lst_line_number = 0
            src_file = ''
            src_line_number = 0
            for line in open(lst_file).readlines():
                try:
                    m = re.match(area_pattern, line)
                    if m:
                        active_area = m.groups()[0]
                        if active_area in self.areas:
                            offset = self.areas[active_area]
                        else:
                            offset = -1
                    if offset >= 0:
                        m = re.match(code_line_pattern, line)
                        if m:
                            g = m.groups()
                            address = int(g[0], 16) + max(offset, 0)
                            print(f'{address}: {lst_file}:{lst_line_number}')
                            self.addresses[address] = CodeLine(module, lst_file, lst_line_number, src_file, src_line_number)
                    m = re.match(src_line_pattern, line)
                    if m:
                        g = m.groups()
                        src_file = g[0]
                        src_line_number = int(g[1])
                except re.error:
                    pass
                lst_line_number += 1
