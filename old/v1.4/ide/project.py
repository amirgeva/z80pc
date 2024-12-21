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
        global_pattern = r'\W*([0-9A-F]+)\W+(\w+)\W+(\w+)?'
        for line in open(map_files[0]).readlines():
            if 'Global Defined In Module' in line:
                in_table = True
            if len(line.strip()) == 0:
                in_table = False
            if in_table:
                m = re.match(global_pattern, line)
                if m:
                    g = m.groups()
                    address = int(g[0], 16)
                    symbol = g[1]
                    module = ''
                    if len(g) > 2 and g[2] is not None:
                        module = g[2]
                    self.symbols[symbol] = Symbol(module, symbol, address)
        sub = os.path.join(self.root_folder, 'intermediate')
        lst_files = [os.path.join(sub, f) for f in os.listdir(sub) if f.endswith('.lst')]
        code_line_pattern = r'\W*([0-9A-F]{6})\W+((?:[0-9A-F]{2}\W)+)\W+\[\W?\d+\]'
        src_line_pattern = r'\W*\d+\W+;(\w+\.c):(\d+):'
        label_line_pattern = r'\W*([0-9A-F]{6})\W+\d+\W+(\w+)::'
        for lst_file in lst_files:
            offset = -1
            module = ''
            lst_line_number = 0
            src_file = ''
            src_line_number = 0
            for line in open(lst_file).readlines():
                m = re.match(code_line_pattern, line)
                if m:
                    g = m.groups()
                    address = int(g[0], 16) + max(offset, 0)
                    self.addresses[address] = CodeLine(module, lst_file, lst_line_number, src_file, src_line_number)
                m = re.match(src_line_pattern, line)
                if m:
                    g = m.groups()
                    src_file = g[0]
                    src_line_number = int(g[1])
                if offset < 0:
                    m = re.match(label_line_pattern, line)
                    if m:
                        g = m.groups()
                        address = int(g[0], 16)
                        symbol = g[1]
                        if symbol in self.symbols:
                            offset = self.symbols.get(symbol).address - address
                lst_line_number += 1
