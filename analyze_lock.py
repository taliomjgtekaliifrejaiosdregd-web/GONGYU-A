with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find UnlockTab onCreateTemp ref
idx = data.find('onCreateTemp,', 8000)
print('UnlockTab onCreateTemp ref at:', idx)
start = data.rfind('const SizedBox(width: 12)', max(0, idx-400), idx)
print('Start (SizedBox before):', start)
print('Content:', repr(data[start:idx+80]))
end_paren = data.find(']);', idx, idx+200)
print('End (]);):', end_paren)
print('Content:', repr(data[idx-20:end_paren+5]))

print()
print('=== PasswordTab ===')
idx2 = data.find('onCreateTemp,', idx+100)
print('PasswordTab onCreateTemp ref at:', idx2)
start2 = data.rfind('const SizedBox(width: 12)', max(0, idx2-400), idx2)
print('Start:', start2)
print('Content:', repr(data[start2:idx2+80]))
end_paren2 = data.find(']);', idx2, idx2+200)
print('End:', end_paren2)

print()
print('=== _showCreateTempDialog boundaries ===')
# Find method definition
method_idx = data.find('void _showCreateTempDialog()')
print('Method starts at:', method_idx)
if method_idx >= 0:
    # Find end of method - look for next method or end of class
    next_method = data.find('String _fmt', method_idx)
    print('Method ends before:', next_method)
    if next_method >= 0:
        print('Method body:', repr(data[method_idx:next_method]))
