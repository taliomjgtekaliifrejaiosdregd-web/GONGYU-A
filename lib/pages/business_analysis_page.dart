import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/goods.dart';

class BusinessAnalysisPage extends StatelessWidget {
  const BusinessAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B61FF),
        foregroundColor: Colors.white,
        title: const Text('购物经营分析'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 概览卡片
          _OverviewCards(),
          const SizedBox(height: 16),

          // 销售趋势图（简化模拟）
          _ChartCard(),
          const SizedBox(height: 16),

          // 商品销售排行
          _SalesRankingCard(),
          const SizedBox(height: 16),

          // 热门品类
          _CategoryCard(),
          const SizedBox(height: 16),

          // 经营建议
          _SuggestionCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OverviewCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('经营概览', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: '本月GMV',
                value: '¥12,580',
                trend: '+23.5%',
                trendUp: true,
                color: const Color(0xFF7B61FF),
                icon: Icons.shopping_bag,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: '订单量',
                value: '86',
                trend: '+15',
                trendUp: true,
                color: const Color(0xFF2196F3),
                icon: Icons.receipt_long,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: '毛利率',
                value: '35.2%',
                trend: '+2.1%',
                trendUp: true,
                color: const Color(0xFF00C853),
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: '客户满意度',
                value: '98%',
                trend: '+1%',
                trendUp: true,
                color: const Color(0xFFFF9800),
                icon: Icons.thumb_up,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool trendUp;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.color,
    required this.icon,
  });

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 12, color: const Color(0xFF757575))),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(trendUp ? Icons.arrow_upward : Icons.arrow_downward, color: trendUp ? const Color(0xFF00C853) : Colors.red, size: 14),
              Text(trend, style: TextStyle(fontSize: 12, color: trendUp ? const Color(0xFF00C853) : Colors.red, fontWeight: FontWeight.w500)),
              Text(' vs上月', style: TextStyle(fontSize: 11, color: const Color(0xFFBDBDBD))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
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
          Row(
            children: [
              const Text('销售趋势', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                child: const Text('近30天', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 模拟柱状图
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Bar(height: 40, label: '周一'),
                _Bar(height: 65, label: '周二'),
                _Bar(height: 55, label: '周三'),
                _Bar(height: 80, label: '周四'),
                _Bar(height: 90, label: '周五'),
                _Bar(height: 100, label: '周六'),
                _Bar(height: 75, label: '周日'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _LegendDot(color: const Color(0xFF7B61FF), label: '尖叫好货'),
              const SizedBox(width: 20),
              _LegendDot(color: const Color(0xFF00C853), label: '租房收入'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final String label;
  _Bar({required this.height, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${(height * 12.8).toStringAsFixed(0)}', style: const TextStyle(fontSize: 9, color: Color(0xFF9E9E9E))),
        const SizedBox(height: 2),
        Container(
          width: 28,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF9C27B0)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF9E9E9E))),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
      ],
    );
  }
}

class _SalesRankingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final goods = Goods.getMockGoods().take(5).toList();
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
          Row(
            children: [
              const Text('商品销售排行', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('查看全部', style: TextStyle(fontSize: 12, color: Color(0xFF7B61FF))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...goods.asMap().entries.map((e) {
            final i = e.key;
            final g = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: i < 3 ? [const Color(0xFFFF5722), const Color(0xFFFF9800), const Color(0xFFFFC107)][i].withOpacity(0.15) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(child: Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: i < 3 ? [const Color(0xFFFF5722), const Color(0xFFFF9800), const Color(0xFFFFC107)][i] : const Color(0xFF757575)))),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.inventory_2, size: 24, color: const Color(0xFFE0E0E0)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('销量 ${g.sales}件', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                      ],
                    ),
                  ),
                  Text('¥${(g.price * g.sales * 0.1).toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': '厨房电器', 'sales': 38, 'gmv': '¥4,580', 'color': const Color(0xFFFF5722)},
      {'name': '智能穿戴', 'sales': 25, 'gmv': '¥3,200', 'color': const Color(0xFF2196F3)},
      {'name': '居家日用', 'sales': 32, 'gmv': '¥2,100', 'color': const Color(0xFF00C853)},
      {'name': '口腔护理', 'sales': 18, 'gmv': '¥1,800', 'color': const Color(0xFF9C27B0)},
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
          const Text('热门品类', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: categories.map((cat) {
              final c = cat['color'] as Color;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(cat['name'] as String, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('${cat['sales']}件', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                      Text(cat['gmv'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final suggestions = [
      {'icon': Icons.lightbulb_outline, 'title': '优化进货', 'desc': '厨房电器销量最高，建议增加库存和sku'},
      {'icon': Icons.trending_up, 'title': '提升客单', 'desc': '当前客单价偏低，可捆绑销售提升GMV'},
      {'icon': Icons.campaign, 'title': '营销活动', 'desc': '周末销售额最高，建议周末加大促销'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7B61FF).withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7B61FF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF7B61FF), size: 18),
              SizedBox(width: 8),
              Text('AI经营建议', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF7B61FF))),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(s['icon'] as IconData, color: const Color(0xFF7B61FF), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF424242))),
                          Text(s['desc'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
