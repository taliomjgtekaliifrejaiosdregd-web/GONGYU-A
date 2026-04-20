with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_property_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

orig_len = len(data)

# ======================================================
# 1. Add imports for new pages
# ======================================================
imports_to_add = [
    "import 'package:gongyu_guanjia/pages/landlord/property_edit_page.dart';",
    "import 'package:gongyu_guanjia/pages/landlord/room_contract_page.dart';",
    "import 'package:gongyu_guanjia/pages/landlord/property_stats_page.dart';",
]
for imp in imports_to_add:
    if imp not in data:
        data = data.replace(
            "import 'package:gongyu_guanjia/pages/landlord/landlord_property_page.dart';",
            "import 'package:gongyu_guanjia/pages/landlord/landlord_property_page.dart';\n" + imp
        )
        print(f"Added: {imp}")
    else:
        print(f"Already imported: {imp}")

# ======================================================
# 2. Fix button 1: 编辑
# ======================================================
old_edit = "GestureDetector(onTap: () {}, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit, size: 16, color: AppColors.primary), SizedBox(width: 4), Text('编辑', style: TextStyle(fontSize: 12, color: AppColors.primary))])))"
new_edit = "GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyEditPage(room: r))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit, size: 16, color: AppColors.primary), SizedBox(width: 4), Text('编辑', style: TextStyle(fontSize: 12, color: AppColors.primary))])))"

if old_edit in data:
    data = data.replace(old_edit, new_edit)
    print("Fixed 编辑 button!")
else:
    print("WARNING: 编辑 pattern not found")

# ======================================================
# 3. Fix button 2: 合同
# ======================================================
old_contract = "GestureDetector(onTap: () {}, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.description, size: 16, color: AppColors.primary), SizedBox(width: 4), Text('合同', style: TextStyle(fontSize: 12, color: AppColors.primary))])))"
new_contract = "GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomContractPage(room: r))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.description, size: 16, color: AppColors.primary), SizedBox(width: 4), Text('合同', style: TextStyle(fontSize: 12, color: AppColors.primary))])))"

if old_contract in data:
    data = data.replace(old_contract, new_contract)
    print("Fixed 合同 button!")
else:
    print("WARNING: 合同 pattern not found")

# ======================================================
# 4. Fix button 3: 统计
# ======================================================
old_stats = "GestureDetector(onTap: () {}, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bar_chart, size: 16, color: AppColors.primary), SizedBox(width: 4), Text('统计', style: TextStyle(fontSize: 12, color: AppColors.primary))])))"
new_stats = "GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyStatsPage(room: r))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bar_chart, size: 16, color: AppColors.primary), SizedBox(width: 4), Text('统计', style: TextStyle(fontSize: 12, color: AppColors.primary))])))"

if old_stats in data:
    data = data.replace(old_stats, new_stats)
    print("Fixed 统计 button!")
else:
    print("WARNING: 统计 pattern not found")

print(f"\nFinal size: {len(data)} (delta: {len(data)-orig_len:+d})")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_property_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
