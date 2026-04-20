data = open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb').read()
lines = data.split(b'\n')

print('L193 full content:')
print(lines[192])
print()
print('L194 full content:')
print(lines[193])
print()
print('L195 full content:')
print(lines[194])
print()
print('Context (lines 188-200):')
for i in range(187, 200):
    if i < len(lines):
        print(f'L{i+1}: {repr(lines[i][:100])}')
