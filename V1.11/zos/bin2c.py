import argh
import sys


def format_byte(b: int):
    return f'0x{b:02x}'


def dump(data, stream, name):
    stream.write(f'const uint8_t {name}[] = {{\n')
    n = len(data)
    for i in range(0,n,16):
        j = min(i+16,n)
        sub=data[i:j]
        sub=[format_byte(b) for b in sub]
        stream.write(f'\t{", ".join(sub)}')
        if j<n:
            stream.write(',')
        stream.write('\n')
    stream.write('};\n')


def main(binary_file: str, code_file: str = "", array_name: str="data"):
    try:
        data = open(binary_file, "rb").read()
        data = list(data)
        if code_file:
            with open(code_file,'w') as f:
                f.write('#pragma once\n\n')
                dump(data, f, array_name)
        else:
            dump(data, sys.stdout, array_name)
    except FileNotFoundError:
        print("File not found")
        
        
if __name__=='__main__':
    argh.dispatch_command(main)