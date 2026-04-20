# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    lines = f.readlines()

# Find the SizedBox + ElevatedButton block
start = -1
end = -1
for i, line in enumerate(lines):
    if 'SizedBox(width: double.infinity' in line and 'child: ElevatedButton' in line:
        start = i
    if start >= 0 and i > start and line.strip() == ');':
        end = i
        break

print(f"Block: lines {start+1} to {end+1}")
print()
for i in range(max(0,start-1), min(len(lines), end+3)):
    print(f"{i+1}: {repr(lines[i])}")
