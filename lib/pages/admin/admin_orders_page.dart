import 'package:flutter/material.dart';

// ============================================================
// 后台管理 - 订单管理
// ============================================================
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});
  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _typeFilter = '全部';
  String _statusFilter = '全部';

  static const _types = ['全部', '房租', '押金', '水电费', '维修费', '其他'];
  static const _statuses = ['全部', '待支付', '已支付', '处理中', '已完成', '已退款', '已取消'];

  static const _orders = [
    {'id': 'ORD2026041701', 'type': '房租', 'room': '华侨城花园A栋501', 'tenant': '张三', 'landlord': '李明', 'amount': '3200.00', 'status': '待支付', 'date': '2026-04-17'},
    {'id': 'ORD2026041702', 'type': '押金', 'room': '科技园公寓B栋302', 'tenant': '王五', 'landlord': '陈强', 'amount': '4500.00', 'status': '已完成', 'date': '2026-04-17'},
    {'id': 'ORD2026041603', 'type': '水电费', 'room': '龙华公馆C栋201', 'tenant': '李四', 'landlord': '赵雪', 'amount': '328.50', 'status': '已退款', 'date': '2026-04-16'},
    {'id': 'ORD2026041604', 'type': '维修费', 'room': '南山花园D栋601', 'tenant': '陈六', 'landlord': '李明', 'amount': '350.00', 'status': '处理中', 'date': '2026-04-16'},
    {'id': 'ORD2026041505', 'type': '房租', 'room': '福田中心E栋401', 'tenant': '刘洋', 'landlord': '陈强', 'amount': '2800.00', 'status': '已完成', 'date': '2026-04-15'},
    {'id': 'ORD2026041506', 'type': '押金', 'room': '罗湖小区F栋102', 'tenant': '周婷', 'landlord': '赵雪', 'amount': '3800.00', 'status': '待支付', 'date': '2026-04-15'},
    {'id': 'ORD2026041407', 'type': '其他', 'room': '宝安中心G栋702', 'tenant': '吴七', 'landlord': '李明', 'amount': '150.00', 'status': '已取消', 'date': '2026-04-14'},
    {'id': 'ORD2026041408', 'type': '水电费', 'room': '坂田公寓H栋503', 'tenant': '郑八', 'landlord': '陈强', 'amount': '215.80', 'status': '已完成', 'date': '2026-04-14'},
  ];

  List<Map<String, String>> get _filtered {
    return _orders.where((o) {
      if (_typeFilter != '全部' && o['type'] != _typeFilter) return false;
      if (_statusFilter != '全部' && o['status'] != _statusFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return o['id']!.toLowerCase().contains(q) || o['tenant']!.toLowerCase().contains(q) || o['room']!.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  Map<String, int> get _stats {
    int total = _orders.length;
    int pending = _orders.where((o) => o['status'] == '待支付').length;
    int completed = _orders.where((o) => o['status'] == '已完成').length;
    int refund = _orders.where((o) => o['status'] == '已退款').length;
    double totalAmount = _orders.where((o) => o['status'] == '已完成').fold<double>(0, (s, o) => s + double.tryParse(o['amount']!)!);
    return {'total': total, 'pending': pending, 'completed': completed, 'refund': refund, 'amount': totalAmount.toInt()};
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('订单管理', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF6366F1),
            unselectedLabelColor: const Color(0xFF9E9E9E),
            indicatorColor: const Color(0xFF6366F1),
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: '订单列表'),
              Tab(text: '数据统计'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab1: 订单列表
          Column(children: [
            // 搜索 + 筛选
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: '搜索订单号/租客/房源',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _FilterChip(label: '类型: $_typeFilter', onTap: () => _showFilter(context, _types, true)),
                    const SizedBox(width: 8),
                    _FilterChip(label: '状态: $_statusFilter', onTap: () => _showFilter(context, _statuses, false)),
                    const SizedBox(width: 8),
                    Text('${_filtered.length} 条', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                  ]),
                ),
              ]),
            ),
            // 统计条
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(children: [
                _MiniStat('待支付', '${stats['pending']}', const Color(0xFFF59E0B)),
                Container(width: 1, height: 24, color: const Color(0xFFE0E0E0)),
                _MiniStat('已完成', '${stats['completed']}', const Color(0xFF10B981)),
                Container(width: 1, height: 24, color: const Color(0xFFE0E0E0)),
                _MiniStat('已退款', '${stats['refund']}', const Color(0xFFEF4444)),
                Container(width: 1, height: 24, color: const Color(0xFFE0E0E0)),
                _MiniStat('收款', '¥${stats['amount']}', const Color(0xFF6366F1)),
              ]),
            ),
            const Divider(height: 1),
            // 列表
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('没有找到符合条件的订单', style: TextStyle(color: Color(0xFF9E9E9E))))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _OrderCard(
                        order: _filtered[i],
                        onProcess: () => _processOrder(context, _filtered[i]),
                        onRefund: () => _refundOrder(context, _filtered[i]),
                        onDetail: () => _showDetail(context, _filtered[i]),
                      ),
                    ),
            ),
          ]),

          // Tab2: 数据统计
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // 营收概览
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(children: [
                  Row(children: [
                    const Text('本月订单营收', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const Spacer(),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Text('2026年4月', style: TextStyle(color: Colors.white, fontSize: 11))),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('¥127,482.30', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.3), borderRadius: BorderRadius.circular(6)), child: const Text('+15.2%', style: TextStyle(color: Colors.white, fontSize: 11))),
                        const SizedBox(width: 6),
                        const Text('较上月增长', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ]),
                    ])),
                    Column(children: [
                      _RevenueMini('收租', '¥89,200', const Color(0xFF10B981)),
                      const SizedBox(height: 6),
                      _RevenueMini('押金', '¥22,500', const Color(0xFFF59E0B)),
                      const SizedBox(height: 6),
                      _RevenueMini('水电费', '¥15,782', const Color(0xFF06B6D4)),
                    ]),
                  ]),
                ]),
              ),

              const SizedBox(height: 16),

              // 按类型统计
              const Text('📊 订单类型分布', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  _TypeStatRow('房租', 42, 3200, const Color(0xFF6366F1)),
                  const SizedBox(height: 12),
                  _TypeStatRow('押金', 18, 4500, const Color(0xFFF59E0B)),
                  const SizedBox(height: 12),
                  _TypeStatRow('水电费', 28, 215, const Color(0xFF06B6D4)),
                  const SizedBox(height: 12),
                  _TypeStatRow('维修费', 8, 350, const Color(0xFFEF4444)),
                  const SizedBox(height: 12),
                  _TypeStatRow('其他', 4, 150, const Color(0xFF9E9E9E)),
                ]),
              ),

              const SizedBox(height: 16),

              // 退款分析
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('💸 退款分析', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _RefundCard('退款订单', '24笔', '¥8,450', const Color(0xFFEF4444))),
                    const SizedBox(width: 8),
                    Expanded(child: _RefundCard('退款率', '4.5%', '-0.3%', const Color(0xFFF59E0B))),
                    const SizedBox(width: 8),
                    Expanded(child: _RefundCard('平均退款', '¥352', '¥320', const Color(0xFF6366F1))),
                  ]),
                ]),
              ),

              const SizedBox(height: 16),

              // 导出按钮
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('订单数据正在导出...'), behavior: SnackBarBehavior.floating),
                    ),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('导出Excel'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('报表生成中...'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
                    ),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('月度报表'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ]),

              const SizedBox(height: 20),
            ]),
          ),
        ],
      ),
    );
  }

  void _showFilter(BuildContext context, List<String> options, bool isType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.all(16), child: Text(isType ? '选择订单类型' : '选择订单状态', style: const TextStyle(fontWeight: FontWeight.bold))),
        ...options.map((o) => ListTile(
          title: Text(o),
          trailing: (isType ? _typeFilter : _statusFilter) == o ? const Icon(Icons.check, color: Color(0xFF6366F1)) : null,
          onTap: () {
            setState(() {
              if (isType) _typeFilter = o; else _statusFilter = o;
            });
            Navigator.pop(context);
          },
        )),
        const SizedBox(height: 8),
      ]),
    );
  }

  void _processOrder(BuildContext context, Map<String, String> order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('处理订单'),
        content: Text('确认处理订单 ${order['id']}？\n金额：¥${order['amount']}\n房源：${order['room']}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('订单 ${order['id']} 处理成功'), behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFF10B981)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('确认处理'),
          ),
        ],
      ),
    );
  }

  void _refundOrder(BuildContext context, Map<String, String> order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('退款处理'),
        content: Text('确认退款订单 ${order['id']}？\n金额：¥${order['amount']}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已发起退款：¥${order['amount']}'), behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFFF59E0B)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            child: const Text('确认退款'),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, String> order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('订单详情', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            _StatusBadge(order['status']!),
          ]),
          const SizedBox(height: 16),
          _DetailRow('订单号', order['id']!),
          _DetailRow('订单类型', order['type']!),
          _DetailRow('房源信息', order['room']!),
          _DetailRow('租客姓名', order['tenant']!),
          _DetailRow('房东姓名', order['landlord']!),
          _DetailRow('订单金额', '¥${order['amount']}'),
          _DetailRow('下单时间', order['date']!),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('关闭'))),
            const SizedBox(width: 12),
            if (order['status'] == '待支付')
              Expanded(child: ElevatedButton(
                onPressed: () { Navigator.pop(context); _processOrder(context, order); },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                child: const Text('确认收款'),
              )),
            if (order['status'] == '已完成')
              Expanded(child: ElevatedButton(
                onPressed: () { Navigator.pop(context); _refundOrder(context, order); },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                child: const Text('退款处理'),
              )),
          ]),
        ]),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF0F0F5), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        const Icon(Icons.arrow_drop_down, size: 18),
      ]),
    ),
  );
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
  ]));
}

