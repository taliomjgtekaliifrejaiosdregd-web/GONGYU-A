# -*- coding: utf-8 -*-
import sys

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    lines = f.readlines()

# Only look at lines 221-237 (0-indexed 220-236)
in_string = False
string_char = None
parens_open = 0
parens_close = 0
brackets_open = 0
brackets_close = 0
braces_open = 0
braces_close = 0

for i in range(220, 237):
    line = lines[i]
    chars = list(line)
    for j, c in enumerate(chars):
        if not in_string:
            if c in ('"', "'", '`'):
                in_string = True
                string_char = c
            elif c == '(':
                parens_open += 1
                sys.stdout.write('(')
            elif c == ')':
                parens_close += 1
                sys.stdout.write(')')
            elif c == '[':
                brackets_open += 1
                sys.stdout.write('[')
            elif c == ']':
                brackets_close += 1
                sys.stdout.write(']')
        else:
            if c == string_char and (string_char != "'" or True):
                # Simple: if same char and not in the middle of an escape
                # Check for \' or \" escapes
                prev = chars[j-1] if j > 0 else ''
                if prev != '\\':
                    in_string = False
                    string_char = None
    sys.stdout.write(f"  -> L{i+1}: parens {parens_open-parens_close:+d} brackets {brackets_open-brackets_close:+d}\n")
    sys.stdout.flush()

print()
print(f"Final: parens delta={parens_open-parens_close} brackets delta={brackets_open-brackets_close}")
print(f"  Open: (={parens_open} )={parens_close} [{brackets_open} ]={brackets_close}")
