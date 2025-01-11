import re
from typing import List, Set, Dict

import argh
import os

folders = []


def get_file_words(filepath: str) -> Set[str]:
    return set(re.findall(r'\w+', open(filepath).read()))


def get_files_words(filepaths: List[str]) -> Set[str]:
    res = set()
    for filepath in filepaths:
        res = res.union(get_file_words(filepath))
    return res


def build_areas_flags(areas: Dict[str, str]) -> str:
    res = ''
    sorted_areas = sorted(areas.keys(), key=lambda name: areas.get(name))
    for area in sorted_areas:
        res += f' -b {area}={areas.get(area)}'
    return res


def load_cfg_sections(cfg_filename: str) -> Dict[str, List[str]]:
    res = {}
    try:
        section_pattern = re.compile(r'\[(\w+)]')
        cur_section = ''
        lines = [line.strip() for line in open(cfg_filename).readlines()]
        for line in lines:
            if line.startswith('#'):
                continue
            m = re.match(section_pattern, line.strip())
            if m:
                cur_section = m.groups()[0]
                res[cur_section] = []
            elif cur_section:
                res[cur_section].append(line)
    except FileNotFoundError:
        pass
    return res


def load_areas(source_folder: str):
    cfg = load_cfg_sections(os.path.join(source_folder, 'areas.cfg'))
    areas = {}
    if 'areas' in cfg:
        for line in cfg.get('areas'):
            parts = line.strip().split()
            if len(parts) == 2:
                areas[parts[0]] = parts[1]
    if len(areas) == 0:
        areas["_CODE"] = "0x1000"
    return areas


def load_folders_cfg():
    cfg = load_cfg_sections("genmake.cfg")
    if 'folders' in cfg:
        global folders
        folders = cfg.get('folders')


def is_executable(source_folder: str, c_files: List[str]) -> bool:
    main_pattern = r'(?:void|int)\s+main\s*\('
    for filename in c_files:
        filepath = os.path.join(source_folder, filename)
        lines = open(filepath).readlines()
        for line in lines:
            if re.match(main_pattern, line.strip()):
                return True
    return False


def load_dependencies(source_folder: str) -> List[str]:
    try:
        deps = open(os.path.join(source_folder, 'deps.cfg')).readlines()
        deps = [d.strip() for d in deps]
        deps = [d for d in deps if d]  # remove empty lines
        return deps
    except FileNotFoundError:
        return []


def generate_makefile(source_folder: str, build_folder: str) -> bool:
    """
    :param source_folder: Absolute path to source folder
    :param build_folder: Absolute path to build folder
    :return: True if the folder has an executable
    """
    rc = False
    target_name = os.path.basename(source_folder)
    rel_build = os.path.relpath(build_folder, source_folder).replace('\\', '/')
    files = os.listdir(source_folder)
    c_files = [f for f in files if f.endswith('.c')]
    asm_files = [f for f in files if f.endswith('.zasm')]
    areas = load_areas(source_folder)
    areas_flags = build_areas_flags(areas)
    all_names = [os.path.splitext(f)[0] for f in asm_files]
    all_names.extend([os.path.splitext(f)[0] for f in c_files])
    all_rels = [f'{rel_build}/{name}.rel' for name in all_names]
    makefile_path = os.path.join(source_folder, 'makefile')
    include_dirs = ' '.join([f'-I../{f}' for f in folders])
    with open(makefile_path, 'w') as f:
        f.write(f'CFLAGS=-I../include {include_dirs}\n\n')
        rels_str = " ".join(all_rels)
        if is_executable(source_folder, c_files):
            deps = load_dependencies(source_folder)
            deps_libs_str = ' '.join([f'-l {rel_build}/{d}.a' for d in deps])
            f.write(f'{rel_build}/{target_name}: {rel_build}/{target_name}.ihx\n')
            f.write(f'\tpython ../ihx2bin.py {rel_build}/{target_name}.ihx {rel_build}/{target_name}\n\n')
            f.write(f'{rel_build}/{target_name}.ihx: {rels_str}\n')
            for dep in deps:
                f.write(f'\tmake -C ../{dep}\n')
            f.write(f'\tsdldz80 -m -w -i {areas_flags} {target_name} {rels_str} {deps_libs_str}\n')
            f.write(f'\tmv {target_name}.ihx {rel_build}/\n\n')
            f.write(f'\tmv {target_name}.map {rel_build}/\n\n')
            rc = True
        else:
            f.write(f'{rel_build}/{target_name}.a: {rels_str}\n')
            f.write(f'\tsdar -r {rel_build}/{target_name}.a {rels_str}\n\n')
        for filename in c_files:
            name = os.path.splitext(filename)[0]
            f.write(f'{rel_build}/{name}.rel: {name}.c\n')
            f.write(f'\tsdcc -c $(CFLAGS) -o {rel_build}/{name}.rel  -mz80 {name}.c\n\n')
        for filename in asm_files:
            name = os.path.splitext(filename)[0]
            f.write(f'{rel_build}/{name}.rel: {name}.zasm\n')
            f.write(f'\tpython ../z80asm.py -r {rel_build}/{name}.rel {name}.zasm\n\n')
    return rc


def main(build_folder: str):
    load_folders_cfg()
    build_folder = os.path.abspath(build_folder)
    libraries = []
    executables = []
    for cur_folder in folders:
        source_folder = os.path.abspath(cur_folder)
        if generate_makefile(source_folder, build_folder):
            executables.append(cur_folder)
        else:
            libraries.append(cur_folder)

    with open('makefile', 'w') as f:
        f.write('all:\n')
        for folder in libraries:
            f.write(f'\tmake -C {folder}\n')
        for folder in executables:
            f.write(f'\tmake -C {folder}\n')


if __name__ == '__main__':
    argh.dispatch_command(main)
