with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'rb') as f:
    data = f.read()

print(f"File size: {len(data)}")

# Fix _PasswordTab: add closing ]); for the Row before password list
# The broken pattern (from _PasswordTab):
old_pw = b"onTap: onChangePassword)),\r\n                  // \xe6\x9c\x89\xe6\x95\x88\xe5\xaf\x86\xe7\xa0\x81\xe5\x88\x97\xe8\xa1\xa8\r\n        const Text"
new_pw = b"onTap: onChangePassword)),\r\n        ]);\r\n\n        const Text"

if old_pw in data:
    data = data.replace(old_pw, new_pw)
    print("Fixed _PasswordTab!")
else:
    print("Pattern not found, trying alternate")
    # Try to find and show what's there
    idx = data.find(b"onTap: onChangePassword)),")
    if idx >= 0:
        # Only replace the first occurrence (the one in _PasswordTab)
        # Find it in _PasswordTab section
        pwtab_idx = data.find(b'class _PasswordTab')
        if pwtab_idx_idx >= 0 and idx > pwtab_idx:
            sub = data[pwtab_idx:pwtab_idx+5000]
            sub2 = sub.find(b"onTap: onChangePassword)),")
            if sub2 >= 0:
                # Replace in the data
                actual_pos = pwtab_idx + sub2
                print(f"Found at {actual_pos}:", repr(data[actual_pos:actual_pos+100]))
                # Replace with new content
                replacement = b"onTap: onChangePassword)),\r\n        ]);\r\n\n        "
                data = data[:actual_pos+len("onTap: onChangePassword)),")] + replacement + data[actual_pos+len("onTap: onChangePassword)),\r\n                  // 有效密码列表"):]
                print("Fixed via alternate method")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'wb') as f:
    f.write(data)
print(f"Final size: {len(data)}")
print("Saved!")
