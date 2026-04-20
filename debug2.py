# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find _buildForm method body
# Start: "Widget _buildForm() {" 
# End: matching closing "}"
method_start = data.find('Widget _buildForm() {')
if method_start < 0:
    print("Could not find _buildForm")
    exit()

# Find matching }
depth = 0
i = method_start
while i < len(data):
    c = data[i]
    if c == '{':
        depth += 1
    elif c == '}':
        depth -= 1
        if depth == 0:
            break
    i += 1

method_end = i
method_body = data[method_start:method_end+1]

print(f"Method body: {method_start} to {method_end}, length={len(method_body)}")

# Now count parens/brackets in the method body, ignoring strings/comments
# Simple approach: remove all string literals first
import re

# Remove string literals (single, double, triple quotes)
clean = re.sub(r"'''[\s\S]*?'''", "''", method_body)  # triple single
clean = re.sub(r'"""[\s\S]*?"""', '""', clean)  # triple double
clean = re.sub(r"'(?:[^'\\]|\\.)*'", "''", clean)  # single-quoted
clean = re.sub(r'"(?:[^"\\]|\\.)*"', '""', clean)  # double-quoted
# Remove template strings ${...}
clean = re.sub(r'\$\{[^}]*\}', '$', clean)  # template interpolation
# Remove // comments
clean = re.sub(r'//.*', '', clean)
# Remove /* */ comments
clean = re.sub(r'/\*[\s\S]*?\*/', '', clean)

# Now count
parens = 0
brackets = 0
for c in clean:
    if c == '(': parens += 1
    elif c == ')': parens -= 1
    elif c == '[': brackets += 1
    elif c == ']': brackets -= 1

print(f"Balance: parens={parens} brackets={brackets}")
if parens != 0 or brackets != 0:
    print("UNBALANCED - this will cause build error!")
else:
    print("BALANCED - syntax looks correct")
