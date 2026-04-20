# -*- coding: utf-8 -*-
# Rebuild the _buildForm method with correct syntax

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Find _buildForm method start
start_marker = '  Widget _buildForm() {\n    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: ['
start_idx = content.find(start_marker)
if start_idx < 0:
    print(f'Marker not found! Trying partial...')
    alt = '  Widget _buildForm() {'
    alt_idx = content.find(alt)
    print(f'Partial found at: {alt_idx}')
    start_idx = alt_idx

print(f'_buildForm starts at: {start_idx}')

# Find _buildForm method end - the matching } 
# Count from start_idx
depth = 0
i = start_idx
while i < len(content):
    if content[i] == '{':
        depth += 1
    elif content[i] == '}':
        depth -= 1
        if depth == 0:
            break
    i += 1

end_idx = i + 1
print(f'_buildForm ends at: {end_idx}')
print(f'Method length: {end_idx - start_idx} chars')

# Get the method body
method_body = content[start_idx:end_idx]
print(f'Method first 200 chars: {repr(method_body[:200])}')
print(f'Method last 200 chars: {repr(method_body[-200:])}')

# Count parens in the method body (simple: just count all opens and closes)
# Remove strings
import re
clean = re.sub(r"'''[\s\S]*?'''", "''", method_body)
clean = re.sub(r'"""[\s\S]*?"""', '""', clean)
clean = re.sub(r"'(?:[^'\\]|\\.)*'", "''", clean)
clean = re.sub(r'"(?:[^"\\]|\\.)*"', '""', clean)
opens = clean.count('(')
closes = clean.count(')')
print(f'Paren balance: opens={opens}, closes={closes}, net={opens-closes}')
opens_b = clean.count('[')
closes_b = clean.count(']')
print(f'Bracket balance: opens={opens_b}, closes={closes_b}, net={opens_b-closes_b}')

# Show the line numbers of any problematic areas
lines = content[start_idx:end_idx].split('\n')
paren_bal = 0
for j, line in enumerate(lines):
    clean_line = re.sub(r"'''[\s\S]*?'''", "''", line)
    clean_line = re.sub(r'"""[\s\S]*?"""', '""', clean_line)
    clean_line = re.sub(r"'(?:[^'\\]|\\.)*'", "''", clean_line)
    clean_line = re.sub(r'"(?:[^"\\]|\\.)*"', '""', clean_line)
    delta = clean_line.count('(') - clean_line.count(')')
    delta_b = clean_line.count('[') - clean_line.count(']')
    paren_bal += delta
    if delta != 0 or delta_b != 0:
        print(f'  Line {j+1}: paren_delta={delta}, bracket_delta={delta_b}, running={paren_bal}: {repr(line.strip()[:60])}')
