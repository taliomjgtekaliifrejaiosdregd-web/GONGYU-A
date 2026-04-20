# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

lines = data.split(b'\n')

# Show lines 181-200 with byte-level paren count
for i in range(180, 201):
    line = lines[i]
    # Count parens in this line (raw bytes)
    opens = line.count(b'(')
    closes = line.count(b')')
    opens_b = line.count(b'[')
    closes_b = line.count(b']')
    
    # Show content
    try:
        content = line.decode('utf-8', errors='replace')
    except:
        content = str(line)
    
    print(f'L{i+1:3d}: opens={opens} closes={closes} brackets_o={opens_b} brackets_c={closes_b}')
    print(f'  {repr(content.strip()[:100])}')
