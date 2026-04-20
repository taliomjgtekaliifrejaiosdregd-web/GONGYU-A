with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find exact byte positions of the _Work items we need to fix
# _Work(Icons.exit_to_app, '...', '3', AppColors.danger),
# This is the one WITHOUT onTap - need to add onTap
# Pattern: ends with , AppColors.danger),\n

# Search for pattern: ends with , AppColors.danger), followed by \n
idx = data.find(", AppColors.danger),\n      _Work")
if idx >= 0:
    print(f"Found at {idx}: {repr(data[idx:idx+60])}")
    # The full _Work call is from earlier in the line
    line_start = data.rfind('\n', 0, idx) + 1
    line_end = data.find(',', idx) + 1  # find the comma after danger
    # Actually the whole line goes to the closing paren
    full_line_start = data.rfind('      _Work', line_start-100, idx)
    print(f"Full line from {full_line_start}: {repr(data[full_line_start:line_end+10])}")
    
    # Replace the whole _Work line for 退租申请
    old_line = data[full_line_start:line_end+10]
    # Find where the line ends
    line_end_pos = data.find('\n', full_line_start)
    old_line = data[full_line_start:line_end_pos]
    print(f"Old line: {repr(old_line)}")
    
    # Replace with navigation version
    # The closing part is: AppColors.danger), -> needs to be: AppColors.danger, onTap: ...),
    new_line = old_line.replace(
        old_line[old_line.rfind(','):],
        ", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminationManagePage()))),"
    )
    # Actually the last part is ", AppColors.danger)," -> replace with same end pattern + onTap
    new_line = old_line.rpartition("AppColors.danger),")[0] + "AppColors.danger, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminationManagePage()))),"
    print(f"New line: {repr(new_line)}")
    data = data.replace(old_line, new_line)
    print("Fixed 退租申请!")
else:
    print("Pattern not found, trying alternative")
    # Alternative: find "AppColors.danger)," that's followed by newline and _Work
    idx2 = data.find("AppColors.danger),\n")
    print(f"Found at {idx2}")
    if idx2 >= 0:
        line_start2 = data.rfind('\n', 0, idx2) + 1
        old_line2 = data[line_start2:idx2+len("AppColors.danger),")]
        print(f"Old line 2: {repr(old_line2)}")
        new_line2 = old_line2.replace("AppColors.danger),", "AppColors.danger, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminationManagePage()))),")
        data = data.replace(old_line2, new_line2)
        print("Fixed via alternative!")
    else:
        print("Still not found!")

# Now fix 合同变更 - it has AppColors.primary) at end
# Find: AppColors.primary),\n
idx3 = data.find("AppColors.primary),\n")
if idx3 >= 0:
    line_start3 = data.rfind('\n', 0, idx3) + 1
    old_line3 = data[line_start3:idx3+len("AppColors.primary),")]
    print(f"Old line3: {repr(old_line3)}")
    new_line3 = old_line3.replace("AppColors.primary),", "AppColors.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContractChangePage()))),")
    data = data.replace(old_line3, new_line3)
    print("Fixed 合同变更!")
else:
    print("合同变更 pattern not found!")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
