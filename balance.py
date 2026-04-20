# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

lines = data.split(b'\n')

# Find _buildTypeSelector
m_start = None
m_end = None
for i, line in enumerate(lines):
    if b'  Widget _buildTypeSelector()' in line and b'{' in line:
        m_start = i
    if m_start is not None and i > m_start:
        # Check if this is the closing brace of _buildTypeSelector
        if line.strip() == b'}':
            # Count braces from method start
            depth = 0
            for j in range(m_start, i+1):
                depth += lines[j].count(b'{') - lines[j].count(b'}')
            if depth == 0:
                m_end = i
                break

print(f'_buildTypeSelector: lines {m_start+1} to {m_end+1}')

# Count parens and brackets through the method
paren_bal = 0
bracket_bal = 0
for i in range(m_start, m_end+1):
    line = lines[i]
    # Simple: count ( ) [ ] but skip string content
    # We need to skip content inside strings
    # Simple heuristic: string starts with ' or " and ends before the next ' or " not preceded by \
    s = bytearray()
    in_str = False
    str_char = None
    escape = False
    for c in line:
        if escape:
            escape = False
            s.append(c)
        elif in_str:
            if c == str_char:
                in_str = False
                str_char = None
            s.append(c)
        else:
            if c in (b"'"[0], b'"'[0]):
                in_str = True
                str_char = c
            elif c == b'\\'[0]:
                escape = True
            s.append(c)
    
    line_str = s.decode('utf-8', errors='replace')
    p_open = line_str.count('(')
    p_close = line_str.count(')')
    b_open = line_str.count('[')
    b_close = line_str.count(']')
    delta_p = p_open - p_close
    delta_b = b_open - b_close
    paren_bal += delta_p
    bracket_bal += delta_b
    if delta_p != 0 or delta_b != 0 or paren_bal != 0 or bracket_bal != 0:
        print(f'L{i+1:3d} {paren_bal:+.0f}/{bracket_bal:+.0f} ({delta_p:+.0f}/{delta_b:+.0f}): {line_str.strip()[:80]}')
    elif i >= m_start + 5:  # only show changes
        pass  # skip unchanged lines after line 5

print(f'Final balance: parens={paren_bal} brackets={bracket_bal}')
