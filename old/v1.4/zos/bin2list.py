import argh


def transform(bin_filename, list_filename):
    data = open(bin_filename, 'rb').read()
    data = list(data)
    data = [f'0x{b:02X}' for b in data]
    lines = []
    i = 0
    while i < len(data):
        ni = min(i + 16, len(data))
        n = ni - i
        lines.append(data[i:ni])
        if ni < len(data):
            lines[-1][-1] += ','
        i = ni
    with open(list_filename, 'w') as f:
        for line in lines:
            f.write(f'{",".join(line)}\n')


if __name__ == '__main__':
    argh.dispatch_command(transform)
