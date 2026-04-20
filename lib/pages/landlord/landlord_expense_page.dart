import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

/// 费用类型
enum ExpenseType {
  property('物业费', Icons.home, Color(0xFF6366F1)),
  repair('维修费', Icons.build, Color(0xFFF59E0B)),
  electricity('电费', Icons.electric_bolt, Color(0xFFEF4444)),
  water('水费', Icons.water_drop, Color(0xFF06B6D4)),
  gas('燃气费', Icons.local_fire_department, Color(0xFFEC4899)),
  other('其他', Icons.more_horiz, Color(0xFF9E9E9E));

  final String label;
  final IconData icon;
  final Color color;
  const ExpenseType(this.label, this.icon, this.color);
}

/// 支出记录
class Expense {
  final String id;
  final ExpenseType type;
  final String title;
  final String? roomTitle;
  final double amount;
  final String date;
  final String? remark;

  const Expense({
    required this.id,
    required this.type,
    required this.title,
    this.roomTitle,
    required this.amount,
    required this.date,
    this.remark,
  });
}

/// ============================================================
// 房东端 - 费用管理（支出记录）
// ============================================================
class LandlordExpensePage extends StatefulWidget {
  const LandlordExpensePage({super.key});

  @override
  State<LandlordExpensePage> createState() => _LandlordExpensePageState();
}

class _LandlordExpensePageState extends State<LandlordExpensePage> {
  ExpenseType? _filterType;
  String _selectedPeriod = '2026-04';

  // Mock支出数据
  final List<Expense> _expenses = [
    const Expense(id: 'E001', type: ExpenseType.repair, title: '门锁维修', roomTitle: '陆家嘴花园整租', amount: 350, date: '2026-04-14', remark: '更换门锁面板'),
    const Expense(id: 'E002', type: ExpenseType.repair, title: '水表维修', roomTitle: '静安寺独栋', amount: 200, date: '2026-04-13', remark: '更换水表传感器'),
    const Expense(id: 'E003', type: ExpenseType.property, title: '物业费', roomTitle: '静安寺独栋', amount: 2000, date: '2026-04-12'),
    const Expense(id: 'E004', type: ExpenseType.repair, title: '电表维修', roomTitle: '徐家汇精品公寓', amount: 150, date: '2026-04-07', remark: '电表显示屏更换'),
    const Expense(id: 'E005', type: ExpenseType.repair, title: '门锁维修', roomTitle: '陆家嘴花园整租', amount: 80, date: '2026-04-05', remark: '门锁电池更换'),
    const Expense(id: 'E006', type: ExpenseType.water, title: '水费', roomTitle: '静安寺独栋', amount: 70, date: '2026-04-01'),
    const Expense(id: 'E007', type: ExpenseType.electricity, title: '电费', roomTitle: '静安寺独栋', amount: 270, date: '2026-04-01'),
    const Expense(id: 'E008', type: ExpenseType.repair, title: '管道疏通', roomTitle: '浦东大道合租', amount: 180, date: '2026-03-28', remark: '厨房下水道疏通'),
  ];

  List<Expense> get _filtered {
    var list = _expenses.where((e) => e.date.startsWith(_selectedPeriod)).toList();
    if (_filterType != null) list = list.where((e) => e.type == _filterType).toList();
    return list;
  }

  double get _monthTotal => _expenses
      .where((e) => e.date.startsWith(_selectedPeriod))
      .fold(0.0, (s, e) => s + e.amount);

  double get _filterTotal => _filtered.fold(0.0, (s, e) => s + e.amount);