class _RevenueMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _RevenueMini(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
    ]),
  );
}

class _OrderCard extends StatelessWidget {
  final Map<String, String> order;
  final VoidCallback onProcess;
  final VoidCallback onRefund;
  final VoidCallback onDetail;

  const _OrderCard({required this.order, required this.onProcess, required this.onRefund, required this.onDetail});

  Color get _statusColor {
    switch (order['status']) {
      case '已完成': return const Color(0xFF10B981);
      case '待支付': return const Color(0xFFF59E0B);
      case '处理中': return const Color(0xFF6366F1);
      case '已退款': return const Color(0xFFEF4444);
      case '已取消': return const Color(0xFF9E9E9E);
      default: return const Color(0xFF9E9E9E);
    }
  }

  IconData get _typeIcon {
    switch (order['type']) {
      case '房租': return Icons.home;
      case '押金': return Icons.security;
      case '水电费': return Icons.water_drop;
      case '维修费': return Icons.build;
      default: return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onDetail,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(_typeIcon, color: _statusColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(order['id']!, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 2),
            Text(order['room']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('¥${order['amount']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _statusColor)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(order['status']!, style: TextStyle(fontSize: 11, color: _statusColor)),
            ),
          ]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Text('${order['tenant']!} · ${order['type']} · ${order['date']}', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          const Spacer(),
          if (order['status'] == '待支付')
            GestureDetector(
              onTap: onProcess,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('确认收款', style: TextStyle(fontSize: 11, color: Color(0xFF10B981))),
              ),
            ),
          if (order['status'] == '已完成')
            GestureDetector(
              onTap: onRefund,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('退款处理', style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B))),
              ),
            ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFF0F0F5), borderRadius: BorderRadius.circular(8)),
            child: const Text('查看详情', style: TextStyle(fontSize: 11, color: Color(0xFF666666))),
          ),
        ]),
      ]),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);
  Color get _color {
    switch (status) {
      case '已完成': return const Color(0xFF10B981);
      case '待支付': return const Color(0xFFF59E0B);
      case '处理中': return const Color(0xFF6366F1);
      case '已退款': return const Color(0xFFEF4444);
      default: return const Color(0xFF9E9E9E);
    }
  }
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Text(status, style: TextStyle(fontSize: 12, color: _color)),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
    ]),
  );
}

class _TypeStatRow extends StatelessWidget {
  final String label;
  final int count;
  final double amount;
  final Color color;
  const _TypeStatRow(this.label, this.count, this.amount, this.color);

  @override
  Widget build(BuildContext context) {
    final pct = (count / 100.0).clamp(0.0, 1.0);
    return Column(children: [
      Row(children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct,
              child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$count单', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        SizedBox(width: 70, child: Text('¥${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: color), textAlign: TextAlign.right)),
      ]),
    ]);
  }
}

class _RefundCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  const _RefundCard(this.label, this.value, this.sub, this.color);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text(label, style: TextStyle(fontSize: 11, color: color)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 2),
      Text(sub, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
    ]),
  );
}
