data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb').read()
lines = data.split(b'\n')
for i in [194, 236, 237, 238]:
    print(f'L{i+1}: {repr(lines[i])} {len(lines[i])} bytes, {lines[i].count(b")")} parens')
