data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace').read()
for i, line in enumerate(data.split('\n'), 1):
    if any(kw in line for kw in ['scan', 'Scan', '扫码', 'camera', 'Camera', 'photo', 'Photo', 'ImagePicker', 'image_picker']):
        print(f'L{i}: {line.strip()[:80]}')
