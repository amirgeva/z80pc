import re
import os
import shlex
import argparse
from instructions import get_instructions

identifier = re.compile(r'[a-zA-Z_]\w*')
label_name_add = r'([a-zA-Z_]\w*)([\+\-]\d+)'
label_name = r'[a-zA-Z_][\+\-\w]*'
label_pat = f'{label_name}:'
hex_num = r'[0-9A-F]+[Hh]'
bin_num = r'[0-1]+[Bb]'
dec_num = r'\d+'
num = f'({hex_num}|{bin_num}|{dec_num})'
num_label = f'({hex_num}|{bin_num}|{dec_num}|{label_name})'
def_str = "DS\s+\\'(.*)\\'"

defines = {}
labels = {}
registers = {'a': 7, 'b': 0, 'c': 1, 'd': 2, 'e': 3, 'h': 4, 'l': 5}
assembler_pass = 1


class ASMSyntaxError(Exception):
    def __init__(self, text='Syntax Error'):
        super(ASMSyntaxError, self).__init__(text)


def is_label(s):
    if s in labels:
        return True
    m = re.match(label_name_add, s)
    if m:
        g = m.groups()
        base = g[0]
        return base in labels
    return False


def get_label_value(s):
    if s in labels:
        return labels.get(s)
    m = re.match(label_name_add, s)
    g = m.groups()
    base = g[0]
    diff = g[1]
    return labels.get(base) + int(diff)


def to_number(text):
    """
    Convert number strings to integers
    :param text: Number string
    :return: integer
    """
    if re.match(hex_num, text):
        return int(text[0:-1], 16)
    if re.match(bin_num, text):
        return int(text[0:-1], 2)
    return int(text)


def parse_number_label(text):
    """
    Parse a number either directly, or from a previously defined label
    :param text: Parameter text
    :return: Integer value
    """
    try:
        return to_number(text)
    except ValueError:
        if text in labels:
            return labels.get(text)
        raise ASMSyntaxError(f'Invalid address or label: {text}')


def parse_number(text):
    """
    Convert to integer, throw if fails
    :param text: Number as text (decimal, hex or binary)
    :return: Integer value
    """
    try:
        return to_number(text)
    except ValueError:
        raise ASMSyntaxError(f'Invalid number format: {text}')


def remove_comments(line):
    """
    Remove all comments from the line
    :param line: assembly source line
    :return: line without comments (; ....)
    """
    comment = line.find(';')
    if comment >= 0:
        line = line[0:comment]
    return line


def define(name, value):
    """
    Add a new definition
    :param name: Name of variable
    :param value: Numeric value
    :return: Empty code (no new machine code)
    """
    if not re.match(identifier, name):
        raise ASMSyntaxError(f'EQU requires a valid identifier: {name}')
    defines[name] = value
    return [], -1


def create_pattern(candidate):
    """
    Create search pattern for parameter placeholders

    :param candidate: Instruction template
    :return: Regular expression pattern for matching
    """
    types = []
    pat = '@@|::|%%'
    while True:
        m = re.search(pat, candidate)
        if m:
            s = m.span()
            types.append(candidate[s[0]:s[1]])
            replacement = num_label
            # if candidate[s[0]] == '@' or candidate[s[0]] == '%':
            #    replacement = num_label
            candidate = candidate[0:s[0]] + replacement + candidate[s[1]:]
        else:
            break
    return candidate + "$", types


def compose(template, values):
    """
    Create machine code for instruction

    :param template: Machine code template
    :param values: Values for placeholders
    :return: Code as a list of integers (0-255 each)
    """
    parts = template.split()
    j = 0
    for i in range(len(parts)):
        if parts[i] == '::':
            if j < len(values):
                parts[i] = values[j]
                j = j + 1
            else:
                raise ASMSyntaxError()
        else:
            parts[i] = int(parts[i], 16)
    return parts


def handle_labels(values, types, pos):
    """

    :param values: list of values to place in template placeholders
    :param types: type of values (@@ or :: or %%) for 16bit, 8bit, relative
    :param pos: Position in program code (bytes)
    :return: Updated values with numbers where text used to be
    """
    res = []
    score = 0
    for value, value_type in zip(values, types):
        if value is None:
            return [], -1
        if value in defines:
            value = defines.get(value)
        if is_label(value):
            value = get_label_value(value)
        if not isinstance(value, int):
            if re.match(label_name, value):
                if assembler_pass == 1:
                    # Ignore unknown label values in first pass
                    value = 0
                    score = 1
                else:
                    return [], -1
            else:
                value = parse_number(value)
        if value_type == '::':
            if value < 0 or value > 255:
                raise ASMSyntaxError(f'Invalid byte value {value}')
            res.append(value)
        if value_type == '@@':
            if value < 0 or value > 65535:
                raise ASMSyntaxError(f'Invalid word value {value}')
            res.append(value & 255)
            res.append((value >> 8) & 255)
        if value_type == '%%':
            value = value - pos
            if assembler_pass == 1:
                value = 0
            if -126 <= value <= 129:
                res.append(value - 2)
            else:
                raise ASMSyntaxError(f'Invalid relative address {value}')
    return res, score


