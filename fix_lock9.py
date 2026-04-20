with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f"File size: {len(data)}")

# Find the exact broken constructor
idx = data.find('required this.,')
if idx >= 0:
    print(f"Found at {idx}:", repr(data[idx-50:idx+100]))
    # Show more context
    start = data.rfind('const _UnlockTab(', max(0, idx-300), idx)
    end = data.find('});', idx, idx+200)
    print(f"\nConstructor start {start}:", repr(data[start:end+5]))
    
    # The fix: remove 'required this.,\n    ' from the constructor
    # Find the pattern more precisely
    bad = "required this.,\n    "
    if bad in data:
        data = data.replace(bad, '')
        print(f"Fixed! New size: {len(data)}")
    else:
        # Try to find the exact bytes
        idx2 = data.find('required this.,')
        print(f"Bad pattern at {idx2}:", repr(data[idx2:idx2+20]))
        # Manually fix it
        # Remove from '    required this.,' to next 'required'
        start_fix = data.rfind('\n    ', max(0, idx2-50), idx2+5)
        end_fix = data.find('required', idx2, idx2+100)
        print(f"Fix from {start_fix} to {end_fix}:", repr(data[start_fix:end_fix]))
        if start_fix >= 0 and end_fix >= 0:
            data = data[:start_fix+1] + data[end_fix:]
            print(f"Manual fix! New size: {len(data)}")
else:
    print("No more required this., found")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
