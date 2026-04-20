# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

lines = data.split(b'\n')

# Current L195: b'    ]))));' (4 parens)  
# Need: b'    ])););'  (4 parens) - but different arrangement
# Actually: "    ]))));   " followed by ");"  
# Current: "    ]))));   \r\n  }\r" = 4 parens + ;
# Want: "    ])););\r\n  }\r" = 4 parens + ;  
# Same byte count! Just different paren positions.

# Current L195: '    ]))));' = spaces + ] + 4 parens + ;
# Want: '    ])););' = spaces + ] + 3 parens + ) + ;
# Both are 9 bytes. Just the 4th paren moves from position 7 to position 8.

# Current: space(1) space(2) space(3) space(4) ] ] ] ] ] ] ] ]
#           paren(5) paren(6) paren(7) paren(8) ;(9)
# That's: 4 spaces + ] + 4 parens + ;
# = 4 + 1 + 4 + 1 = 10 bytes

# Want: 4 spaces + ] + 3 parens + ) + ;
# = 4 + 1 + 3 + 1 + 1 = 10 bytes
# = 4 spaces + ] + paren + paren + paren + ) + ;

# Current: b'\x20\x20\x20\x20\x5d\x29\x29\x29\x29\x3b\x0d' = 11 bytes (with \r)
# Wait: 4 spaces + ] + 4 parens + ; + \r = 11 bytes

# So I need: b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x29\x0d' = 11 bytes
# = 4 spaces + ] + 3 parens + ) + ; + \r

# But wait: I need "    ])););" = 4 spaces + ] + 3 parens + ) + ;
# That should be: \x20\x20\x20\x20 + \x5d + \x29\x29\x29 + \x3b + \x29 + \x0d
# = 11 bytes

# Current (11 bytes): \x20\x20\x20\x20\x5d\x29\x29\x29\x29\x3b\x0d
# Target (11 bytes): \x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x29\x0d

# The difference: the 4th \x29 (\x3b\x29) becomes (\x29\x3b\x29)
# i.e., one of the closing parens moves from position 8 to position 9 (before the ;)

current = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x29\x3b\x0d'
target = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x29\x0d'

if current in data:
    data = data.replace(current, target, 1)
    with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'wb') as f:
        f.write(data)
    print('FIXED: changed "]))));' to "])));"')
    # Verify
    lines2 = data.split(b'\n')
    print(f'New L195: {repr(lines2[194])}')
else:
    print('Pattern not found!')
    # Find it
    idx = data.find(b'    ])))')
    if idx >= 0:
        print(f'Found "    ])))" at {idx}: {repr(data[idx:idx+20])}')
