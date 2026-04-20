with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f"File size: {len(data)}")

# Find the broken ActionCard with onTap: )
# Search for "onTap: )" which is the broken remaining after removing onCreateTemp
broken = "onTap: )"
idx = data.find(broken)
if idx >= 0:
    print(f"Found broken onTap at {idx}:")
    print(repr(data[max(0,idx-300):idx+100]))
    # Find the SizedBox before and ]); after
    sbox = data.rfind('const SizedBox(width: 12)', max(0, idx-500), idx)
    end_action = data.find(']);', idx, idx+400)
    print(f"sbox={sbox}, end_action={end_action}")
    if sbox >= 0 and end_action >= 0:
        data = data[:sbox] + data[end_action+3:]
        print(f"Removed! New size: {len(data)}")
    else:
        print("Could not find boundaries")
else:
    print("Broken onTap not found")

# Check for any remaining temp password refs
for pattern in ['onCreateTemp', 'add_circle_outline', '临时密码']:
    idx2 = data.find(pattern)
    if idx2 >= 0:
        print(f"Still has: {pattern} at {idx2}:", repr(data[max(0,idx2-50):idx2+80]))

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
