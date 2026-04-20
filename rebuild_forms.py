# -*- coding: utf-8 -*-
import re

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    text = f.read()

# Strategy: find the two methods, remove their closing lines, 
# rebuild them with correct syntax.

# === Fix _buildForm ===
# Find "  Widget _buildForm() {" and its method body
m = re.search(r'  Widget _buildForm\(\) \{', text)
if not m:
    print("Cannot find _buildForm!")
    exit()
start = m.start()

# Find matching closing brace
depth = 0
i = m.end() - 1
while i < len(text):
    if text[i] == '{': depth += 1
    elif text[i] == '}':
        depth -= 1
        if depth == 0: break
    i += 1
end = i + 1

form_body = text[start:end]
form_lines = form_body.split('\n')
print(f"_buildForm: {len(form_lines)} lines")

# Find the return statement
return_line_idx = None
for j, line in enumerate(form_lines):
    if 'return SingleChildScrollView' in line:
        return_line_idx = j
        break

print(f"Return statement at line {return_line_idx} of method: {form_lines[return_line_idx][:50]}")

# Count how many open ( there are on the return line
# "return SingleChildScrollView(padding: ..., child: Form(key: ..., child: Column(..., children: ["
return_line = form_lines[return_line_idx]
opens_on_return = return_line.count('(') - return_line.count(')')
print(f"Opens on return line: {opens_on_return}")

# The children list [ should be on the return line too
children_open = 'children: [' in return_line
print(f"Children [ on return line: {children_open}")

# Now look at the last non-empty lines of the method
nonempty = [(j, form_lines[j]) for j in range(len(form_lines)-1, max(0, len(form_lines)-15), -1) 
            if form_lines[j].strip()]
for j, line in nonempty[:8]:
    print(f"  [{len(form_lines)-1-j}] {repr(line[:80])}")

# === Fix _buildTypeSpecificFields ===
m2 = re.search(r'  Widget _buildTypeSpecificFields\(\) \{', text)
if not m2:
    print("Cannot find _buildTypeSpecificFields!")
else:
    start2 = m2.start()
    depth = 0
    i = m2.end() - 1
    while i < len(text):
        if text[i] == '{': depth += 1
        elif text[i] == '}':
            depth -= 1
            if depth == 0: break
        i += 1
    end2 = i + 1
    method2 = text[start2:end2]
    lines2 = method2.split('\n')
    print(f"\n_buildTypeSpecificFields: {len(lines2)} lines")
    for j, line in enumerate(lines2[-5:]):
        print(f"  [{len(lines2)-5+j}] {repr(line[:80])}")
