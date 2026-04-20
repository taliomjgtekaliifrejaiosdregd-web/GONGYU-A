data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb').read()
lines = data.split(b'\n')

# Check L195
l195 = lines[194]
print(f'L195: length={len(l195)} bytes')
print('Bytes:', [hex(b) for b in l195])
paren_count = sum(1 for b in l195 if b == 0x29)
bracket_count = sum(1 for b in l195 if b == 0x5d)
print(f'Parens: {paren_count}, Brackets: {bracket_count}')
print('Content:', ''.join(chr(b) if 32 <= b < 127 else '.' for b in l195))

print()

# Check L237
l237 = lines[236]
print(f'L237: length={len(l237)} bytes')
print('Bytes:', [hex(b) for b in l237])
paren_count2 = sum(1 for b in l237 if b == 0x29)
bracket_count2 = sum(1 for b in l237 if b == 0x5d)
print(f'Parens: {paren_count2}, Brackets: {bracket_count2}')
print('Content:', ''.join(chr(b) if 32 <= b < 127 else '.' for b in l237))
