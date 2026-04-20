data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb').read()
lines = data.split(b'\n')

# Find _buildForm method
for i, line in enumerate(lines):
    if b'Widget _buildForm()' in line:
        start = i
        print(f'_buildForm at L{i+1}')
        break

# Find end (matching })
depth = 0
for i in range(start, len(lines)):
    depth += lines[i].count(b'{') - lines[i].count(b'}')
    if depth == 0 and i > start:
        end = i
        break

print(f'_buildForm: L{start+1} to L{end+1}')

# Check last 5 lines
for i in range(end-4, end+1):
    line = lines[i]
    opens = line.count(b'(')
    closes = line.count(b')')
    print(f'L{i+1}: opens={opens} closes={closes} {repr(line.strip()[:60])}')

# Count parens in the whole method
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
print(f'\nTotal _buildForm balance: opens={opens} closes={closes} net={opens-closes}')
