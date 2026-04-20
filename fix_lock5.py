with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f"File size: {len(data)}")

# Find the broken area - 'icon: Icons.atitle:' is broken
broken = "icon: Icons.atitle:"
idx = data.find(broken)
if idx >= 0:
    print(f"Found broken at {idx}:")
    # Show context
    print(repr(data[max(0,idx-400):idx+300]))
    print()
    # The start is the SizedBox before this ActionCard
    sbox = data.rfind('const SizedBox(width: 12)', max(0, idx-500), idx)
    print(f"sbox at {sbox}:", repr(data[sbox:sbox+30] if sbox >= 0 else "NOT FOUND"))
    # The end is the nearest ]);\n after the broken area
    end_idx = data.find(']);\n', idx, idx+500)
    if end_idx < 0:
        end_idx = data.find(']);', idx, idx+500)
    print(f"end at {end_idx}:", repr(data[end_idx:end_idx+10] if end_idx >= 0 else "NOT FOUND"))
    
    if sbox >= 0 and end_idx >= 0:
        # Remove the entire block
        removal = data[sbox:end_idx+3]
        print(f"\nRemoving {len(removal)} chars:")
        print(repr(removal))
        data = data[:sbox] + data[end_idx+3:]
        print(f"New size: {len(data)}")
    else:
        print("Could not determine boundaries")

# Verify no more temp password refs
for pattern in ['onCreateTemp', 'add_circle_outline', '临时密码', 'atitle']:
    idx2 = data.find(pattern)
    if idx2 >= 0:
        print(f"STILL HAS: {pattern} at {idx2}")
    else:
        print(f"Clean: {pattern} not found")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
