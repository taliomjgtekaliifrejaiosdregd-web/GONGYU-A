# -*- coding: utf-8 -*-
import re

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

lines = data.split(b'\n')

# Find _buildTypeSelector method
for i, line in enumerate(lines):
    if b'  Widget _buildTypeSelector()' in line and b'{' in line:
        start = i
        break

# Find end (matching })
depth = 0
for i in range(start, len(lines)):
    depth += lines[i].count(b'{') - lines[i].count(b'}')
    if depth == 0:
        end = i
        break

print(f'_buildTypeSelector: lines {start+1} to {end+1}')
method_text = b'\n'.join(lines[start:end+1]).decode('utf-8', errors='replace')

# Remove strings and comments to count parens accurately
# Remove triple-quoted strings
clean = re.sub(r"'''[\s\S]*?'''", "''", method_text)
clean = re.sub(r'"""[\s\S]*?"""', '""', clean)
# Remove single-quoted strings (simple: non-greedy)
clean = re.sub(r"'(?:[^'\\]|\\.)*'", "''", clean)
# Remove double-quoted strings
clean = re.sub(r'"(?:[^"\\]|\\.)*"', '""', clean)
# Remove template strings ${
clean = re.sub(r'\$\{[^}]*\}', '$', clean)
# Remove // comments
clean = re.sub(r'//.*', '', clean)
# Remove /* */ comments
clean = re.sub(r'/\*[\s\S]*?\*/', '', clean)

# Now count parens/brackets
opens = clean.count('(')
closes = clean.count(')')
b_opens = clean.count('[')
b_closes = clean.count(']')

print(f'Raw count: opens={opens} closes={closes} net={opens-closes}')
print(f'Brackets: opens={b_opens} closes={b_closes} net={b_opens-b_closes}')

# Find the line where the imbalance starts
running = 0
for i, line in enumerate(lines[start:end+1]):
    line_str = line.decode('utf-8', errors='replace')
    # Remove strings from this line
    l2 = re.sub(r"'''[\s\S]*?'''", "''", line_str)
    l2 = re.sub(r'"""[\s\S]*?"""', '""', l2)
    l2 = re.sub(r"'(?:[^'\\]|\\.)*'", "''", l2)
    l2 = re.sub(r'"(?:[^"\\]|\\.)*"', '""', l2)
    l2 = re.sub(r'\$\{[^}]*\}', '$', l2)
    l2 = re.sub(r'//.*', '', l2)
    
    delta = l2.count('(') - l2.count(')')
    delta_b = l2.count('[') - l2.count(']')
    running += delta
    rb = 0
    if delta != 0 or delta_b != 0:
        rb += delta_b
        print(f'L{start+i+1}: {running:+.0f}/{rb:+.0f} ({delta:+.0f}/{delta_b:+.0f}): {line_str.strip()[:60]}')
