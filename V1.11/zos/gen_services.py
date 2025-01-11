from typing import List, Set
import re


def find_services_block(lines: List[str]) -> List[int]:
    res = []
    for i in range(len(lines)):
        if lines[i].startswith(';SERVICES'):
            res.append(i)
    return res


def service_label(ll_names: Set[str], name: str) -> str:
    if name in ll_names:
        return name
    if name == '0':
        return name
    return f'_{name}_impl'


class ServiceWrapper:
    def __init__(self, prototype, index):
        self.prototype = prototype
        name_pattern = r'\w+ (\w+)'
        m = re.match(name_pattern, prototype)
        if not m:
            raise RuntimeError(f"Invalid prototype: {prototype}")
        g = m.groups()
        self.name = g[0]
        self.index = index

    def gen_impl(self) -> str:
        # return f'_{self.name}::\n\tLD A,#{self.index}\n\t.db 0xCF\n\tret\n\n'
        return f"_{self.name}::\n\tEX AF,AF'\n\tLD A,#{self.index}\n\tJP   8\n"

    def gen_header(self):
        return f'{self.prototype};\n'

    def gen_slc_header(self):
        return f'#define SERVICE_{self.name.upper()} {self.index}'


def load_llfuncs():
    ll_names = set()
    pattern = r'(\w+)::'
    for line in open('llfuncs.zasm').readlines():
        m = re.match(pattern, line)
        if m:
            name = m.groups()[0]
            if not name.startswith('_'):
                ll_names.add(name)
    return ll_names


def main():
    try:
        ll_names = load_llfuncs()
        services = [s.strip() for s in open('services.txt').readlines() if s.strip()]
        wrappers = [ServiceWrapper(s, i) for (s, i) in zip(services, range(len(services)))]
        services = [sw.name for sw in wrappers]
        source_services = list(services)
        print(f'Total {len(services)} services')

        declarations = [f'\t.globl\t\t{service_label(ll_names, s)}' for s in source_services]
        services = [f'\t.dw\t\t{service_label(ll_names, s)}' for s in services]
        new_lines = ['', '.area _SERVICES', '', '_services::']

        new_lines.extend(declarations)
        new_lines.extend(services)
        new_lines.append('')

        with open('services.zasm', 'w') as f:
            f.write('\n'.join(new_lines))
        with open('../include/stdlib.h', 'w') as f:
            f.write(f'#pragma once\n\n#include "stdlib_types.h"\n\n')
            for sw in wrappers:
                f.write(sw.gen_header())
        with open('../stdlib/stdlib.zasm', 'w') as f:
            f.write('\t.area _CODE\n\n')
            for sw in wrappers:
                f.write(sw.gen_impl())
        with open('../../../sl/slc/services.h', 'w') as f:
            f.write('#pragma once\n\n')
            f.write('\n'.join([sw.gen_slc_header() for sw in wrappers]))
    except Exception as e:
        print(e)


if __name__ == '__main__':
    main()
