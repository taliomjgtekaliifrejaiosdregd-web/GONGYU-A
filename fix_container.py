# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

lines = data.split(b'\n')

# Find L193: Container line
l193 = lines[192]
print(f'L193 ends with: {repr(l193[-30:])}')
print(f'L193 length: {len(l193)}')

# Find the position of L194
l194 = lines[193]
print(f'L194 starts: {repr(l194[:40])}')

# The L193 ends with: `..., border: Border.all(color: const Color(...).withOpacity(0.2))),`
# I need to add a `)` before the `,` to close Container
# Current: `...))),` (3 parens + comma = Container not closed)
# Want:   `...))),)` (4 parens + comma = Container closes)

# The current L193 ending is:
# `...0.2))),` = .withOpacity(0.2))) + ,
# That's: withOpacity( 0.2 ) ) , = 2 parens + comma
# The 3 parens are: Color, withOpacity, Border.all, and the 4th paren closes BoxDecoration?
# Wait, let me just find the pattern: the last few bytes before the `,`

# Find where the `,` is before L194
# L193 ends with `...))),` (3 parens + comma)
# I need: `...))),)` (4 parens + comma)

# The last 3 bytes of L193 are: \x3b (\x0d = cr)? Let me check
print(f'Last bytes of L193: {[hex(b) for b in l193[-5:]]}')

# Find the `,` that ends L193
comma_pos = l193.rfind(b',')
print(f'Comma at position: {comma_pos} from end')
print(f'Around comma: {repr(l193[comma_pos-5:comma_pos+3])}')

# Current ending: `))),` (3 parens + comma)
# Need: `))),)` (4 parens + comma)
# The fix: add one `)` before the `,`

# Find the `,` at the end of L193 (before \r\n)
# L193 = `..., border: Border.all(color: ...0.2))),` + \r\n
# The `,` is the one before \r\n
# The pattern to find: the last `,` that ends L193

# Strategy: find the last `)` before the final `,\r\n`
# The last `)` before `,\r\n` should be changed to `),\r\n`
# Actually, I need to add one `)` before the final `,`

# Find the pattern: the last 2 bytes before the \r\n
# Should be `),\r\n` = 0x2c 0x0d
last2 = l193[-2:]
print(f'Last 2 bytes: {repr(last2)} = {[hex(b) for b in last2]}')
# If last2 is `),\r`, that's correct (comma + CR)
# Wait, but L193 ends with `))),` which is 3 parens + comma + \r\n

# The `,` is at position len-2 (just before \r)
# I need to insert `)` before `,`
# Current: `...0.2))),\r\n`
# Want:   `...0.2))),)\r\n`

# The ending pattern: ...0.2))),\r\n
# = last 6 bytes: `\x2c\x0d\x0a` = `,\r\n`
# Replace `,\r\n` with `),\r\n`

old_ending = l193[-6:]
new_ending = l193[-6:-3] + b')\x0d\x0a'
print(f'Old ending: {repr(old_ending)}')
print(f'New ending: {repr(new_ending)}')

if data.endswith(l193 + b'\n' + l194):
    # Replace the L193 + \n + L194 boundary
    old_boundary = l193 + b'\n' + l194
    # Insert `)` before the final `,` of L193
    # Actually, find the last `,` in L193
    last_comma = l193.rfind(b',')
    # Insert `)` at that position
    new_l193 = l193[:last_comma] + b')' + l193[last_comma:]
    new_boundary = new_l193 + b'\n' + l194
    
    if old_boundary in data:
        data = data.replace(old_boundary, new_boundary, 1)
        print('FIXED: added ) before final comma of L193')
        with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'wb') as f:
            f.write(data)
    else:
        print('OLD boundary not found!')
        print(f'Looking for: {repr(old_boundary[:50])}')
else:
    print('L193 + \\n + L194 pattern not found')
    # Try without \n
    if l193 + l194 in data:
        print('Found without \\n separator')
    else:
        print('Also not found without \\n')
