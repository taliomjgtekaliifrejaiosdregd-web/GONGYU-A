import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

/// ============================================================
// 房东端 - 数据统计
/// ============================================================
class LandlordStatsPage extends StatefulWidget {
  const LandlordStatsPage({super.key});

  @override
  State<LandlordStatsPage> createState() => _LandlordStatsPageState();
}

class _LandlordStatsPageState extends State<LandlordStatsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  // Mock数据
  final List<_ChartData> _monthlyRevenue = [
    _ChartData('10月', 98000, 82000),
    _ChartData('11月', 105000, 88000),
    _ChartData('12月', 112000, 94000),
    _ChartData('01月', 108000, 90000),
    _ChartData('02月', 115000, 96000),
    _ChartData('03月', 128000, 105000),
    _ChartData('04月', 128600, 103920),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() => _currentTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('数据统计', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF9E9E9E),
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '营收'),
            Tab(text: '房源'),
            Tab(text: '租客'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRevenueTab(),
          _buildPropertyTab(),
          _buildTenantTab(),
        ],
      ),
    );
  }

  Widget _buildRevenueTab() {
    final maxVal = _monthlyRevenue.map((d) => d.total).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 汇总卡片
        Row(children: [
          Expanded(child: _SummaryCard('本月收入', '¥128,600', const Color(0xFF10B981), Icons.arrow_downward)),
          const SizedBox(width: 8),
          Expanded(child: _SummaryCard('本月支出', '¥103,920', const Color(0xFFEF4444), Icons.arrow_upward)),
          const SizedBox(width: 8),
          Expanded(child: _SummaryCard('净收益', '¥24,680', const Color(0xFF6366F1), Icons.trending_up)),
        ]),
        const SizedBox(height: 16),

        // 柱状图
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('近6月营收趋势', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              _Legend('收入', const Color(0xFF10B981)),
              const SizedBox(width: 16),
              _Legend('支出', const Color(0xFFEF4444)),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _monthlyRevenue.skip(1).take(6).map((d) {
                  final totalH = (d.total / maxVal * 140).clamp(20.0, 140.0);
                  final expenseH = (d.expense / maxVal * 140).clamp(10.0, 140.0);
                  return Expanded(child: _BarColumn(d.label, totalH, expenseH));
                }).toList(),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),

        // 分类统计
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('收入分类', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _PieRow('租金收入', 5800 * 18, 128600, const Color(0xFF6366F1)),
            _PieRow('水费收入', 2800, 128600, const Color(0xFF06B6D4)),
            _PieRow('电费收入', 4200, 128600, const Color(0xFFF59E0B)),
            _PieRow('押金收入', 12000, 128600, const Color(0xFF10B981)),
            _PieRow('其他收入', 3200, 128600, const Color(0xFF9C27B0)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPropertyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(children: [
          Expanded(child: _MiniStatCard('全部房源', '24', '户', AppColors.primary)),
          const SizedBox(width: 8),
          Expanded(child: _MiniStatCard('已出租', '18', '户', const Color(0xFF10B981))),
          const SizedBox(width: 8),
          Expanded(child: _MiniStatCard('空置', '6', '户', const Color(0xFFF59E0B))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _MiniStatCard('出租率', '75', '%', AppColors.primary)),
          const SizedBox(width: 8),
          Expanded(child: _MiniStatCard('续签率', '82', '%', const Color(0xFF10B981))),
          const SizedBox(width: 8),
          Expanded(child: _MiniStatCard('平均租期', '8.5', '月', const Color(0xFF6366F1))),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('各小区房源数', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _BarRow('陆家嘴花园', 8, 24, AppColors.primary),
            _BarRow('浦东大道公寓', 6, 24, const Color(0xFF06B6D4)),
            _BarRow('静安公馆', 4, 24, const Color(0xFFF59E0B)),
            _BarRow('前滩小区', 3, 24, const Color(0xFF10B981)),
            _BarRow('徐家汇公寓', 2, 24, const Color(0xFFEC4899)),
            _BarRow('其他', 1, 24, Colors.grey),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTenantTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(children: [
          Expanded(child: _MiniStatCard('总租客', '18', '人', AppColors.primary)),
          const SizedBox(width: 8),
          Expanded(child: _MiniStatCard('本月新增', '3', '人', const Color(0xFF10B981))),
          const SizedBox(width: 8),
          Expanded(child: _MiniStatCard('本月退租', '1', '人', const Color(0xFFEF4444))),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('租客构成', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _PieRow('上班族', 12, 18, const Color(0xFF6366F1)),
            _PieRow('学生', 3, 18, const Color(0xFF06B6D4)),
            _PieRow('家庭', 2, 18, const Color(0xFFF59E0B)),
            _PieRow('其他', 1, 18, const Color(0xFF9C27B0)),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('合同即将到期（30天内）', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _AlertTenant('张先生', '陆家嘴花园整租', '还剩15天'),
            _AlertTenant('李女士', '浦东大道合租', '还剩5天'),
            _AlertTenant('陈小姐', '徐家汇精品公寓', '还剩5天'),
          ]),
        ),
      ]),
    );
  }
}

class _ChartData {
  final String label;
  final int total;
  final int expense;
  const _ChartData(this.label, this.total, this.expense);
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _SummaryCard(this.label, this.value, this.color, this.icon);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ]),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    ]),
  );
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  const _Legend(this.label, this.color);
  @override Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11)),
  ]);
}

class _BarColumn extends StatelessWidget {
  final String label;
  final double totalH;
  final double expenseH;
  const _BarColumn(this.label, this.totalH, this.expenseH);
  @override Widget build(BuildContext context) => Column(children: [
    Expanded(child: Container()),
    const SizedBox(height: 8),
    Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
    const SizedBox(height: 4),
    Container(width: 20, height: expenseH, decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))),
    const SizedBox(height: 2),
    Container(width: 20, height: totalH - expenseH, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)))),
    const SizedBox(height: 8),
  ]);
}

class _PieRow extends StatelessWidget {
  final String label;
  final double value;
  final double total;
  final Color color;
  const _PieRow(this.label, this.value, this.total, this.color);
  @override Widget build(BuildContext context) {
    final pct = (value / total * 100).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        Text('$pct%', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text('¥${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  const _MiniStatCard(this.label, this.value, this.unit, this.color);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      Text(unit, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
    ]),
  );
}

class _BarRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;
  const _BarRow(this.label, this.value, this.total, this.color);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12))),
      Expanded(
        child: Container(
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / total,
            child: Container(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text('$value户', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ]),
  );
}

class _AlertTenant extends StatelessWidget {
  final String name;
  final String room;
  final String due;
  const _AlertTenant(this.name, this.room, this.due);
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
    child: Row(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.person, color: Color(0xFFF59E0B), size: 16)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        Text(room, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Text(due, style: const TextStyle(fontSize: 10, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}
