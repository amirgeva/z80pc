#!/usr/bin/env python3
import os
import re
import sys
import subprocess as sp

define_pattern = re.compile(r'\.define (\w+) (.+)')
identifier_pattern = re.compile(r'\w+')


class DictReplace:
    def __init__(self, dictionary):
        self._dictionary = dictionary

    def __call__(self, match):
        s = match.group()
        if s in self._dictionary:
            return self._dictionary.get(s)
        return s


def preprocess_file(source_file: str, preprocessed_file: str):
    lines = open(source_file).readlines()
    defines = {}
    for i in range(len(lines)):
        line = lines[i]
        m = re.match(define_pattern, line.strip())
        if m:
            g = m.groups()
            macro = g[0]
            replacement = g[1]
            defines[macro] = replacement
            lines[i] = '\n'
        else:
            if len(defines) > 0:
                new_line, n = re.subn(identifier_pattern, DictReplace(defines), line)
                if n > 0:
                    lines[i] = new_line
    with open(preprocessed_file, 'w') as f:
        f.write(''.join(lines))


def process_errors(error_text: str):
    pattern = r'temp.zasm:(\d+):'
    code = open('temp.zasm').readlines()
    errors = error_text.split('\n')
    for line in errors:
        sys.stderr.write(f'{line.strip()}\n')
        m = re.match(pattern, line)
        if m:
            line_number = int(m.groups()[0])
            sys.stderr.write(f'{code[line_number - 1].strip()}\n')


def main():
    if len(sys.argv) != 2:
        sys.stderr.write("Usage: z80asm.py <source file>\n")
    else:
        source_file = sys.argv[1]
        preprocess_file(source_file, 'temp.zasm')
        rel_file = source_file.replace('.zasm', '.rel')
        res = sp.run(['sdasz80', '-l', '-o', rel_file, 'temp.zasm'], capture_output=True)
        if res.returncode != 0:
            process_errors(res.stderr.decode('ascii'))
        os.remove('temp.zasm')


if __name__ == '__main__':
    main()
