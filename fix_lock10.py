with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f"File size: {len(data)}")

# Check current state of constructor
idx = data.find('onChangePassword,')
if idx >= 0:
    print("Around onChangePassword,", repr(data[idx:idx+100]))

# Fix: remove duplicate '\n, ' after removing onCreateTemp
# The pattern should be: 'onChangePassword,\n, required' -> 'onChangePassword,\nrequired'
bad = 'onChangePassword,\n, required'
if bad in data:
    data = data.replace(bad, 'onChangePassword,\n    required')
    print("Fixed duplicate comma!")
else:
    print("Pattern not found, trying alternate")
    # Check what's actually there
    idx2 = data.find('onChangePassword,')
    if idx2 >= 0:
        snippet = data[idx2:idx2+60]
        print("Actual:", repr(snippet))
        # Try to fix by replacing '\n, ' with '\n    '
        if '\n, ' in snippet:
            fixed = snippet.replace('\n, ', '\n    ')
            data = data[:idx2] + fixed + data[idx2+len(snippet):]
            print("Fixed!")
        else:
            print("Could not find pattern to fix")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print(f"Final size: {len(data)}")
