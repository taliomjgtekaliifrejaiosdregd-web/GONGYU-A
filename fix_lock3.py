with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

orig_len = len(data)
print(f"Original: {orig_len}")

# Remove ALL occurrences of 'required this.onCreateTemp,' and 'required this.onCreateTemp'
data = data.replace('required this.onCreateTemp,\n', '')
data = data.replace('required this.onCreateTemp}', 'required this.onChangePassword}')
data = data.replace(', required this.onCreateTemp', '')
print(f"After removing required this.onCreateTemp: {len(data)}")

# Remove ALL occurrences of 'onCreateTemp: onCreateTemp'
data = data.replace('onCreateTemp: onCreateTemp,\n', '')
data = data.replace('onCreateTemp: onCreateTemp}', '')
print(f"After removing onCreateTemp: onCreateTemp: {len(data)}")

# Remove ALL occurrences of 'final VoidCallback onCreateTemp;'
data = data.replace('final VoidCallback onCreateTemp;\n', '')
data = data.replace('final VoidCallback onCreateTemp;', '')
print(f"After removing VoidCallback onCreateTemp;: {len(data)}")

# Remove ALL remaining 'onCreateTemp' strings
while 'onCreateTemp' in data:
    before = len(data)
    data = data.replace('onCreateTemp', '')
    after = len(data)
    print(f"Removed onCreateTemp: {before} -> {after}")
    if before == after:
        break

# Remove ALL _ActionCard blocks for 临时密码
# These have: title: '临时密码' (or the garbled version)
# Pattern: the Expanded(_ActionCard) block with add_circle_outline and temp password
# We'll search for it using add_circle_outline
temp_cards_removed = 0
while True:
    # Find add_circle_outline in context
    idx = data.find('add_circle_outline')
    if idx < 0:
        break
    # Check context for temp password
    context = data[max(0,idx-300):idx+200]
    if ('临时密码' in context or 'F59E0B' in context) and 'onCreateTemp' not in context:
        # Check if it was removed already or needs removal
        # Find the SizedBox before and ]); after
        sbox = data.rfind('const SizedBox(width: 12)', max(0, idx-400), idx)
        end_action = data.find(']);', idx, idx+400)
        if sbox >= 0 and end_action >= 0:
            data = data[:sbox] + data[end_action+3:]
            temp_cards_removed += 1
            print(f"Removed temp password ActionCard #{temp_cards_removed}")
        else:
            # Just skip this one
            data = data[:idx+1] + data[idx+20:]
    else:
        break

print(f"After removing temp password ActionCards: {len(data)}")
print(f"Removed {orig_len - len(data)} total chars")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
