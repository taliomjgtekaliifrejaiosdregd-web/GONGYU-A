# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

# Current L195: 3 parens = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d' (10 bytes)
# Fix to 2 parens: b'\x20\x20\x20\x20\x5d\x29\x29\x3b\x0d' (9 bytes)
old = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d'
new = b'\x20\x20\x20\x20\x5d\x29\x29\x3b\x0d'

if old in data:
    data = data.replace(old, new, 1)
    with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'wb') as f:
        f.write(data)
    print('FIXED: L195 changed from 3 parens to 2 parens')
else:
    print('Pattern not found! Current L195:')
    lines = data.split(b'\n')
    l195 = lines[194]
    print(f'  {repr(l195)} ({len(l195)} bytes)')
