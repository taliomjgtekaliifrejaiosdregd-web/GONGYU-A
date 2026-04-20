data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb').read()
lines = data.split(b'\n')

# Show L193, L194, L195 in full detail
print('L193 full bytes:', list(lines[192]))
print('L193 full:', lines[192])
print()
print('L194 full bytes:', list(lines[193]))
print('L194 full:', lines[193])
print()
print('L195 full:', lines[194])

# Count ( ) [ ] in L194
l194 = lines[193]
opens = l194.count(b'(')
closes = l194.count(b')')
print(f'\nL194: ( = {opens}, ) = {closes}')

# For L193
l193 = lines[192]
opens = l193.count(b'(')
closes = l193.count(b')')
print(f'L193: ( = {opens}, ) = {closes}')
