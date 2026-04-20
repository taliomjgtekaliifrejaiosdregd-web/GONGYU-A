# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f'File size before: {len(data)}')

# Find _QRScannerSheet (it's inside _FormField currently)
qr_start = data.find('class _QRScannerSheet')
print(f'_QRScannerSheet at {qr_start}')

if qr_start >= 0:
    # Find the closing brace of the file
    last_brace = data.rfind('}')
    print(f'Last brace at {last_brace}')
    
    # Extract the new classes
    new_classes = data[qr_start:last_brace+1]
    print(f'New classes length: {len(new_classes)}')
    
    # Remove from inside _FormField
    data = data[:qr_start] + data[last_brace+1:]
    print(f'After removal: {len(data)}')
    
    # Now find where _FormField ends
    idx = data.find('class _FormField extends StatelessWidget')
    depth = 0
    i = data.find('{', idx)
    end_pos = -1
    while i < len(data):
        if data[i] == '{': depth += 1
        elif data[i] == '}':
            depth -= 1
            if depth == 0:
                end_pos = i
                break
        i += 1
    print(f'_FormField ends at {end_pos}')
    
    # Insert new classes AFTER _FormField
    # Find the next class after _FormField (there shouldn't be one, so insert at end)
    data = data[:end_pos+1] + '\n\n' + new_classes
    
    print(f'Final size: {len(data)}')
else:
    print('_QRScannerSheet not found - already fixed?')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print('Saved!')