  @override
  Widget build(BuildContext context) {
    final typeTotal = (ExpenseType t) => _expenses
        .where((e) => e.date.startsWith(_selectedPeriod) && e.type == t)
        .fold(0.0, (s, e) => s + e.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('费用管理', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _showAddExpense(context),
          ),
        ],
      ),
      body: Column(children: [
        // 账期选择
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Row(children: [
            const Text('账期：', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 8),
            _PeriodChip('2026-04', _selectedPeriod == '2026-04', () => setState(() => _selectedPeriod = '2026-04')),
            const SizedBox(width: 8),
            _PeriodChip('2026-03', _selectedPeriod == '2026-03', () => setState(() => _selectedPeriod = '2026-03')),
            const Spacer(),
            Text('支出 ¥${_monthTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
          ]),
        ),

        // 费用类型分布
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _TypeChip(
                type: null,
                selected: _filterType == null,
                label: '全部',
                amount: _monthTotal,
                onTap: () => setState(() => _filterType = null),
              ),
              ...ExpenseType.values.where((t) => typeTotal(t) > 0).map((t) => _TypeChip(
                type: t,
                selected: _filterType == t,
                label: t.label,
                amount: typeTotal(t),
                onTap: () => setState(() => _filterType = t),
              )),
            ],
          ),
        ),

        const Divider(height: 1),

        // 支出列表
        Expanded(
          child: _filtered.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('暂无支出记录', style: TextStyle(color: Colors.grey.shade500)),
                ]))
              : Column(children: [
                  // 小计
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    color: const Color(0xFFF5F5F5),
                    child: Row(children: [
                      Text(_filterType != null ? _filterType!.label : '全部支出', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                      const Spacer(),
                      Text('¥${_filterTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                    ]),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _ExpenseCard(
                        expense: _filtered[i],
                        onTap: () => _showExpenseDetail(context, _filtered[i]),
                        onDelete: () {
                          setState(() => _expenses.removeWhere((e) => e.id == _filtered[i].id));
                        },
                      ),
                    ),
                  ),
                ]),
        ),
      ]),
    );
  }

  void _showAddExpense(BuildContext context) {
    ExpenseType _selType = ExpenseType.repair;
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('新增支出', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('费用类型', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: ExpenseType.values.map((t) => GestureDetector(
              onTap: () => setSheetState(() => _selType = t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _selType == t ? t.color.withOpacity(0.1) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _selType == t ? t.color : Colors.transparent),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(t.icon, size: 14, color: _selType == t ? t.color : Colors.grey),
                  const SizedBox(width: 4),
                  Text(t.label, style: TextStyle(fontSize: 12, color: _selType == t ? t.color : Colors.black87)),
                ]),
              ),
            )).toList()),
            const SizedBox(height: 16),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '金额（元）', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: '备注（选填）', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountCtrl.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('请输入正确金额'), behavior: SnackBarBehavior.floating));
                    return;
                  }
                  setState(() {
                    _expenses.insert(0, Expense(
                      id: 'E${DateTime.now().millisecondsSinceEpoch}',
                      type: _selType,
                      title: _selType.label,
                      amount: amount,
                      date: DateTime.now().toIso8601String().substring(0, 10),
                      remark: descCtrl.text.isNotEmpty ? descCtrl.text : null,
                    ));
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('支出记录已添加'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                child: const Text('保存', style: TextStyle(color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showExpenseDetail(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: expense.type.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(expense.type.icon, color: expense.type.color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(expense.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(expense.type.label, style: TextStyle(fontSize: 12, color: expense.type.color)),
            ])),
            Text('¥${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 16),
          _DetailRow('日期', expense.date),
          if (expense.roomTitle != null) _DetailRow('房源', expense.roomTitle!),
          if (expense.remark != null) _DetailRow('备注', expense.remark!),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodChip(this.label, this.selected, this.onTap);
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: selected ? Colors.white : Colors.black87)),
    ),
  );
}

class _TypeChip extends StatelessWidget {
  final ExpenseType? type;
  final bool selected;
  final String label;
  final double amount;
  final VoidCallback onTap;
  const _TypeChip({this.type, required this.selected, required this.label, required this.amount, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? (type?.color ?? AppColors.primary).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? (type?.color ?? AppColors.primary) : const Color(0xFFE0E0E0)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (type != null) ...[
            Icon(type!.icon, size: 14, color: type!.color),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: 12, color: selected ? (type?.color ?? AppColors.primary) : Colors.black87)),
        ]),
        const SizedBox(height: 4),
        Text('¥${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: type?.color ?? AppColors.primary)),
      ]),
    ),
  );
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _ExpenseCard({required this.expense, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: expense.type.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(expense.type.icon, color: expense.type.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(expense.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(expense.roomTitle ?? expense.type.label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('-¥${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
            Text(expense.date, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
          ]),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
    ]),
  );
}
