#!/usr/bin/env python3
import sys
import os
import re
from dataclasses import dataclass
from typing import Dict

address_pattern = re.compile(r'[0-9A-F]{8}')
identifier_pattern = re.compile(r'[A-Za-z_]\w+')
code_pattern = re.compile(r'([0-9A-F]{4}) (([0-9A-F]{2}[ r])+)')
section_pattern = re.compile(r'([A-Za-z_]\w+)::')
code_line_pattern = re.compile(r';\w+.c:(\d+):')


@dataclass
class Symbol:
    address: int
    name: str
    module: str


def read_map_file(filename: str):
    symbols = {}
    for line in open(filename).readlines():
        parts = line.strip().split()
        if len(parts) == 3:
            if re.match(address_pattern, parts[0]):
                s = Symbol(address=int(parts[0], 16), name=parts[1], module=parts[2])
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
                base_address = symbol.address
                module = symbol.module
        m = re.search(code_line_pattern, line)
        if m:
            source_line = int(m.groups()[0])
        m = re.search(code_pattern, line)
        if m:
            offset = int(m.groups()[0], 16)
            mapping[offset + base_address] = module, source_line
    return mapping


def parse_program(directory: str):
    intermediate = os.path.join(directory, 'intermediate')
    files = os.listdir(directory)
    intermediate_files = os.listdir(os.path.join(intermediate))
    map_files = [f for f in files if f.endswith('.map')]
    list_files = [f for f in intermediate_files if f.endswith('.lst')]
    if len(map_files) != 1:
        print("Expecting a single map file")
    else:
        symbols = read_map_file(os.path.join(directory, map_files[0]))
        for list_file in list_files:
            mapping = scan_list_file(os.path.join(intermediate, list_file), symbols)
            print(mapping)


if __name__ == '__main__':
    if len(sys.argv) > 1:
        print(parse_program(sys.argv[1]))
