# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

# Fix 1: Line 195 - remove one ):
# Current (wrong): b'    ]))));\r' (4 parens, 11 bytes)
# Correct:         b'    ]));\r'   (3 parens, 10 bytes)
old1 = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x29\x3b\x0d'  # 4 parens (11 bytes)
new1 = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d'       # 3 parens (10 bytes)

# Fix 2: Line 237 - add one ):
# Current (wrong): b'    ]));\r'   (3 parens, 9 bytes)
# Correct:         b'    ])));\r'  (4 parens, 10 bytes)
old2 = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d'       # 3 parens (9 bytes)
new2 = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x29\x3b\x0d'  # 4 parens (10 bytes)

count = 0
if old1 in data:
    data = data.replace(old1, new1, 1)
    print(f'Fix 1 OK: L195 4->3 parens (11->10 bytes)')
    count += 1
else:
    print('Fix 1 FAIL: pattern not found')

if old2 in data:
    data = data.replace(old2, new2, 1)
    print(f'Fix 2 OK: L237 3->4 parens (9->10 bytes)')
    count += 1
else:
    print('Fix 2 FAIL: pattern not found')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'wb') as f:
    f.write(data)
print(f'Done ({count}/2 fixes applied)')
