# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

import re

# Find all class definitions
classes = []
for m in re.finditer(r'\nclass (_\w+)', data):
    classes.append((m.start(), m.group(1)))

print('Classes in order:')
for pos, name in classes:
    print(f'  {name} at {pos}')

# Find end of _LandlordHomePageState
idx = data.find('class _LandlordHomePageState')
print(f'\n_LandlordHomePageState at {idx}')
depth = 0
i = data.find('{', idx)
end_pos = -1
while i < len(data):
    if data[i] == '{':
        depth += 1
    elif data[i] == '}':
        depth -= 1
        if depth == 0:
            end_pos = i
            break
    i += 1
print(f'_LandlordHomePageState ends at {end_pos}')
print(f'Content: {repr(data[end_pos-30:end_pos+30])}')

# Find end of _LandlordHomeWrapperState
idx2 = data.find('class _LandlordHomeWrapperState')
print(f'\n_LandlordHomeWrapperState at {idx2}')
depth2 = 0
i2 = data.find('{', idx2)
end_pos2 = -1
while i2 < len(data):
    if data[i2] == '{':
        depth2 += 1
    elif data[i2] == '}':
        depth2 -= 1
        if depth2 == 0:
            end_pos2 = i2
            break
    i2 += 1
print(f'_LandlordHomeWrapperState ends at {end_pos2}')
print(f'Content: {repr(data[end_pos2-30:end_pos2+30])}')
