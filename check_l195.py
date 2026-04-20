data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb').read()
lines = data.split(b'\n')
l195 = lines[194]
print('L195:', repr(l195))
print('Length:', len(l195))
# Show hex of each byte
print('Hex:', [hex(b) for b in l195])
