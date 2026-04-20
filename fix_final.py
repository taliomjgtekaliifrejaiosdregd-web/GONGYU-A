# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'rb') as f:
    data = f.read()

# Find _buildTypeSpecificFields - show its full content
idx = data.find(b'_buildTypeSpecificFields')
if idx >= 0:
    # Find method start {
    brace_start = data.find(b'{', idx)
    # Find matching }
    depth = 0
    i = brace_start
    while i < len(data):
        if data[i:i+1] == b'{': depth += 1
        elif data[i:i+1] == b'}':
            depth -= 1
            if depth == 0: break
        i += 1
    method_bytes = data[brace_start:i+1]
    lines = method_bytes.split(b'\n')
    print(f'_buildTypeSpecificFields: {len(lines)} lines, {len(method_bytes)} bytes')
    print('ALL lines:')
    for j, line in enumerate(lines):
        print(f'  {j}: {repr(line[:80])}')

print()
# Find _buildForm - show its full content
idx = data.find(b'  Widget _buildForm() {')
if idx >= 0:
    brace_start = idx + len(b'  Widget _buildForm() {') - 1
    depth = 1
    i = brace_start + 1
    while i < len(data):
        if data[i:i+1] == b'{': depth += 1
        elif data[i:i+1] == b'}':
            depth -= 1
            if depth == 0: break
        i += 1
    method_bytes = data[brace_start:i+1]
    lines = method_bytes.split(b'\n')
    print(f'_buildForm: {len(lines)} lines, {len(method_bytes)} bytes')
    print('Last 8 lines:')
    for j, line in enumerate(lines[-8:]):
        print(f'  {len(lines)-8+j}: {repr(line[:80])}')
