data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb').read()
print('File size:', len(data))
lines = data.split(b'\n')
print('Lines:', len(lines))
