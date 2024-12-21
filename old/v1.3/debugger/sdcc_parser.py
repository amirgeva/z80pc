#!/usr/bin/env python3
import sys
import os
import re
from dataclasses import dataclass
from typing import Dict

address_pattern = re.compile(r'[0-9A-F]{8}')
identifier_pattern = re.compile(r'[A-Za-z_]\w+')

# Example:   0012 21 20 11
code_pattern = re.compile(r'([0-9A-F]{4}) (([0-9A-F]{2}[ r])+)')

# Example:   _main::
section_pattern = re.compile(r'([A-Za-z_]\w+)::')

# Example:   ;filename.c:213:
code_line_pattern = re.compile(r';\w+.c:(\d+):')


@dataclass
class Symbol:
    base_address: int
    name: str
    module: str


def read_map_file(filename: str):
    symbols = {}
    modules = {}
    code_segment = False
    for line in open(filename).readlines():
        if len(line.strip())==0:
            continue
        if line.startswith('_CODE'):
            code_segment=True
        if line.startswith(' ') and code_segment:
            parts = line.strip().split()
            if len(parts) == 3 and re.match(address_pattern, parts[0]):
                address = int(parts[0], 16)
                symbol_name = parts[1]
                module_name = parts[2]
                if module_name in modules:
                    address = modules.get(module_name)
                else:
                    modules[module_name] = address
                s = Symbol(base_address=address, name=symbol_name, module=module_name)
                print(f'Adding symbol {symbol_name} to {module_name} base address {address}')
                symbols[s.name] = s
    return symbols


def scan_list_file(filename: str, symbols: Dict[str, Symbol]):
    mapping = {}
    base_address = -1
    module = ''
    source_line = -1
    for line in open(filename).readlines():
        m = re.search(section_pattern, line)
        if m:
            section_name = m.groups()[0]
            if section_name in symbols:
                symbol = symbols.get(section_name)
                base_address = symbol.base_address
                module = symbol.module
        m = re.search(code_line_pattern, line)
        if m:
            source_line = int(m.groups()[0])
        m = re.search(code_pattern, line)
        if m:
            address_text = m.groups()[0]
            code_text = m.groups()[1]
            offset = int(address_text, 16)
            if code_text.startswith('00'):
                print('Ignoring data line')
            else:
                print(f'Mapping address {offset+base_address} to {module}:{source_line}')
                mapping[offset + base_address] = module, source_line
    return mapping


def parse_program(directory: str):
    intermediate = os.path.join(directory, 'intermediate')
    files = os.listdir(directory)
    intermediate_files = os.listdir(os.path.join(intermediate))
    map_files = [f for f in files if f.endswith('.map')]
    list_files = [f for f in intermediate_files if f.endswith('.lst')]
    mapping = {}
    if len(map_files) != 1:
        print("Expecting a single map file")
    else:
        symbols = read_map_file(os.path.join(directory, map_files[0]))
        # print(symbols)
        for list_file in list_files:
            mapping = scan_list_file(os.path.join(intermediate, list_file), symbols)
            # print(mapping)
    return mapping


if __name__ == '__main__':
    if len(sys.argv) > 1:
        print(parse_program(sys.argv[1]))
