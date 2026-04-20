# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

# Find the section to replace using bytes
# The section from "const SizedBox(height: 24),\r\n" to the end of _buildTypeSelector
idx1 = data.find(b'const SizedBox(height: 24),\r\n      Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration')
if idx1 < 0:
    idx1 = data.find(b'const SizedBox(height: 24),\n      Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration')
    print(f'LF version found at {idx1}')

print(f'Section start: {idx1}')

# Find the end: the method body closing }
# After the section we want to replace up to and including "    ])));\r\n  }"
# Actually, find "    ])));\r\n  }"
idx2_search = data.find(b'    ])));\r\n  }')
if idx2_search < 0:
    idx2_search = data.find(b'    ]));\n  }')
    print(f'Alternative end found at {idx2_search}')

print(f'Section end (search): {idx2_search}')

# The section to replace: from idx1 to idx2_search + len("    ])));\r\n  }")
if idx1 >= 0 and idx2_search >= 0:
    end_marker = data.find(b'\r\n  }\r\n', idx2_search)
    if end_marker >= 0:
        end_marker += len(b'\r\n  }')
    else:
        end_marker = data.find(b'\n  }\n', idx2_search)
        if end_marker >= 0:
            end_marker += len(b'\n  }')
    
    print(f'Method end marker: {end_marker}')
    
    # Show what we're replacing
    print('OLD content:')
    old_section = data[idx1:end_marker+1]
    print(repr(old_section[:200]))
    print('...')
    print(repr(old_section[-100:]))
    
    # NEW content: the same section but with correct closing parens
    # The correct ending should be:
    # - Row's children: ]   - Row: )
    # - Column's children: ]  - Column: )
    # - Form: )
    # - SSS: )
    # That's: ]));); plus ;
    # BUT: Container also needs to be closed!
    # If Container is at the end of Column's children: the ] after Row closes Column's children
    # Then: ) closes Column, ) closes Form, ) closes SSS, ; ends return
    # = ])););
    # BUT we also need to close Container!
    # Container was closed on line 194: ", after Container's child = Row closes Container
    # Actually: Container(..., child: Row(...)), → the last ), closes Container
    # So: Row closes with ]), Container closes with ), Column's children with ], Column with ), Form with ), SSS with );
    # That's: ],)])););
    # Wait, that's: ] + ),] + )); + ); = too many
    
    # Let me try the simplest fix: just change line 195 from 3 parens to 4 parens
    # Old line 195: b'    ])));\r\n  }\r\n'
    # New line 195: b'    ])));\r\n  }\r\n' (add 1 more ))
    
    old_end = data[idx2_search:idx2_search+len(b'    ])));\r\n  }')]
    print(f'Old end: {repr(old_end)}')
    
    # Try: change 3 parens to 4 parens
    # b'    ])));\r\n  }\r\n' -> b'    ])));\r\n  }\r\n' (add 1 paren: 3->4)
    # Current old_end bytes: 4 spaces + ] + 3 parens + ; + crlf + 2 spaces + }
    # b'    ])));\r\n  }' = 4 + 1 + 3 + 1 + 2 + 2 = 13 bytes
    # Need: 4 + 1 + 4 + 1 + 2 + 2 = 14 bytes
    
    # The specific bytes to change: the 3rd closing paren before ;
    # old_end: \x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d\x0a\x20\x20\x7d
    # = 4sp + ] + 3 parens + ; + crlf + 2sp + }
    # old_end[7] = \x29 (3rd paren)
    # We want 4 parens: need to add one \x29 at position 7
    
    old_bytes = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x3b\x0d\x0a\x20\x20\x7d'
    new_bytes = b'\x20\x20\x20\x20\x5d\x29\x29\x29\x29\x3b\x0d\x0a\x20\x20\x7d'
    
    if old_bytes in data:
        data = data.replace(old_bytes, new_bytes, 1)
        print('FIX APPLIED: changed 3 parens to 4 parens at line 195')
        with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'wb') as f:
            f.write(data)
    else:
        print('OLD pattern not found!')
        # Try to find it
        pos = data.find(b'    ])))')
        if pos >= 0:
            print(f'Found ) at {pos}: {repr(data[pos:pos+20])}')
else:
    print(f'idx1={idx1}, idx2_search={idx2_search}')
