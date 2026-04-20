with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

orig_len = len(data)
print(f"Original size: {orig_len}")

# ======================================================
# 1. Add onTap to _Stat class
# ======================================================
# Old _Stat class definition
old_stat_def = """class _Stat extends StatelessWidget {
  final String label; final String v; final String u; final Color color;
  const _Stat(this.label, this.v, this.u, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), Text(u, style: TextStyle(fontSize: 11, color: color))]), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600))]))); }"""

new_stat_def = """class _Stat extends StatelessWidget {
  final String label; final String v; final String u; final Color color;
  final VoidCallback? onTap;
  const _Stat(this.label, this.v, this.u, this.color, {this.onTap});
  @override Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), Text(u, style: TextStyle(fontSize: 11, color: color))]), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600))])))); }"""

if old_stat_def in data:
    data = data.replace(old_stat_def, new_stat_def)
    print("Fixed _Stat class!")
else:
    print("WARNING: _Stat pattern not found")

# ======================================================
# 2. Add onTap to _Mini class
# ======================================================
old_mini_def = """class _Mini extends StatelessWidget {
  final String label; final String v; final Color? color;
  const _Mini(this.label, this.v, [this.color]);
  @override Widget build(BuildContext context) => Column(children: [Text(v, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color ?? AppColors.primary)), Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600))]); }"""

new_mini_def = """class _Mini extends StatelessWidget {
  final String label; final String v; final Color? color;
  final VoidCallback? onTap;
  const _Mini(this.label, this.v, [this.color, this.onTap]);
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Column(children: [Text(v, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color ?? AppColors.primary)), Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600))])); }"""

if old_mini_def in data:
    data = data.replace(old_mini_def, new_mini_def)
    print("Fixed _Mini class!")
else:
    print("WARNING: _Mini pattern not found")

# ======================================================
# 3. Update _buildDashboard() to pass onTap callbacks
# ======================================================
old_dashboard = """  Widget _buildDashboard() => SliverToBoxAdapter(child: _Card(
    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
    title: '数据看板',
    child: Column(children: [
      Row(children: [_Stat('近30日合同即将到期', '5', '户', AppColors.warning), const SizedBox(width: 8), _Stat('合同逾期数量', '2', '户', AppColors.danger)]),
      const SizedBox(height: 10),
      Row(children: [_Stat('近30日待收金额', '12.8', '万元', AppColors.success), const SizedBox(width: 8), _Stat('其中逾期', '0.3', '万元', AppColors.danger)]),
      const Divider(height: 24),
      Row(children: [Expanded(child: _Mini('全部房源', '24户')), Expanded(child: _Mini('已租', '18户', AppColors.success)), Expanded(child: _Mini('空置', '6户', AppColors.warning))]),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: _Mini('出租率', '75%')), Expanded(child: _Mini('续签率', '82%')), Expanded(child: _Mini('收房均价', '4200元/月'))]),
    ]),
  ));"""

new_dashboard = """  Widget _buildDashboard() => SliverToBoxAdapter(child: _Card(
    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
    title: '数据看板',
    child: Column(children: [
      Row(children: [_Stat('近30日合同即将到期', '5', '户', AppColors.warning, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordContractPage()))), const SizedBox(width: 8), _Stat('合同逾期数量', '2', '户', AppColors.danger, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordContractPage())))]),
      const SizedBox(height: 10),
      Row(children: [_Stat('近30日待收金额', '12.8', '万元', AppColors.success, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordBillPage()))), const SizedBox(width: 8), _Stat('其中逾期', '0.3', '万元', AppColors.danger, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordBillPage())))]),
      const Divider(height: 24),
      Row(children: [Expanded(child: _Mini('全部房源', '24户', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordPropertyPage())))), Expanded(child: _Mini('已租', '18户', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordPropertyPage())))), Expanded(child: _Mini('空置', '6户', AppColors.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordPropertyPage()))))]),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: _Mini('出租率', '75%', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordStatsPage())))), Expanded(child: _Mini('续签率', '82%', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordStatsPage())))), Expanded(child: _Mini('收房均价', '4200元/月', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordStatsPage()))))]),
    ]),
  ));"""

if old_dashboard in data:
    data = data.replace(old_dashboard, new_dashboard)
    print("Fixed _buildDashboard()!")
else:
    print("WARNING: _buildDashboard pattern not found")

# ======================================================
# 4. Add missing imports
# ======================================================
imports_to_add = [
    "import 'package:gongyu_guanjia/pages/landlord/landlord_bill_page.dart';",
    "import 'package:gongyu_guanjia/pages/landlord/landlord_stats_page.dart';",
]

for imp in imports_to_add:
    if imp not in data:
        # Add after landlord_contract_page import
        data = data.replace(
            "import 'package:gongyu_guanjia/pages/landlord/landlord_contract_page.dart';",
            "import 'package:gongyu_guanjia/pages/landlord/landlord_contract_page.dart';\n" + imp
        )
        print(f"Added import: {imp}")

print(f"Final size: {len(data)} (delta: {len(data)-orig_len:+d})")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
