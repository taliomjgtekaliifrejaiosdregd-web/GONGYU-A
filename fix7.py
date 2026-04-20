data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb').read()
lines = data.split(b'\n')

# Show key lines to understand structure
for i in [192, 193, 194, 195, 196, 197, 198, 199, 200, 234, 235, 236, 237, 238, 239, 240]:
    if i < len(lines):
        print(f'L{i+1}: {repr(lines[i][:60])}')
