d = open(r'D:\Projects\gongyu_guanjia\lib\main.dart', 'r', encoding='utf-8', errors='replace').read()
# Find where routes are defined
for i, line in enumerate(d.split('\n'), 1):
    if any(kw in line for kw in ['repair-manage', 'termination-manage', '/alert', 'repair_list']):
        print(f'L{i}: {line.strip()[:100]}')
