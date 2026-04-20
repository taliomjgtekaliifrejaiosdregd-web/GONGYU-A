with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'rb') as f:
    data = f.read()
# Find the broken area
idx = data.find(b'onTap: onChangePassword)),')
if idx >= 0:
    print('Found at', idx)
    print(repr(data[idx:idx+300]))
else:
    print('Not found')
# Find class _PasswordTab
idx2 = data.find(b'class _PasswordTab')
print('class _PasswordTab at', idx2)
if idx2 >= 0:
    # Find the broken area in _PasswordTab
    # Look for 'onTap: onChangePassword' in _PasswordTab
    sub = data[idx2:idx2+3000]
    idx3 = sub.find(b'onTap: onChangePassword')
    if idx3 >= 0:
        print('In _PasswordTab, onTap at', idx3, ':', repr(sub[idx3:idx3+150]))
    else:
        print('No onTap in _PasswordTab')
