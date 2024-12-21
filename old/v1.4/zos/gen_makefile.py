import os


# -b _CODE=0x100 -b _BOOT=1 -b _ISRS=0x38 -b _INITIALIZER=0x04 -b _DFLT=0x1200

def main():
    try:
        areas = open('areas.cfg').readlines()
    except FileNotFoundError:
        print("Cannot find areas.cfg.  Aborting")
        return
    areas=['_'+a.strip() for a in areas]
    code_section_flags = '-b '+' -b '.join(areas)
    with open('makefile', 'w') as o:
        files = os.listdir('.')
        c_files = [f for f in files if f.endswith('.c')]
        asm_files = [f for f in files if f.endswith('.zasm')]
        rel_files = [f[0:-2]+".rel" for f in c_files]
        rel_files.extend([f[0:-5] + ".rel" for f in asm_files])
        rel_files=' '.join(rel_files)
        name = os.path.basename(os.getcwd())
        o.write(f'''{name}.bin: {name}.ihx
\trm -f {name}.bin
\trm -f intermediate/*
\techo intermediate > intermediate/README.md
\tpython ihx2bin.py {name}.ihx {name}.bin
\tpython bin2list.py {name}.bin ../z80io/os.inl
\tmv *.asm intermediate
\tmv *.lst intermediate
\tmv *.ihx intermediate
\tmv *.rel intermediate
\tmv *.sym intermediate

{name}.ihx: {rel_files}
\tsdldz80 -m -w -i {code_section_flags} {name} {rel_files}

''')
        for name in asm_files:
            base, _ = os.path.splitext(name)
            o.write(f'{base}.rel: {base}.zasm\n\tsdasz80 -l -o {base}.rel {base}.zasm\n\n')
        for name in c_files:
            base, _ = os.path.splitext(name)
            o.write(f'{base}.rel: {name}\n\tsdcc -c -mz80 {name}\n\n')
        o.write('''clean:
\trm -f *.asm
\trm -f *.map
\trm -f *.rel
\trm -f *.lst
\trm -f *.sym
\trm -f *.cdb
\trm -f *.rst
\trm -f *.ihx
\trm -f intermediate/*
''')






if __name__ == '__main__':
    main()
