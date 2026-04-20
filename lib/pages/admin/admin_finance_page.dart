import 'package:flutter/material.dart';

// ============================================================
// 后台管理 - 财务统计
// ============================================================
class AdminFinancePage extends StatelessWidget {
  const AdminFinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('财务统计', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          TextButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('正在导出财务报表...'), behavior: SnackBarBehavior.floating),
            ),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('导出', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 财务总览
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('平台总营收', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('¥ 1,284,720', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.4), borderRadius: BorderRadius.circular(6)), child: const Text('+15.2%', style: TextStyle(color: Colors.white, fontSize: 11))),
                    const SizedBox(width: 6),
                    const Text('较上月增长', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ]),
                ])),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _FinMini('本月收入', '¥87,620', Colors.white70),
                _FinMini('本月支出', '¥12,350', Colors.amber.shade200),
                _FinMini('本月利润', '¥75,270', Colors.green.shade200),
                _FinMini('待结算', '¥15,800', Colors.red.shade200),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          // 收支趋势
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💹 近6个月收支趋势', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                  height: 130,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    _MonthBar('11月', 82000, 98000, 16000),
                    _MonthBar('12月', 95000, 110000, 15000),
                    _MonthBar('1月', 78000, 95000, 17000),
                    _MonthBar('2月', 88000, 102000, 14000),
                    _MonthBar('3月', 102000, 118000, 16000),
                    _MonthBar('4月', 87620, 100000, 12350),
                  ]),
                ),
              const SizedBox(height: 8),
              Row(children: [
                _LegendDot(const Color(0xFF10B981), '收入'),
                const SizedBox(width: 16),
                _LegendDot(const Color(0xFFEF4444), '支出'),
                const SizedBox(width: 16),
                _LegendDot(Color(0xFFFFB800), '利润'),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          // 收入来源分布
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💰 收入来源分布', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(painter: _PieChartPainter(), size: const Size(120, 120)),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(children: [
                  _PieLegend('房租收入', '¥65,200', 75, const Color(0xFF6366F1)),
                  const SizedBox(height: 8),
                  _PieLegend('押金收入', '¥12,500', 14, const Color(0xFF10B981)),
                  const SizedBox(height: 8),
                  _PieLegend('水电费', '¥6,820', 8, const Color(0xFF06B6D4)),
                  const SizedBox(height: 8),
                  _PieLegend('维修/其他', '¥3,100', 3, const Color(0xFFF59E0B)),
                ])),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          // 收支明细
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📋 本月收支明细', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._incomeItems.map((item) => _IncomeItemRow(item: Map<String, dynamic>.from(item))),
            ]),
          ),

          const SizedBox(height: 16),

          // 房东收益排行
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('🏆 房东收益排行 TOP5', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('查看全部', style: TextStyle(fontSize: 12))),
              ]),
              const SizedBox(height: 8),
              ...[
                {'rank': '🥇', 'name': '李明', 'rooms': '12套', 'income': '¥28,600'},
                {'rank': '🥈', 'name': '陈强', 'rooms': '8套', 'income': '¥19,200'},
                {'rank': '🥉', 'name': '赵雪', 'rooms': '5套', 'income': '¥12,800'},
                {'rank': '4', 'name': '钱伟', 'rooms': '4套', 'income': '¥9,600'},
                {'rank': '5', 'name': '孙亮', 'rooms': '3套', 'income': '¥7,200'},
              ].map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  SizedBox(width: 30, child: Text(r['rank']!, style: const TextStyle(fontSize: 16))),
                  CircleAvatar(radius: 14, backgroundColor: const Color(0xFF6366F1).withOpacity(0.1), child: Text((r['name'] as String).substring(0, 1), style: const TextStyle(fontSize: 11, color: Color(0xFF6366F1)))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    Text(r['rooms']!, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                  ])),
                  Text(r['income']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                ]),
              )),
            ]),
          ),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  static const _incomeItems = <Map<String, dynamic>>[
    {'icon': '💵', 'title': '房租收入', 'desc': '42笔订单', 'amount': '+¥65,200', 'color': Color(0xFF10B981)},
    {'icon': '🔒', 'title': '押金收入', 'desc': '18笔订单', 'amount': '+¥12,500', 'color': Color(0xFF10B981)},
    {'icon': '💧', 'title': '水电费代收', 'desc': '89笔订单', 'amount': '+¥6,820', 'color': Color(0xFF10B981)},
    {'icon': '🔧', 'title': '维修服务费', 'desc': '8笔订单', 'amount': '+¥2,400', 'color': Color(0xFF10B981)},
    {'icon': '📦', 'title': '其他收入', 'desc': '3笔订单', 'amount': '+¥700', 'color': Color(0xFF10B981)},
    {'icon': '🏗️', 'title': '维修支出', 'desc': '5笔支出', 'amount': '-¥5,200', 'color': Color(0xFFEF4444)},
    {'icon': '💡', 'title': '能耗成本', 'desc': '公共区域电费', 'amount': '-¥3,800', 'color': Color(0xFFEF4444)},
    {'icon': '🧹', 'title': '保洁支出', 'desc': '12次保洁', 'amount': '-¥2,400', 'color': Color(0xFFEF4444)},
    {'icon': '🔑', 'title': '门锁维护', 'desc': '3套门锁换电', 'amount': '-¥950', 'color': Color(0xFFEF4444)},
  ];
}

