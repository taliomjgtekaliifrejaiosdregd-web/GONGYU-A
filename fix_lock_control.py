with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

original_len = len(data)
print(f"File size: {original_len}")

# 1. Remove _showCreateTempDialog method (from 'void _showCreateTempDialog()' to 'String _fmt')
method_start = data.find('void _showCreateTempDialog()')
method_end = data.find('String _fmt(', method_start)
if method_start >= 0 and method_end >= 0:
    data = data[:method_start] + data[method_end:]
    print(f"Removed _showCreateTempDialog method ({method_end - method_start} chars)")
else:
    print(f"Could not find method: start={method_start}, end={method_end}")

# 2. Remove onCreateTemp parameter from _UnlockTab call in build()
# Find the _UnlockTab call with onCreateTemp
unlock_tab_ref = data.find('onCreateTemp: _showCreateTempDialog')
if unlock_tab_ref >= 0:
    # Go back to find ',\n' before this
    start = data.rfind(',\n', max(0, unlock_tab_ref - 200), unlock_tab_ref)
    end = data.find('\n', unlock_tab_ref, unlock_tab_ref + 50)
    data = data[:start+1] + data[end:]
    print(f"Removed onCreateTemp from _UnlockTab call")
else:
    print("onCreateTemp in _UnlockTab not found")

# 3. Remove onCreateTemp parameter from _PasswordTab call in build()
pw_tab_ref = data.find('onCreateTemp: _showCreateTempDialog')
if pw_tab_ref >= 0:
    start = data.rfind(',\n', max(0, pw_tab_ref - 200), pw_tab_ref)
    end = data.find('\n', pw_tab_ref, pw_tab_ref + 50)
    data = data[:start+1] + data[end:]
    print(f"Removed onCreateTemp from _PasswordTab call")
else:
    print("onCreateTemp in _PasswordTab not found")

# 4. Remove onCreateTemp parameter from _UnlockTab class definition
unlock_class = data.find('VoidCallback onCreateTemp;')
if unlock_class >= 0:
    # Find the preceding line break
    start = data.rfind('\n', max(0, unlock_class - 100), unlock_class)
    end = data.find('\n', unlock_class, unlock_class + 50)
    data = data[:start] + data[end:]
    print(f"Removed onCreateTemp from _UnlockTab class")
else:
    print("onCreateTemp in _UnlockTab class not found")

# 5. Remove onCreateTemp parameter from _PasswordTab class definition
pw_class = data.find('VoidCallback onCreateTemp;')
if pw_class >= 0:
    start = data.rfind('\n', max(0, pw_class - 100), pw_class)
    end = data.find('\n', pw_class, pw_class + 50)
    data = data[:start] + data[end:]
    print(f"Removed onCreateTemp from _PasswordTab class")
else:
    print("onCreateTemp in _PasswordTab class not found")

# 6. Remove the _ActionCard for 临时密码 in _UnlockTab
# Find the ActionCard with onCreateTemp in UnlockTab
action_unlock = data.find("icon: Icons.add_circle_outline, title:", 0, 30000)
if action_unlock >= 0 and action_unlock < 30000:
    # Check if next char is temp password
    check = data[action_unlock:action_unlock+100]
    if 'onCreateTemp' in check:
        # Find the SizedBox before it
        sbox = data.rfind('const SizedBox(width: 12)', max(0, action_unlock-500), action_unlock)
        end_action = data.find(']);', action_unlock, action_unlock+300)
        if sbox >= 0 and end_action >= 0:
            data = data[:sbox] + data[end_action+3:]
            print(f"Removed _ActionCard temp password from _UnlockTab")
        else:
            print(f"Could not find ActionCard boundaries in UnlockTab: sbox={sbox}, end={end_action}")
    else:
        print("ActionCard in UnlockTab is not temp password")
else:
    print("ActionCard in UnlockTab not found")

# 7. Remove the _ActionCard for 临时密码 in _PasswordTab
action_pw = data.find("icon: Icons.add_circle_outline, title:", 30000)
if action_pw >= 0:
    check = data[action_pw:action_pw+100]
    if 'onCreateTemp' in check:
        sbox = data.rfind('const SizedBox(width: 12)', max(0, action_pw-500), action_pw)
        end_action = data.find(']);', action_pw, action_pw+300)
        if sbox >= 0 and end_action >= 0:
            data = data[:sbox] + data[end_action+3:]
            print(f"Removed _ActionCard temp password from _PasswordTab")
        else:
            print(f"Could not find ActionCard boundaries in _PasswordTab: sbox={sbox}, end={end_action}")
    else:
        print("ActionCard in _PasswordTab is not temp password")
else:
    print("ActionCard in _PasswordTab not found")

# 8. Remove unused imports (pwdCtrl, countCtrl, dateRange)
# These are declared in _showCreateTempDialog which we removed

print(f"\nFinal file size: {len(data)} (removed {original_len - len(data)} chars)")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
