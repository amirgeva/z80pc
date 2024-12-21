import argh
import os


def hex2(n):
    s = hex(n)
    if len(s) < 4:
        s = f'0x0{s[2]}'
    return s


def array_to_cpp(f, data: bytes):
    n = len(data)
    i = 0
    while i < n:
        next_i = min(i + 16, n)
        block = data[i:next_i]
        block = [f'{hex2(k)}' for k in block]
        suffix = ''
        if next_i < n:
            suffix = ','
        f.write(f"{','.join(block)}{suffix}\n")
        i = next_i


def main():
    files = os.listdir('vdisk')
    data = bytearray()
    for filename in files:
        filedata = open(f'vdisk/{filename}', 'rb').read()
        if len(filedata) > 0xFFFF:
            filedata = filedata[0:0xFFFF]
        if len(filename) > 14:
            filename = filename[0:14]
        header = bytearray([0] * 16)
        header[0:len(filename)] = bytes(filename, 'ascii')
        n = len(filedata)
        header[14] = n & 255
        header[15] = (n & 0xFF00) >> 8
        data.extend(header)
        data.extend(filedata)
    with open('disk_table.inl', 'w') as f:
        array_to_cpp(f, data)


if __name__ == '__main__':
    argh.dispatch_command(main)
