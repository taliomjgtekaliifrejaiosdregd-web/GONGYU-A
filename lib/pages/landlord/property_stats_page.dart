import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/room.dart';
import 'package:gongyu_guanjia/models/contract.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

// ============================================================
// 房源统计页
// ============================================================
class PropertyStatsPage extends StatefulWidget {
  final Room room;
  const PropertyStatsPage({super.key, required this.room});

  @override
  State<PropertyStatsPage> createState() => _PropertyStatsPageState();
}

class _PropertyStatsPageState extends State<PropertyStatsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 模拟收入数据
  final List<_IncomeData> _monthlyIncome = [
    _IncomeData('2024-01', 5800, 5800, 0),
    _IncomeData('2024-02', 5800, 5800, 0),
    _IncomeData('2024-03', 5800, 5800, 0),
    _IncomeData('2024-04', 5800, 5800, 0),
    _IncomeData('2024-05', 5800, 5800, 0),
    _IncomeData('2024-06', 5800, 5800, 0),
    _IncomeData('2024-07', 5800, 5800, 0),
    _IncomeData('2024-08', 5800, 5800, 0),
    _IncomeData('2024-09', 5800, 5800, 0),
    _IncomeData('2024-10', 5800, 5800, 0),
    _IncomeData('2024-11', 5800, 5800, 0),
    _IncomeData('2024-12', 5800, 5800, 0),
    _IncomeData('2025-01', 5800, 5800, 0),
    _IncomeData('2025-02', 5800, 5800, 0),
    _IncomeData('2025-03', 5800, 5800, 0),
  ];

  // 模拟账单数据
  final List<_BillData> _bills = [
    _BillData('2025-03', '租金', 5800, true),
    _BillData('2025-02', '租金', 5800, true),
    _BillData('2025-01', '租金', 5800, true),
    _BillData('2024-12', '租金', 5800, true),
    _BillData('2024-11', '水费', 120, true),
    _BillData('2024-11', '电费', 280, true),
    _BillData('2024-11', '租金', 5800, true),
  ];

  double get _totalIncome => _bills.where((b) => b.isIncome).fold(0.0, (s, b) => s + b.amount);
  double get _totalExpense => _bills.where((b) => !b.isIncome).fold(0.0, (s, b) => s + b.amount);
  double get _avgMonthlyIncome => _totalIncome / _monthlyIncome.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(children: [
          const Text('房源统计', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
          Text(widget.room.title, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ]),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '收入概览'),
            Tab(text: '账单明细'),
            Tab(text: '租客分析'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _IncomeOverviewTab(room: widget.room, monthlyIncome: _monthlyIncome, avgMonthlyIncome: _avgMonthlyIncome, totalIncome: _totalIncome),
          _BillDetailTab(bills: _bills, totalIncome: _totalIncome, totalExpense: _totalExpense),
          _TenantAnalysisTab(room: widget.room),
        ],
      ),
    );
  }
}

class _IncomeOverviewTab extends StatelessWidget {
  final Room room;
  final List<_IncomeData> monthlyIncome;
  final double avgMonthlyIncome;
  final double totalIncome;

  const _IncomeOverviewTab({
    required this.room,
    required this.monthlyIncome,
    required this.avgMonthlyIncome,
    required this.totalIncome,
  });

  @override
  Widget build(BuildContext context) {
    final maxIncome = monthlyIncome.map((d) => d.rent).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        // 总览卡片
        Row(children: [
          Expanded(child: _MiniStatCard(
            label: '累计收入',
            value: '¥${totalIncome.toStringAsFixed(0)}',
            color: const Color(0xFF10B981),
            icon: Icons.account_balance_wallet,
          )),
          const SizedBox(width: 8),
          Expanded(child: _MiniStatCard(
            label: '月均收入',
            value: '¥${avgMonthlyIncome.toStringAsFixed(0)}',
            color: const Color(0xFF6366F1),
            icon: Icons.trending_up,
          )),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _MiniStatCard(
            label: '出租率',
            value: room.isAvailable ? '未出租' : '100%',
            color: room.isAvailable ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
            icon: Icons.home,
          )),
          const SizedBox(width: 8),
          Expanded(child: _MiniStatCard(
            label: '当前租金',
            value: '¥${room.price.toStringAsFixed(0)}/月',
            color: AppColors.primary,
            icon: Icons.payments,
          )),
        ]),

        const SizedBox(height: 16),

        // 近15月收入趋势
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('近15月收入趋势', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(children: [
                Expanded(child: _BarChart(
                  data: monthlyIncome,
                  maxValue: maxIncome,
                  color: const Color(0xFF6366F1),
                )),
              ]),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: monthlyIncome.map((d) => Text(d.month.substring(5), style: TextStyle(fontSize: 8, color: Colors.grey.shade500))).toList()),
          ]),
        ),

        const SizedBox(height: 12),

        // 收支趋势
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('收支对比', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _TrendRow('租金收入', totalIncome, const Color(0xFF10B981)),
            const SizedBox(height: 12),
            _TrendRow('其他收入', totalIncome * 0.05, const Color(0xFF6366F1)),
            const SizedBox(height: 12),
            _TrendRow('运营成本', totalIncome * 0.15, const Color(0xFFEF4444)),
          ]),
        ),
      ]),
    );
  }
}

