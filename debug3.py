# -*- coding: utf-8 -*-
import re

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find _buildForm method body
method_start = data.find('Widget _buildForm() {')
if method_start < 0:
    print("Could not find _buildForm")
    exit()

depth = 0
i = method_start
while i < len(data):
    c = data[i]
    if c == '{': depth += 1
    elif c == '}':
        depth -= 1
        if depth == 0:
            break
    i += 1

method_end = i
method_body = data[method_start:method_end+1]

# Remove strings and comments
clean = re.sub(r"'''[\s\S]*?'''", "''", method_body)
clean = re.sub(r'"""[\s\S]*?"""', '""', clean)
clean = re.sub(r"'(?:[^'\\]|\\.)*'", "''", clean)
clean = re.sub(r'"(?:[^"\\]|\\.)*"', '""', clean)
# Remove ${...} (template strings) - need nested brace support
# Simple: just remove $ when not followed by {
# Actually for our case, let's just replace $ with empty
clean = re.sub(r'\$', '', clean)
clean = re.sub(r'//.*', '', clean)
clean = re.sub(r'/\*[\s\S]*?\*/', '', clean)

# Now scan and find the first place where parens go negative
parens = 0
for idx, c in enumerate(clean):
    if c == '(':
        parens += 1
    elif c == ')':
        parens -= 1
    if parens < 0:
        # Find the line number in the original method_body
        line_num = clean[:idx].count('\n') + 1
        line_start = 0
        lc = 0
        for li, ch in enumerate(clean):
            if ch == '\n':
                lc += 1
            if lc >= line_num - 1:
                line_start = li + 1
                break
        line_end = clean.find('\n', line_start)
        bad_line = clean[line_start:line_end]
        print(f"First paren negative at char {idx}, line {line_num} in method body:")
        print(f"  -> {bad_line.strip()}")
        print(f"  Context: ...{repr(clean[max(0,idx-30):idx+5])}...")
        break

if parens == 0:
    print("All balanced!")
else:
    print(f"Final parens balance: {parens} (all excess ) are at the END)")
    # Show the last 100 chars
    print(f"End of method: {repr(clean[-100:])}")
