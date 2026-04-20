# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

# Current line 237: b'    ]));\r' (9 bytes: 4 spaces + ] + 3 parens + ;)
# Need: b'    ])));\r' (10 bytes: 4 spaces + ] + 4 parens + ;)
# Change: add one more ) after the existing 3

old_bytes = b'    ]));\r\n  }'
new_bytes = b'    ])));\r\n  }'

if old_bytes in data:
    data = data.replace(old_bytes, new_bytes, 1)
    with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'wb') as f:
        f.write(data)
    print('Fixed: added extra )')
else:
    print('Pattern not found! Looking for:')
    idx = data.find(b'    ]))')
    if idx >= 0:
        print(repr(data[idx:idx+30]))
