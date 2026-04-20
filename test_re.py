# -*- coding: utf-8 -*-
import re

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

lines = data.split(b'\n')

# Get L194 raw
l194 = lines[193].decode('utf-8', errors='replace')
print(f'Original L194: {l194}')
print(f'Length: {len(l194)}')
print(f'( count: {l194.count("(")}, ) count: {l194.count(")")}')
print()

# Apply each string removal step
s = l194
print(f'Step 0 (original): ( = {s.count("(")}, ) = {s.count(")")}')

# Triple quoted
s2 = re.sub(r"'''[\s\S]*?'''", "''", s)
print(f'Step 1 (triple q): ( = {s2.count("(")}, ) = {s2.count(")")}')
print(f'  Content: {repr(s2)}')

s3 = re.sub(r'"""[\s\S]*?"""', '""', s2)
print(f'Step 2 (double triple q): ( = {s3.count("(")}, ) = {s3.count(")")}')

# Single quoted - this is the critical step
s4 = re.sub(r"'(?:[^'\\]|\\.)*'", "''", s3)
print(f'Step 3 (single q): ( = {s4.count("(")}, ) = {s4.count(")")}')
print(f'  Content: {repr(s4)}')

# Double quoted
s5 = re.sub(r'"(?:[^"\\]|\\.)*"', '""', s4)
print(f'Step 4 (double q): ( = {s5.count("(")}, ) = {s5.count(")")}')
print(f'  Content: {repr(s5)}')
