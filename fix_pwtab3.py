with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find _PasswordTab build method
pwtab_idx = data.find('class _PasswordTab')
pwtab_end = data.find('class _Stat', pwtab_idx)

# Extract _PasswordTab
pwtab = data[pwtab_idx:pwtab_end]

# Check structure
print("Opening _PasswordTab:")
print(pwtab[:200])

# Find the problematic Row #2
row2_idx = pwtab.find('Row(children: [\n          Expanded(child: _ActionCard(')
print("\nRow #2 at:", row2_idx)
print(pwtab[row2_idx:row2_idx+500])
