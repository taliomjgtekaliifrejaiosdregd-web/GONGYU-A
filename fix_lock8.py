with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f"File size: {len(data)}")

# Fix 1: constructor 'required this.,' -> 'required this.onCreateTemp,'
# But onCreateTemp was removed, so it should just be removed from the constructor
# Fix: replace 'required this.,' with empty
data = data.replace('required this.,\n    required this.onLoadRecords,', 'required this.onLoadRecords,')
print(f"After fixing constructor: {len(data)}")

# Fix 2: broken _QuickActions widget ': )'
data = data.replace('_QuickActions(onChangePassword: onChangePassword, : ),', '_QuickActions(onChangePassword: onChangePassword),')
print(f"After fixing _QuickActions: {len(data)}")

# Check for any more issues
for pattern in ['required this.,', 'onChangePassword: ,', '_QuickActions(:']:
    idx = data.find(pattern)
    if idx >= 0:
        print(f"Still has: {pattern} at {idx}:", repr(data[idx-30:idx+60]))

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
