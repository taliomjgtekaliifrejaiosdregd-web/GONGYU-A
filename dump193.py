data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb').read()
lines = data.split(b'\n')
l193 = lines[192]  # 0-indexed
print('L193 length:', len(l193))
print('L193 ends with:')
# Print last 30 bytes
last30 = l193[-30:]
print(repr(last30))
print('Hex:', [hex(b) for b in last30])

# Count parens
opens = sum(1 for b in l193 if b == 0x28)
closes = sum(1 for b in l193 if b == 0x29)
print(f'opens={opens}, closes={closes}, net={opens-closes}')