class _FinMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _FinMini(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(label, style: TextStyle(color: color, fontSize: 11)),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
  ]));
}

class _MonthBar extends StatelessWidget {
  final String month;
  final double income;
  final double expense;
  final double profit;
  const _MonthBar(this.month, this.income, this.expense, this.profit);

  @override
  Widget build(BuildContext context) {
    const max = 120000.0;
    final ih = (income / max).clamp(0.1, 1.0);
    final eh = (expense / max).clamp(0.05, 1.0);
    return Expanded(child: Column(children: [
      Expanded(
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Align(alignment: Alignment.bottomCenter, child: FractionallySizedBox(heightFactor: ih, child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: const BorderRadius.vertical(top: Radius.circular(3))))))),
          Expanded(child: Align(alignment: Alignment.bottomCenter, child: FractionallySizedBox(heightFactor: eh, child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: const BorderRadius.vertical(top: Radius.circular(3))))))),
        ]),
      ),
      const SizedBox(height: 4),
      Text(month, style: const TextStyle(fontSize: 9, color: Color(0xFF9E9E9E))),
    ]));
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot(this.color, this.label);
  @override Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
  ]);
}

class _IncomeItemRow extends StatelessWidget {
  final Map<String, dynamic> item;
  const _IncomeItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final icon = item['icon'] as String;
    final title = item['title'] as String;
    final desc = item['desc'] as String;
    final amount = item['amount'] as String;
    final color = item['color'] as Color;
    final isExpense = amount.startsWith('-');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
        ])),
        Text(amount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isExpense ? const Color(0xFFEF4444) : color)),
      ]),
    );
  }
}

class _PieLegend extends StatelessWidget {
  final String label;
  final String amount;
  final int pct;
  final Color color;
  const _PieLegend(this.label, this.amount, this.pct, this.color);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 6),
    Expanded(child: Text(label, style: const TextStyle(fontSize: 11))),
    Text('$pct%', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  ]);
}

class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final items = [
      (0.75, const Color(0xFF6366F1)),
      (0.14, const Color(0xFF10B981)),
      (0.08, const Color(0xFF06B6D4)),
      (0.03, const Color(0xFFF59E0B)),
    ];

    double startAngle = -1.5708; // -90度（从顶部开始）
    for (final item in items) {
      final sweepAngle = item.$1 * 2 * 3.14159265359;
      final paint = Paint()
        ..color = item.$2
        ..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
