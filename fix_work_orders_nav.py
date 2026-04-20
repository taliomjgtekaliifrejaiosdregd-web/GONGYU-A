with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# 1. Add imports for new pages (after repair_manage_page.dart import)
import_line = "import 'package:gongyu_guanjia/pages/landlord/repair_manage_page.dart';"
new_imports = "import 'package:gongyu_guanjia/pages/landlord/termination_manage_page.dart';\nimport 'package:gongyu_guanjia/pages/landlord/contract_change_page.dart';"
if import_line in data and 'termination_manage_page.dart' not in data:
    data = data.replace(import_line, import_line + '\n' + new_imports)
    print("Added imports!")
else:
    print("Imports already present or anchor not found")

# 2. Fix the _buildWorkOrders method - add onTap to 退租申请
old_退租 = "_Work(Icons.exit_to_app, '退租申请', '3', AppColors.danger)"
new_退租 = "_Work(Icons.exit_to_app, '退租申请', '3', AppColors.danger, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminationManagePage())))"

if old_退租 in data:
    data = data.replace(old_退租, new_退租)
    print("Fixed 退租申请 navigation!")
else:
    print("WARNING: 退租申请 pattern not found")

# 3. Fix the _buildWorkOrders method - add onTap to 合同变更
old_合同 = "_Work(Icons.description, '合同变更', '2', AppColors.primary)"
new_合同 = "_Work(Icons.description, '合同变更', '2', AppColors.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContractChangePage())))"

if old_合同 in data:
    data = data.replace(old_合同, new_合同)
    print("Fixed 合同变更 navigation!")
else:
    print("WARNING: 合同变更 pattern not found")

print(f"File size: {len(data)}")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
