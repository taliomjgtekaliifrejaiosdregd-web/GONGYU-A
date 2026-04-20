with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

orig_len = len(data)

# ======================================================
# 1. Add onTap to _Stat class definition
# ======================================================
# Find _Stat class and replace
idx_stat = data.find('class _Stat extends StatelessWidget')
if idx_stat >= 0:
    end_stat = data.find('}', idx_stat + 10)
    old_stat = data[idx_stat:end_stat+1]
    new_stat = """class _Stat extends StatelessWidget {
  final String label; final String v; final String u; final Color color;
  final VoidCallback? onTap;
  const _Stat(this.label, this.v, this.u, this.color, {this.onTap});
  @override Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), Text(u, style: TextStyle(fontSize: 11, color: color))]), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600))])))); }"""
    data = data[:idx_stat] + new_stat + data[end_stat+1:]
    print("Fixed _Stat class!")
else:
    print("WARNING: _Stat class not found")

# ======================================================
# 2. Add onTap to _Mini class definition
# ======================================================
idx_mini = data.find('class _Mini extends StatelessWidget')
if idx_mini >= 0:
    end_mini = data.find('}', idx_mini + 10)
    old_mini = data[idx_mini:end_mini+1]
    new_mini = """class _Mini extends StatelessWidget {
  final String label; final String v; final Color? color;
  final VoidCallback? onTap;
  const _Mini(this.label, this.v, [this.color, this.onTap]);
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Column(children: [Text(v, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color ?? AppColors.primary)), Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600))])); }"""
    data = data[:idx_mini] + new_mini + data[end_mini+1:]
    print("Fixed _Mini class!")
else:
    print("WARNING: _Mini class not found")

# ======================================================
# 3. Update _buildDashboard() _Stat calls
# ======================================================
dashboard_changes = [
    # (old, new)
    ("_Stat('近30日合同即将到期', '5', '户', AppColors.warning)",
     "_Stat('近30日合同即将到期', '5', '户', AppColors.warning, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordContractPage())))"),
    ("_Stat('合同逾期数量', '2', '户', AppColors.danger)",
     "_Stat('合同逾期数量', '2', '户', AppColors.danger, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordContractPage())))"),
    ("_Stat('近30日待收金额', '12.8', '万元', AppColors.success)",
     "_Stat('近30日待收金额', '12.8', '万元', AppColors.success, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordBillPage())))"),
    ("_Stat('其中逾期', '0.3', '万元', AppColors.danger)",
     "_Stat('其中逾期', '0.3', '万元', AppColors.danger, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordBillPage())))"),
]

for old, new in dashboard_changes:
    if old in data:
        data = data.replace(old, new)
        print(f"Fixed: {old[:40]}...")
    else:
        print(f"WARNING: not found: {old[:40]}")

# ======================================================
# 4. Update _buildDashboard() _Mini calls
# ======================================================
mini_changes = [
    # (old, new)
    ("_Mini('全部房源', '24户')",
     "_Mini('全部房源', '24户', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordPropertyPage())))"),
    ("_Mini('已租', '18户', AppColors.success)",
     "_Mini('已租', '18户', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordPropertyPage())))"),
    ("_Mini('空置', '6户', AppColors.warning)",
     "_Mini('空置', '6户', AppColors.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordPropertyPage())))"),
    ("_Mini('出租率', '75%')",
     "_Mini('出租率', '75%', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordStatsPage())))"),
    ("_Mini('续签率', '82%')",
     "_Mini('续签率', '82%', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordStatsPage())))"),
    ("_Mini('收房均价', '4200元/月')",
     "_Mini('收房均价', '4200元/月', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordStatsPage())))"),
]

for old, new in mini_changes:
    if old in data:
        data = data.replace(old, new)
        print(f"Fixed: {old[:40]}...")
    else:
        print(f"WARNING: not found: {old[:40]}")

# ======================================================
# 5. Add missing imports
# ======================================================
imports_to_add = [
    "import 'package:gongyu_guanjia/pages/landlord/landlord_bill_page.dart';",
    "import 'package:gongyu_guanjia/pages/landlord/landlord_stats_page.dart';",
]

for imp in imports_to_add:
    if imp not in data:
        data = data.replace(
            "import 'package:gongyu_guanjia/pages/landlord/landlord_contract_page.dart';",
            "import 'package:gongyu_guanjia/pages/landlord/landlord_contract_page.dart';\n" + imp
        )
        print(f"Added import: {imp}")
    else:
        print(f"Already imported: {imp}")

print(f"\nFinal size: {len(data)} (delta: {len(data)-orig_len:+d})")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
