import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/tenant_order.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

/// ============================================================
//  租客 - 租房订单
// ============================================================
class RentOrdersPage extends StatefulWidget {
  const RentOrdersPage({super.key});
  @override
  State<RentOrdersPage> createState() => _RentOrdersPageState();
}

class _RentOrdersPageState extends State<RentOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<RentOrder> _allOrders = [
    RentOrder(
      id: '1',
      contractNo: 'HT20250301001',
      roomTitle: '阳光城A座301',
      roomAddress: '朝阳区望京街道阳光城小区A座',
      layout: '2室1厅1卫',
      area: 78.5,
      rentAmount: 4500,
      depositAmount: 9000,
      startDate: DateTime(2025, 3, 1),
      endDate: DateTime(2026, 3, 1),
      status: RentOrderStatus.active,
      nextBillAmount: 4500,
      nextBillDate: DateTime(2026, 4, 5),
      hasUnpaidBill: false,
    ),
    RentOrder(
      id: '2',
      contractNo: 'HT20241001002',
      roomTitle: '龙湖时代2号楼1502',
      roomAddress: '海淀区中关村南大街龙湖时代',
      layout: '1室1厅1卫',
      area: 52.0,
      rentAmount: 3800,
      depositAmount: 7600,
      startDate: DateTime(2024, 10, 1),
      endDate: DateTime(2025, 10, 1),
      status: RentOrderStatus.expiringSoon,
      nextBillAmount: 3800,
      nextBillDate: DateTime(2026, 4, 1),
      hasUnpaidBill: true,
    ),
    RentOrder(
      id: '3',
      contractNo: 'HT20231201003',
      roomTitle: '万科城市花园7单元1201',
      roomAddress: '浦东新区陆家嘴万科城市花园',
      layout: '3室2厅2卫',
      area: 120.0,
      rentAmount: 6800,
      depositAmount: 13600,
      startDate: DateTime(2023, 12, 1),
      endDate: DateTime(2024, 12, 1),
      status: RentOrderStatus.expired,
    ),
    RentOrder(
      id: '4',
      contractNo: 'HT20240115004',
      roomTitle: '华润橡树湾5号楼801',
      roomAddress: '天河区珠江新城华润橡树湾',
      layout: '2室1厅1卫',
      area: 65.0,
      rentAmount: 5200,
      depositAmount: 10400,
      startDate: DateTime(2024, 1, 15),
      endDate: DateTime(2025, 1, 15),
      status: RentOrderStatus.terminated,
    ),
  ];

  List<RentOrder> get _activeOrders => _allOrders.where((o) => o.status == RentOrderStatus.active || o.status == RentOrderStatus.expiringSoon).toList();
  List<RentOrder> get _historyOrders => _allOrders.where((o) => o.status == RentOrderStatus.expired || o.status == RentOrderStatus.terminated).toList();

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

  Color _parseColor(String hex) => Color(int.parse(hex.replaceFirst('#', '0xFF')));

  void _showOrderDetail(BuildContext context, RentOrder order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            // 顶部标题
            Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: _parseColor(order.statusColor).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.receipt_long, color: _parseColor(order.statusColor), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order.roomTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(order.contractNo, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _parseColor(order.statusColor).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(order.statusLabel, style: TextStyle(fontSize: 12, color: _parseColor(order.statusColor), fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 20),
            // 房源信息
            _DetailSection('房源信息', [
              _DetailRow('房源名称', order.roomTitle),
              _DetailRow('房源地址', order.roomAddress),
              _DetailRow('户型', order.layout),
              _DetailRow('面积', '${order.area.toStringAsFixed(1)} m\u00b2'),
            ]),
            const SizedBox(height: 16),
            // 合同信息
            _DetailSection('合同信息', [
              _DetailRow('合同编号', order.contractNo),
              _DetailRow('合同期限', order.periodText),
              _DetailRow('月租金', '\u00a5${order.rentAmount.toStringAsFixed(0)}'),
              _DetailRow('押金', '\u00a5${order.depositAmount.toStringAsFixed(0)}'),
              _DetailRow('剩余天数', '${order.daysToExpire > 0 ? order.daysToExpire : 0} 天'),
            ]),
            if (order.hasUnpaidBill) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFDE68A))),
                child: Row(children: [
                  const Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('待缴账单提醒', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                    const SizedBox(height: 2),
                    Text('您有待缴租金 \u00a5${order.nextBillAmount?.toStringAsFixed(0)}，请尽快缴纳', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ])),
                ]),
              ),
            ],
            const SizedBox(height: 24),
            if (order.status == RentOrderStatus.active || order.status == RentOrderStatus.expiringSoon) ...[
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.extension), label: const Text('申请维修'),
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF6366F1)))),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.payment), label: const Text('立即缴费'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white))),
              ]),
            ],
            if (order.status == RentOrderStatus.expired || order.status == RentOrderStatus.terminated) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade600),
                    child: const Text('查看历史记录'))),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('租房订单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: const Color(0xFF9E9E9E),
          indicatorColor: const Color(0xFF6366F1),
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: [
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('生效中'),
              const SizedBox(width: 4),
              _CountBadge(count: _activeOrders.length),
            ])),
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('历史'),
              const SizedBox(width: 4),
              _CountBadge(count: _historyOrders.length),
            ])),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OrderList(orders: _activeOrders, emptyIcon: Icons.receipt_long, emptyText: '暂无生效合同', onTap: _showOrderDetail),
          _OrderList(orders: _historyOrders, emptyIcon: Icons.history, emptyText: '暂无历史合同', onTap: _showOrderDetail),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});
  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(10)),
      child: Text('$count', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<RentOrder> orders;
  final IconData emptyIcon;
  final String emptyText;
  final Function(BuildContext, RentOrder) onTap;

  const _OrderList({required this.orders, required this.emptyIcon, required this.emptyText, required this.onTap});

  Color _parseColor(String hex) => Color(int.parse(hex.replaceFirst('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(emptyIcon, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(emptyText, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (_, i) {
        final o = orders[i];
        final statusColor = _parseColor(o.statusColor);
        return GestureDetector(
          onTap: () => onTap(context, o),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.home, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(o.roomTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(o.contractNo, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(o.statusLabel, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Row(children: [
                _StatChip(Icons.calendar_today, o.periodText),
                const SizedBox(width: 12),
                _StatChip(Icons.attach_money, '\u00a5${o.rentAmount.toStringAsFixed(0)}/月'),
                const Spacer(),
                if (o.hasUnpaidBill)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                    child: const Text('\u00a5待缴费', style: TextStyle(fontSize: 10, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600)),
                  )
                else if (o.daysToExpire > 0)
                  Text('剩余 ${o.daysToExpire} 天', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ]),
            ]),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: Colors.grey.shade400),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
  ]);
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<_DetailRow> rows;
  const _DetailSection(this.title, this.rows);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
      child: Column(children: rows),
    ),
  ]);
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    ]),
  );
}
