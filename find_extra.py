# -*- coding: utf-8 -*-
import re

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

lines = data.split(b'\n')

# Get L194 content
l194 = lines[193]
print(f'L194: {l194}')
print(f'Length: {len(l194)}')

# Remove strings to count parens
l194_str = l194.decode('utf-8', errors='replace')
# Remove strings
clean = re.sub(r"'''[\s\S]*?'''", "''", l194_str)
clean = re.sub(r'"""[\s\S]*?"""', '""', clean)
# The string in L194 uses single quotes - try to find where it is
# The string starts at ' and ends at '
# Count: opens=7, closes=8
# Which ) doesn't have matching (?

# Simple: just look at all ) in the clean version
# and find the one that doesn't have a matching (
depth = 0
in_str = False
string_char = None
escape_next = False

print('\nTracking paren depth:')
for i, c in enumerate(clean):
    if escape_next:
        escape_next = False
        continue
    if in_str:
        if c == string_char:
            in_str = False
            string_char = None
        elif c == '\\':
            escape_next = True
        continue
    if c in '"\'':
        in_str = True
        string_char = c
    elif c == '(':
        depth += 1
        print(f'  @{i} OPEN depth={depth}: ...{repr(clean[max(0,i-15):i+20])}...')
    elif c == ')':
        depth -= 1
        print(f'  @{i} CLOSE depth={depth}: ...{repr(clean[max(0,i-15):i+20])}...')

print(f'\nFinal depth: {depth}')
print(f'L194 clean: {repr(clean)}')
