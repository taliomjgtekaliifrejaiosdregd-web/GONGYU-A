# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

lines = data.split(b'\n')
# Find line 195 with context
print('Lines 191-199:')
for i in range(190, 200):
    if i < len(lines):
        print(f'L{i+1}: {repr(lines[i][:80])} parens={lines[i].count(b")")}')

print()
# Find _buildTypeSpecificFields and show its full content
idx = data.find(b'_buildTypeSpecificFields')
print(f'First occurrence at byte {idx}')

# Find all occurrences
pos = 0
count = 0
while True:
    pos = data.find(b'_buildTypeSpecificFields', pos)
    if pos < 0: break
    count += 1
    snippet = data[pos:pos+50]
    print(f'  Occurrence {count} at byte {pos}: {repr(snippet)}')
    pos += 1

# Find all Widget method definitions
print()
print('All Widget method definitions:')
pos = 0
while True:
    pos = data.find(b'  Widget ', pos)
    if pos < 0: break
    snippet = data[pos:pos+40]
    # Find line number
    line_num = data[:pos].count(b'\n') + 1
    print(f'  Line {line_num}: {repr(snippet)}')
    pos += 1
