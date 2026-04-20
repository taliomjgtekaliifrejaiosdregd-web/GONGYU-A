with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()
lines = data.split(b'\n')
for i, line in enumerate(lines):
    if b'Widget ' in line and b'build' in line and b'{' in line:
        print(f'L{i+1}: {repr(line.strip()[:60])}')
