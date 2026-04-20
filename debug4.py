# -*- coding: utf-8 -*-
import sys

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    lines = f.readlines()

# Find _buildForm method - scan for the widget build method that starts at line 198
# Lines 199-237 (0-indexed 198-236)
# return SingleChildScrollView(...)
# -> Form -> Column -> children -> SizedBox (line 221)

# Let's scan from line 199 (where the return starts) to find where SingleChildScrollView closes
# The return is on line 199: "return SingleChildScrollView(..."
# This should close at the end of _buildForm

# Scan lines 198-236 to count parens
in_string = False
string_char = None
escape_next = False
parens = 0
brackets = 0
started = False

for i in range(198, 237):
    line = lines[i]
    j = 0
    while j < len(line):
        c = line[j]
        if escape_next:
            escape_next = False
            j += 1
            continue
        if not in_string:
            if c in ('"', "'"):
                # Check for triple quotes
                if line[j:j+3] in ('"""', "'''"):
                    # triple quoted string - find end
                    end = line.find(line[j:j+3], j+3)
                    if end >= 0:
                        j = end + 3
                        continue
                    else:
                        in_string = True
                        string_char = line[j:j+3]
                        j += 3
                        continue
                else:
                    in_string = True
                    string_char = c
            elif c == '(':
                parens += 1
                started = True
            elif c == ')':
                parens -= 1
            elif c == '[':
                brackets += 1
            elif c == ']':
                brackets -= 1
        else:
            if c == '\\':
                escape_next = True
            elif c == string_char:
                in_string = False
                string_char = None
        j += 1
    if started:
        print(f"L{i+1:3d} parens={parens:+.0f} brackets={brackets:+.0f}  {line.rstrip()[:70]}")

print()
print(f"Final balance: parens={parens} brackets={brackets}")
