import 'package:flutter/material.dart';

class IncomeStatsPage extends StatelessWidget {
  const IncomeStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        title: const Text('收支统计'),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCard(),
          const SizedBox(height: 16),
          _MonthPicker(),
          const SizedBox(height: 16),
          _IncomeBreakdown(),
          const SizedBox(height: 16),
          _RecentTransactions(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF00873A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF00C853).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('本月总收入', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('¥28,600', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: const [
                    Icon(Icons.trending_up, color: Colors.white, size: 12),
                    SizedBox(width: 2),
                    Text('12.5%', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(label: '租金收入', value: '¥24,000'),
              const SizedBox(width: 24),
              _MiniStat(label: '服务收入', value: '¥4,600'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _MonthPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          const Icon(Icons.chevron_left, color: Color(0xFF9E9E9E)),
          const Spacer(),
          const Text('2026年4月', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
        ],
      ),
    );
  }
}

class _IncomeBreakdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('收入构成', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _IncomeItem(label: '租金收入', amount: '¥24,000', pct: 84, color: const Color(0xFF00C853)),
          const SizedBox(height: 12),
          _IncomeItem(label: '服务收入', amount: '¥3,200', pct: 11, color: const Color(0xFF7B61FF)),
          const SizedBox(height: 12),
          _IncomeItem(label: '其他收入', amount: '¥1,400', pct: 5, color: const Color(0xFFFF9800)),
        ],
      ),
    );
  }
}

class _IncomeItem extends StatelessWidget {
  final String label;
  final String amount;
  final int pct;
  final Color color;
  const _IncomeItem({required this.label, required this.amount, required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
            const Spacer(),
            Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: pct / 100,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactions = [
      {'name': '张三 - 阳光公寓', 'type': '租金', 'amount': '+3200', 'date': '04-10', 'color': const Color(0xFF00C853)},
      {'name': '李四 - 都市花园', 'type': '租金', 'amount': '+2800', 'date': '04-08', 'color': const Color(0xFF00C853)},
      {'name': '保洁服务 - 订单#1', 'type': '服务', 'amount': '+80', 'date': '04-06', 'color': const Color(0xFF00C853)},
      {'name': '维修服务 - 订单#2', 'type': '服务', 'amount': '+150', 'date': '04-05', 'color': const Color(0xFF00C853)},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('近期交易', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...transactions.map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: (t['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.arrow_downward, color: t['color'] as Color, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          Text('${t['type']} · ${t['date']}', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    ),
                    Text(t['amount'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: t['color'] as Color)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
