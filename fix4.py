# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

# Current: b'    ]));\r\n  }' (9 bytes: 4 spaces + ] + 3*')' + ; + \r + \n + 2 spaces + })
# Need:     b'    ])));\r\n  }' (10 bytes: 4 spaces + ] + 4*')' + ; + \r + \n + 2 spaces + })

# The old pattern: 4 spaces + ] + 3 parens + ; + \r\n + 2 spaces + }
old = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d\x0a\x20\x20\x7d'
# The new pattern: 4 spaces + ] + 4 parens + ; + \r\n + 2 spaces + }
new = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x29\x3b\x0d\x0a\x20\x20\x7d'

if old in data:
    data = data.replace(old, new, 1)
    with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'wb') as f:
        f.write(data)
    print('SUCCESS: Changed 3 parens to 4 parens')
else:
    print('Pattern not found!')
    # Show what we have
    idx = data.find(b'    ]))')
    if idx >= 0:
        snippet = data[idx:idx+20]
        print('Found:', repr(snippet))
        print('Bytes:', list(snippet))