def find_match(candidates, instruction, pos):
    """

    :param candidates: A list of potential matches.  Each is a (code, template) tuple
    :param instruction: Text from assembly line
    :param pos: Position in program (bytes)
    :return: code as a list of integers (0-255 each)
    """
    scored_candidates = [[], [], [], [], [], []]
    for candidate in candidates:
        pattern, types = create_pattern(re.escape(candidate[1]))
        match = re.match(pattern, instruction)
        if match:
            values, score = handle_labels(match.groups(), types, pos)
            if score >= 0:
                scored_candidates[score].append((candidate[0], values))
            # return compose(candidate[0], values)
    for score in range(6):
        if len(scored_candidates[score]) > 0:
            s = scored_candidates[score][0]
            return compose(s[0], s[1])
    raise ASMSyntaxError(f"Could not assemble: {instruction}")
    # return []


def parse_bytes(parts):
    parts = [p.split(',') for p in parts]
    numbers = []
    for p in parts:
        numbers.extend(p)
    numbers = [n.upper() for n in numbers]
    return [parse_number(p) for p in numbers]


def parse_words(parts):
    parts = [p.split(',') for p in parts]
    numbers = []
    for p in parts:
        numbers.extend(p)
    numbers = [n.upper() for n in numbers]
    res = []
    for n in numbers:
        val = parse_number(n)
        res.append(val & 255)
        res.append((val >> 8) & 255)
    return res


def parse_line(parts, pos):
    """

    :param parts: list of words in line
    :param pos: Position in program (bytes)
    :return: (code,new position)   Code is a list of integers (0-255 each)
                                   new position should be positive for an ORG
                                   or negative for a valid code line
    """
    parts[0] = parts[0].upper()
    if len(parts) == 3 and parts[1].upper() == 'EQU':
        return define(parts[0], parts[2])
    if re.match(label_pat, parts[0]):
        label = parts[0]
        label = label[0:-1]
        labels[label] = pos
        del parts[0]
        if len(parts) == 0:
            return [], -1
    if parts[0] == 'ORG':
        return [], parse_number(parts[1])
    if parts[0] == 'DB':
        return parse_bytes(parts[1:]), -1
    if parts[0] == 'DW':
        return parse_words(parts[1:]), -1
    if parts[0] == 'BUF':
        return [0] * parse_number(parts[1]), -1
    m = re.match(def_str, ' '.join(parts))
    if m:
        s = m.groups()[0]
        return [ord(x) for x in s], -1
    candidates = get_instructions(parts[0])
    if candidates is not None:
        instruction = " ".join(parts)
        code = find_match(candidates, instruction.upper(), pos)
        if len(code) == 0:
            raise ASMSyntaxError()
        return code, -1
    raise ASMSyntaxError()


def fix_negatives(code):
    """
    Two's complement   e.g.  -1  ->  255
    """
    for i in range(len(code)):
        if code[i] < 0:
            code[i] = 256 + code[i]


def assemble(src):
    """
    Given a source file name, assemble it into machine code

    :param src:
    :return: binary program bytes
    """
    full_code = []
    pos = 0
    last_line = ''
    try:
        listing = []
        for line_number, line in enumerate(open(src).readlines()):
            last_line = line.strip()
            line = remove_comments(line)
            parts = shlex.split(line, False, False)
            if len(parts) == 0:
                continue
            code, new_pos = parse_line(parts, pos)
            if new_pos >= 0:
                pos = new_pos
            elif code:
                fix_negatives(code)
                if pos > len(full_code):
                    full_code.extend([0] * (pos - len(full_code)))
                listing.append((pos, line_number, code, last_line))
                full_code[pos:(pos + len(code))] = code
                pos = pos + len(code)
        return bytes(full_code), listing
    except ASMSyntaxError as e:
        print(last_line)
        print(f'{e} in line {line_number}')
        return None, None
    except Exception as e:
        print(f"Syntax error in line {line_number}")
        print(last_line)
        return None, None


def hexbytes(code):
    s = [f'{b:#0{4}x}' for b in code]
    s = [b[2:] for b in s]
    return ' '.join(s)


def print_listing(f, listing):
    for pos, line_number, code, line in listing:
        f.write(f'{pos:#0{6}x} {str(line_number+1):<4} {hexbytes(code):<16} {line}\n')


def main():
    parser = argparse.ArgumentParser(description='Z80 Assembler')
    parser.add_argument('source', type=str, help='Asm source file to assemble')
    args = parser.parse_args()
    # print("Pass 1")
    source_name = args.source
    base_name = os.path.splitext(source_name)[0]
    bin_name = base_name + '.bin'
    lst_name = base_name + '.lst'
    code, listing = assemble(args.source)
    if code:
        global assembler_pass
        assembler_pass = 2
        # print("Pass 2")
        code, listing = assemble(args.source)
    if code:
        with open(bin_name, 'wb') as f:
            f.write(code)
        # else:
        #    for line in [code[i:i + 16] for i in range(0, len(code), 16)]:
        #        print(' '.join([f'{byte:02x}'.upper() for byte in list(line)]))
        with open(lst_name, 'w') as f:
            print_listing(f, listing)


if __name__ == '__main__':
    main()