class _BillDetailTab extends StatelessWidget {
  final List<_BillData> bills;
  final double totalIncome;
  final double totalExpense;

  const _BillDetailTab({required this.bills, required this.totalIncome, required this.totalExpense});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        // 汇总
        Row(children: [
          Expanded(child: _MiniStatCard(label: '收入合计', value: '¥${totalIncome.toStringAsFixed(0)}', color: const Color(0xFF10B981), icon: Icons.arrow_downward)),
          const SizedBox(width: 8),
          Expanded(child: _MiniStatCard(label: '支出合计', value: '¥${totalExpense.toStringAsFixed(0)}', color: const Color(0xFFEF4444), icon: Icons.arrow_upward)),
          const SizedBox(width: 8),
          Expanded(child: _MiniStatCard(label: '净收益', value: '¥${(totalIncome - totalExpense).toStringAsFixed(0)}', color: const Color(0xFF6366F1), icon: Icons.show_chart)),
        ]),
        const SizedBox(height: 16),

        // 账单列表
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: bills.asMap().entries.map((e) {
              final idx = e.key;
              final bill = e.value;
              final isLast = idx == bills.length - 1;
              return Column(children: [
                ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: (bill.isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      bill.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: bill.isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  title: Text(bill.type, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(bill.month, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  trailing: Text(
                    '${bill.isIncome ? '+' : '-'}¥${bill.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: bill.isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  ),
                ),
                if (!isLast) const Divider(height: 1, indent: 70),
              ]);
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

class _TenantAnalysisTab extends StatelessWidget {
  final Room room;
  const _TenantAnalysisTab({required this.room});

  @override
  Widget build(BuildContext context) {
    final contract = MockService.contracts.where((c) => c.roomId == room.id).firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        // 租客信息
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(contract?.tenantName ?? '暂无租客', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(contract?.tenantPhone ?? '—', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ]),
              ])),
              if (contract != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('租客', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                ),
            ]),
            if (contract != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _StatTile('入住日期', contract.startDate.year == 2024 ? '2024-01-01' : '未知', Icons.calendar_today)),
                Expanded(child: _StatTile('合同到期', '${contract.daysToExpire}天后', Icons.event)),
                Expanded(child: _StatTile('租金', '¥${contract.rentAmount}/月', Icons.payments)),
              ]),
            ],
          ]),
        ),

        const SizedBox(height: 12),

        // 租客行为分析
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('租客行为分析', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _BehaviorItem(icon: Icons.payment, label: '缴费及时率', value: '98%', color: const Color(0xFF10B981))),
              const SizedBox(width: 8),
              Expanded(child: _BehaviorItem(icon: Icons.autorenew, label: '续租意愿', value: '高', color: const Color(0xFF6366F1))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _BehaviorItem(icon: Icons.report_problem, label: '报修次数', value: '2次', color: const Color(0xFFF59E0B))),
              const SizedBox(width: 8),
              Expanded(child: _BehaviorItem(icon: Icons.star, label: '综合评分', value: '4.8分', color: const Color(0xFFEF4444))),
            ]),
          ]),
        ),

        const SizedBox(height: 12),

        // 风险提示
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(children: [
            const Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 24),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('风险提示', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
              const SizedBox(height: 4),
              Text('当前租客合同即将到期，建议提前30天联系确认续租意向。', style: TextStyle(fontSize: 11, color: Colors.orange.shade700)),
            ])),
          ]),
        ),
      ]),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _MiniStatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ]),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    ]),
  );
}

class _BarChart extends StatelessWidget {
  final List<_IncomeData> data;
  final double maxValue;
  final Color color;
  const _BarChart({required this.data, required this.maxValue, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: data.map((d) {
      final height = maxValue > 0 ? (d.rent / maxValue * 100) : 0.0;
      return Expanded(child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        height: height.clamp(4, 120),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ));
    }).toList(),
  );
}

class _TrendRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _TrendRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    final pct = value > 0 ? (value / value * 100).clamp(0, 100) : 0.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text('¥${value.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ]),
      const SizedBox(height: 6),
      Container(
        height: 6,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: (value / (value * 1.2)).clamp(0, 1),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatTile(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, size: 18, color: Colors.grey.shade400),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
  ]);
}

class _BehaviorItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _BehaviorItem({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
    ]),
  );
}

// ============ 数据模型 ============
class _IncomeData {
  final String month;
  final double rent;
  final double received;
  final double overdue;
  _IncomeData(this.month, this.rent, this.received, this.overdue);
}

class _BillData {
  final String month;
  final String type;
  final double amount;
  final bool isIncome;
  _BillData(this.month, this.type, this.amount, this.isIncome);
}
