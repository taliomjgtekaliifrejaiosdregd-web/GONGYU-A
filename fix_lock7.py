with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f"File size before: {len(data)}")

# Remove broken temp password ActionCard
broken = "atitle:"
idx = data.find(broken)
removed_something = False
if idx >= 0:
    print(f"Found broken at {idx}")
    
    # Find SizedBox before
    sbox = data.rfind('const SizedBox(width: 12)', max(0, idx-500), idx)
    
    # Find end marker
    end_marker = '        ]),\n\n        const SizedBox(height: 20),\n\n'
    found = data.find(end_marker, idx, idx+800)
    
    if found >= 0:
        end_pos = found + len(end_marker)
        removed = data[sbox:end_pos]
        print(f"Removing {len(removed)} chars from {sbox} to {end_pos}")
        data = data[:sbox] + data[end_pos:]
        removed_something = True
        print(f"After removal: {len(data)}")
    else:
        print("Could not find end marker")
else:
    print("No broken content found")

# Verify
issues = ['onCreateTemp', 'add_circle_outline', '临时密码', 'atitle']
all_clean = True
for pattern in issues:
    idx2 = data.find(pattern)
    if idx2 >= 0:
        print(f"STILL HAS: {pattern} at {idx2}")
        all_clean = False
    else:
        print(f"Clean: {pattern}")

if all_clean:
    print("\nAll issues resolved!")
else:
    print("\nSome issues remain!")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print(f"Saved! Final size: {len(data)}")
