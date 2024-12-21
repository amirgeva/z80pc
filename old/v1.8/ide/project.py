import os
import re
from dataclasses import dataclass
from typing import Dict, Optional


# from PyQt5.QtWidgets import QMessageBox


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


def is_address(text: str) -> bool:
    if len(text) == 8:
        try:
            _ = int(text, 16)
            return True
        except ValueError:
            pass
    return False


class Project:
    def __init__(self):
        self.addresses: Dict[int, CodeLine] = {}

    def find_address_for_line(self, lst_filename: str, lst_line: int):
        for addr in self.addresses:
            cl = self.addresses[addr]
            if cl.lst_file == lst_filename and cl.line == lst_line:
                return addr
        return -1

    def get_code_line(self, address: int) -> Optional[CodeLine]:
        if address in self.addresses:
            return self.addresses.get(address)
        return None

    @staticmethod
    def load_map_file(filename: str, areas: Dict[str, int], symbols: Dict[str, Symbol]):
        map_lines = open(filename).readlines()
        i = 0
        while i < len(map_lines):
            line = map_lines[i]
            if line.startswith('Area'):
                parts = map_lines[i + 2].split()
                i = i + 3
                area_name = parts[0]
                try:
                    address = int(parts[1], 16)
                    areas[area_name] = address
                except ValueError:
                    pass
            else:
                parts = map_lines[i].split()
                if len(parts) > 1 and is_address(parts[0]) and parts[1][1] != '_':
                    module_name = ''
                    if len(parts) > 2:
                        module_name = parts[2]
                    symbols[parts[1]] = Symbol(module_name, parts[1], int(parts[0], 16))
                i = i + 1

    @staticmethod
    def get_map_filename(root_folder: str):
        map_files = [os.path.join(root_folder, f) for f in os.listdir(root_folder) if f.endswith('.map')]
        bin_files = [os.path.join(root_folder, f) for f in os.listdir(root_folder) if f.endswith('.bin')]
        if len(map_files) != 1 or len(bin_files) != 1:
            # QMessageBox.critical(None, 'Error', 'Project folder must have 1 map and 1 bin')
            print('Project folder must have 1 map and 1 bin')
            return ''
        return map_files[0]

    def load_addresses(self, root_folder: str):
        areas: Dict[str, int] = {}
        symbols: Dict[str, Symbol] = {}

        map_file = self.get_map_filename(root_folder)
        if not map_file:
            return False
        self.load_map_file(map_file, areas, symbols)

        sub = os.path.join(root_folder, 'intermediate')
        lst_files = [os.path.join(sub, f) for f in os.listdir(sub) if f.endswith('.lst')]
        code_line_pattern = r'\W*([0-9A-F]{6})\W+((?:[0-9A-F]{2}[ r])+)\W+\[\W?\d+\]'
        src_line_pattern = r'\W*\d+\W+;(\w+\.c):(\d+):'
        area_pattern = r'\W+\d+\W+.area (\w+)'
        label_line_pattern = r'\W*([0-9A-F]{6})\W+\d+\W+(\w+)::'
        for lst_file in lst_files:
            print(f'Loading list file {lst_file}')
            offset = -1
            module = ''
            lst_line_number = 0
            src_file = ''
            src_line_number = 0
            symbol_offset = 0
            for line in open(lst_file).readlines():
                try:
                    m = re.match(area_pattern, line)
                    if m:
                        active_area = m.groups()[0]
                        if active_area in areas:
                            offset = areas[active_area]
                        else:
                            offset = -1
                    if symbol_offset == 0:
                        m = re.match(label_line_pattern, line)
                        if m:
                            g = m.groups()
                            symbol = g[-1]
                            if symbol in symbols:
                                symbol = symbols[symbol]
                                symbol_offset = symbol.address
                                offset = symbol_offset
                    if offset >= 0:
                        m = re.match(code_line_pattern, line)
                        if m:
                            g = m.groups()
                            address = int(g[0], 16) + max(offset, 0)
                            print(f'0x{address:04x}: {lst_file}:{lst_line_number}')
                            self.addresses[address] = CodeLine(module, lst_file, lst_line_number, src_file,
                                                               src_line_number)
                    m = re.match(src_line_pattern, line)
                    if m:
                        g = m.groups()
                        src_file = g[0]
                        src_line_number = int(g[1])
                except re.error:
                    pass
                lst_line_number += 1
