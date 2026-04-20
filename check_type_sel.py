data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb').read()
lines = data.split(b'\n')

# Find _buildTypeSelector
for i, line in enumerate(lines):
    if b'Widget _buildTypeSelector()' in line:
        start = i
        print(f'_buildTypeSelector at L{i+1}')
        break

# Find end
depth = 0
for i in range(start, len(lines)):
    depth += lines[i].count(b'{') - lines[i].count(b'}')
    if depth == 0 and i > start:
        end = i
        break

print(f'_buildTypeSelector: L{start+1} to L{end+1}')

# Balance check
method_data = b'\n'.join(lines[start:end+1])
import re
clean = method_data.decode('utf-8', errors='replace')
for pattern, replacement in [
    (r"'''[\s\S]*?'''", "''"),
    (r'"""[\s\S]*?"""', '""'),
    (r"'(?:[^'\\]|\\.)*'", "''"),
    (r'"(?:[^"\\]|\\.)*"', '""'),
]:
    clean = re.sub(pattern, replacement, clean)
opens = clean.count('(')
closes = clean.count(')')
print(f'Balance: opens={opens} closes={closes} net={opens-closes}')

# Last 8 lines
print('\nLast 8 lines:')
for i in range(end-7, end+1):
    line = lines[i]
    opens_l = line.count(b'(')
    closes_l = line.count(b')')
    opens_b = line.count(b'[')
    closes_b = line.count(b']')
    print(f'L{i+1}: opens={opens_l} closes={closes_l} b_o={opens_b} b_c={closes_b}: {repr(line.strip()[:80])}')
