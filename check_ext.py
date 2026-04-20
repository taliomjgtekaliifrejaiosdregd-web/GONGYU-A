# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\room_detail_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find extension
idx = data.find('extension ')
print('extension at:', idx)
if idx >= 0:
    with open(r'D:\temp_ext.txt', 'w', encoding='utf-8', errors='replace') as out:
        out.write(data[idx:idx+300])
    print('Written to temp_ext.txt')

lines = data.split('\n')
if len(lines) > 40:
    print('Line 41:', lines[40])
