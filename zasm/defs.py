import re

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
