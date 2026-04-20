# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

# Step 1: Revert line 195 (should be 3 parens, not 4)
# Current (wrong): b'    ]))));\r\n  }\r\n\r\n'
# Should be:       b'    ]));\r\n  }\r\n\r\n'
old1 = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x29\x29\x3b\x0d\x0a\x20\x20\x7d\x0d\x0a\x0d\x0a'
new1 = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d\x0a\x20\x20\x7d\x0d\x0a\x0d\x0a'

if old1 in data:
    data = data.replace(old1, new1, 1)
    print('Step 1 OK: reverted line 195')
else:
    print('Step 1 FAIL: pattern not found')
    idx = data.find(b'    ]))))')
    if idx >= 0:
        print('Found at', idx, ':', repr(data[idx:idx+20]))

# Step 2: Now fix line 237 (needs 4 parens, currently has 3)
# Current: b'    ]));\r\n  }\r\n\r\n'
# Should be:     b'    ])));\r\n  }\r\n\r\n'
old2 = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d\x0a\x20\x20\x7d\x0d\x0a\x0d\x0a'
new2 = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x29\x3b\x0d\x0a\x20\x20\x7d\x0d\x0a\x0d\x0a'

if old2 in data:
    data = data.replace(old2, new2, 1)
    print('Step 2 OK: fixed line 237')
else:
    print('Step 2 FAIL: pattern not found')
    idx = data.find(b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d\x0a\x20\x20\x7d')
    if idx >= 0:
        print('Found at', idx, ':', repr(data[idx:idx+20]))

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'wb') as f:
    f.write(data)
print('Done')
