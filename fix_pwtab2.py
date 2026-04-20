with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Fix: line 912 ends with ')),' (closes Expanded and ActionCard)
# But we need to close the Row too
# Change: 'color: ..., onTap: onChangePassword)),\n        ]);' -> 'color: ..., onTap: onChangePassword)),\n        ]);' (already has ]);)
# The issue is the ), at the end closes Expanded but there IS no ], to close Row's children
# After fix_pwtab.py: line 912 ends with ')),' and line 913 is ']);'
# But the Row has only one child, so we need:
# '));'  ← closes Expanded
# ']);'  ← ] closes Row.children, ) closes Row

# Check if the issue is different - maybe the Row was never opened
# Let me look at the context again
idx = data.find('Row(children: [')
in_pwtab = data.find('class _PasswordTab')
if data.find('Row(children: [') > in_pwtab:
    print("Row found in _PasswordTab")
    sub = data[in_pwtab:in_pwtab+5000]
    idx2 = sub.find('Row(children: [')
    if idx2 >= 0:
        print("Row context:", repr(sub[idx2:idx2+400]))

# The issue: line 912 ends with ')),' and line 913 is ']);'
# This means: Expanded closes (one )), and then ]); which is ]); for Row
# But there might not be a proper Row(children: [ opening
# Let me check if Row(children: [ is properly opened
pwtab_start = data.find('class _PasswordTab')
pwtab = data[pwtab_start:pwtab_start+5000]
row_idx = pwtab.find('Row(children: [')
print(f"Row(children: [ at: {row_idx} in _PasswordTab")
if row_idx >= 0:
    print(repr(pwtab[row_idx:row_idx+300]))
