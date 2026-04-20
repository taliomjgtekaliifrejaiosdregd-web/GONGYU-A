# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Fix extra ) on line 237: '    ])));'  -> '    ]));'
old = '    ])));'
new = '    ]));'
if old in data:
    data = data.replace(old, new, 1)
    print('Fixed: removed extra ) from line 237')
else:
    print('Pattern not found, checking...')
    lines = data.split('\n')
    print('Line 237:', repr(lines[236]))
    print('Line 238:', repr(lines[237]))

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
