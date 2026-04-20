data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb').read()
lines = data.split(b'\n')
for i in [193, 194, 195, 196, 197, 198, 199, 200, 235, 236, 237, 238]:
    if i < len(lines):
        print(f'L{i+1}: {repr(lines[i][:70])} parens={lines[i].count(b")")} brackets={lines[i].count(b"]")}')
