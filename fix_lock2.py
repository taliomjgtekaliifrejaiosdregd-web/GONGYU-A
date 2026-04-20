with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f"File size: {len(data)}")

# Check what's left
for pattern in ['onCreateTemp', 'add_circle_outline']:
    idx = data.find(pattern)
    while idx >= 0:
        print(f"  {pattern} at {idx}:", repr(data[max(0,idx-30):idx+80]))
        idx = data.find(pattern, idx+1)
        if idx > 50000: break

# Remove remaining onCreateTemp in _PasswordTab class definition
idx = data.find('required this.onCreateTemp,')
if idx >= 0:
    # Find the surrounding context
    # This is in _PasswordTab constructor
    start = data.rfind('\n', max(0, idx-100), idx)
    end = data.find('\n', idx, idx+50)
    # Check this is in _PasswordTab (should be after 'class _PasswordTab')
    pw_class_start = data.find('class _PasswordTab')
    if pw_class_start >= 0 and pw_class_start < idx:
        data = data[:start] + data[end:]
        print(f"Removed onCreateTemp from _PasswordTab class")
    else:
        print(f"onCreateTemp found but not in _PasswordTab class")
else:
    print("No more onCreateTemp in _PasswordTab class")

# Remove the ActionCard for 临时密码 in _PasswordTab
# Find the Expanded(_ActionCard for temp password
temp_action = data.find("title: '")
search_pos = 0
while True:
    idx = data.find("title: '", search_pos)
    if idx < 0 or idx > 60000:
        break
    if idx < 25000 or idx > 42000:
        search_pos = idx + 1
        continue
    # Check if this is the temp password card
    context = data[idx:idx+80]
    if '临时密码' in context or 'onCreateTemp' in context:
        print(f"Found temp password ActionCard at {idx}:", repr(context))
        # Find SizedBox before it
        sbox = data.rfind('const SizedBox(width: 12)', max(0, idx-500), idx)
        end_action = data.find(']);', idx, idx+400)
        if sbox >= 0 and end_action >= 0:
            data = data[:sbox] + data[end_action+3:]
            print(f"Removed ActionCard! New size: {len(data)}")
            break
        else:
            print(f"Could not remove: sbox={sbox}, end={end_action}")
            break
    search_pos = idx + 1

print(f"\nFinal file size: {len(data)}")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
