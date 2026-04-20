import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/tenant_order.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

/// ============================================================
// 租客 - 好物订单（商品订单）
/// ============================================================
class GoodsOrdersPage extends StatefulWidget {
  const GoodsOrdersPage({super.key});
  @override
  State<GoodsOrdersPage> createState() => _GoodsOrdersPageState();
}

class _GoodsOrdersPageState extends State<GoodsOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<GoodsOrder> _orders = [
    GoodsOrder(
      id: 'G001', orderNo: 'DD20260410001234', createdAt: DateTime.now(),
      status: GoodsOrderStatus.pendingPayment, merchantName: '小米官方旗舰店',
      items: [GoodsOrderItem(name: '小米智能手环9', spec: '石墨黑 / 标准版', quantity: 1, price: 249)],
      freight: 0, discount: 20,
    ),
    GoodsOrder(
      id: 'G002', orderNo: 'DD20260408001111', createdAt: DateTime(2026, 4, 8, 14, 30),
      status: GoodsOrderStatus.pendingShip, merchantName: '得力办公专营店',
      items: [GoodsOrderItem(name: '得力订书机套装', spec: '蓝色 / 标配', quantity: 2, price: 35.9)],
      freight: 5, discount: 0,
    ),
    GoodsOrder(
      id: 'G003', orderNo: 'DD20260405000888', createdAt: DateTime(2026, 4, 5, 9, 15),
      status: GoodsOrderStatus.shipped, merchantName: '安踏官方outlets店',
      items: [
        GoodsOrderItem(name: '安踏运动T恤', spec: '黑色 XL', quantity: 1, price: 89),
        GoodsOrderItem(name: '安踏运动短裤', spec: '黑色 XL', quantity: 1, price: 59),
      ],
      freight: 0, discount: 10,
      trackingNo: 'SF1089234567890', trackingCompany: '顺丰速运',
    ),
    GoodsOrder(
      id: 'G004', orderNo: 'DD20260328000666', createdAt: DateTime(2026, 3, 28, 16, 40),
      status: GoodsOrderStatus.shipped, merchantName: '美的官方旗舰店',
      items: [GoodsOrderItem(name: '美的电热水壶', spec: '白色 1.7L', quantity: 1, price: 129)],
      freight: 0, discount: 0,
      trackingNo: 'YT2026040100234567', trackingCompany: '圆通速递',
    ),
    GoodsOrder(
      id: 'G005', orderNo: 'DD20260310000555', createdAt: DateTime(2026, 3, 10, 10, 0),
      status: GoodsOrderStatus.completed, merchantName: 'Apple授权专营店',
      items: [GoodsOrderItem(name: 'AirPods Pro 2', spec: 'MagSafe充电盒', quantity: 1, price: 1799)],
      freight: 0, discount: 50,
    ),
    GoodsOrder(
      id: 'G006', orderNo: 'DD20260220000444', createdAt: DateTime(2026, 2, 20, 11, 30),
      status: GoodsOrderStatus.completed, merchantName: 'OLAY玉兰油官方旗舰店',
      items: [
        GoodsOrderItem(name: 'OLAY淡斑小白瓶', spec: '40ml', quantity: 1, price: 259),
        GoodsOrderItem(name: 'OLAY熬夜霜', spec: '50g', quantity: 1, price: 169),
      ],
      freight: 0, discount: 30,
    ),
    GoodsOrder(
      id: 'G007', orderNo: 'DD20260110000333', createdAt: DateTime(2026, 1, 10, 8, 0),
      status: GoodsOrderStatus.refunded, merchantName: '联想官方旗舰店',
      items: [GoodsOrderItem(name: 'ThinkPad蓝牙鼠标', spec: '银色', quantity: 1, price: 89)],
      freight: 0, discount: 0,
    ),
  ];

  List<GoodsOrder> _filter(GoodsOrderStatus s) => _orders.where((o) => o.status == s).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _c(String h) => Color(int.parse(h.replaceFirst('#', '0xFF')));

  String _d(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Widget _buildDetailSheet(BuildContext ctx, GoodsOrder o) {
    final sc = ScrollController();
    final statusColor = _c(o.statusColor);
    return DraggableScrollableSheet(
      initialChildSize: 0.82, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
      builder: (_, __) => ListView(
        controller: sc,
        padding: const EdgeInsets.all(20),
        children: [
          // 头部
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(o.merchantName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('订单号：${o.orderNo}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              Text('下单时间：${_d(o.createdAt)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(o.statusLabel, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          const Text('商品信息', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...o.items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Icon(_itemIcon(item.name), size: 28, color: AppColors.primary.withValues(alpha: 0.6)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.spec, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Row(children: [
                  Text('\u00a5${item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('x${item.quantity}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ]),
              ])),
            ]),
          )),
          const SizedBox(height: 12),
          // 费用
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              _PRow('商品总价', '\u00a5${o.items.fold(0.0, (s, i) => s + i.total).toStringAsFixed(2)}'),
              if (o.freight > 0) _PRow('运费', '+\u00a5${o.freight.toStringAsFixed(2)}'),
              if (o.discount > 0) _PRow('优惠', '-\u00a5${o.discount.toStringAsFixed(2)}'),
              const Divider(height: 16),
              _PRow('实付金额', '\u00a5${o.totalAmount.toStringAsFixed(2)}', isBold: true, vc: const Color(0xFFEF4444)),
            ]),
          ),
          // 物流
          if (o.trackingNo != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.local_shipping, color: Color(0xFF0284C7), size: 20),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${o.trackingCompany}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0284C7))),
                  Text('运单号：${o.trackingNo}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ])),
                TextButton(onPressed: () {}, child: const Text('查看物流')),
              ]),
            ),
          ],
          const SizedBox(height: 24),
          // 操作按钮
          _buildDetailActions(o),
        ],
      ),
    );
  }

  Widget _buildDetailActions(GoodsOrder o) {
    switch (o.status) {
      case GoodsOrderStatus.pendingPayment:
        return Row(children: [
          Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('取消订单'))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            child: const Text('立即付款'),
          )),
        ]);
      case GoodsOrderStatus.pendingShip:
        return OutlinedButton(onPressed: () {}, child: const Text('提醒发货'));
      case GoodsOrderStatus.shipped:
        return ElevatedButton(
          onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
          child: const Text('确认收货'),
        );
      case GoodsOrderStatus.completed:
        return OutlinedButton(onPressed: () {}, child: const Text('申请售后'));
      default:
        return const SizedBox.shrink();
    }
  }

  IconData _itemIcon(String name) {
    if (name.contains('手环') || name.contains('耳机') || name.contains('AirPods')) return Icons.headphones;
    if (name.contains('T恤') || name.contains('运动') || name.contains('短裤')) return Icons.checkroom;
    if (name.contains('水壶') || name.contains('瓶') || name.contains('霜')) return Icons.local_drink;
    if (name.contains('鼠标') || name.contains('键盘')) return Icons.mouse;
    return Icons.shopping_bag;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0,
        title: const Text('好物订单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6366F1), unselectedLabelColor: const Color(0xFF9E9E9E),
          indicatorColor: const Color(0xFF6366F1), indicatorWeight: 2.5,
          isScrollable: true, tabAlignment: TabAlignment.start,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: [
            _TabL('待付款', _filter(GoodsOrderStatus.pendingPayment).length),
            _TabL('待发货', _filter(GoodsOrderStatus.pendingShip).length),
            _TabL('配送中', _filter(GoodsOrderStatus.shipped).length),
            _TabL('已完成', _filter(GoodsOrderStatus.completed).length),
            _TabL('退款/取消', _filter(GoodsOrderStatus.refunded).length + _filter(GoodsOrderStatus.cancelled).length),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OL(orders: _filter(GoodsOrderStatus.pendingPayment), onTap: _buildDetailSheet),
          _OL(orders: _filter(GoodsOrderStatus.pendingShip), onTap: _buildDetailSheet),
          _OL(orders: _filter(GoodsOrderStatus.shipped), onTap: _buildDetailSheet),
          _OL(orders: _filter(GoodsOrderStatus.completed), onTap: _buildDetailSheet),
          _OL(orders: [..._filter(GoodsOrderStatus.refunded), ..._filter(GoodsOrderStatus.cancelled)], onTap: _buildDetailSheet),
        ],
      ),
    );
  }
}

class _TabL extends StatelessWidget {
  final String label;
  final int count;
  const _TabL(this.label, this.count);
  @override
  Widget build(BuildContext context) => Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
    Text(label),
    if (count > 0) ...[
      const SizedBox(width: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(8)),
        child: Text('$count', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    ],
  ]));
}

class _OL extends StatelessWidget {
  final List<GoodsOrder> orders;
  final Widget Function(BuildContext, GoodsOrder) onTap;
  const _OL({required this.orders, required this.onTap});

  Color _c(String h) => Color(int.parse(h.replaceFirst('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('暂无订单', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12), itemCount: orders.length,
      itemBuilder: (_, i) {
        final o = orders[i];
        final sc = _c(o.statusColor);
        return GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            builder: (_) => SizedBox(height: MediaQuery.of(context).size.height * 0.85, child: onTap(context, o)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(children: [
              // 店铺头
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
                child: Row(children: [
                  const Icon(Icons.store, size: 16, color: Color(0xFF6366F1)),
                  const SizedBox(width: 6),
                  Text(o.merchantName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: sc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(o.statusLabel, style: TextStyle(fontSize: 10, color: sc, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
              // 商品列表
              ...o.items.map((item) => Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.shopping_bag, size: 28, color: Colors.grey.shade400),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(item.spec, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text('\u00a5${item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('x${item.quantity}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ]),
                  ])),
                ]),
              )),
              // 底部
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
                child: Row(children: [
                  Text('共 ${o.items.fold(0, (s, i) => s + i.quantity)} 件，合计', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  Text('\u00a5${o.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                  const Spacer(),
                  _ABtn(o),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _ABtn extends StatelessWidget {
  final GoodsOrder o;
  const _ABtn(this.o);
  @override
  Widget build(BuildContext context) {
    switch (o.status) {
      case GoodsOrderStatus.pendingPayment:
        return Row(children: [
          OutlinedButton(
            onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade600, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), minimumSize: Size.zero),
            child: const Text('取消', style: TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), minimumSize: Size.zero),
            child: const Text('付款', style: TextStyle(fontSize: 11)),
          ),
        ]);
      case GoodsOrderStatus.shipped:
        return ElevatedButton(
          onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), minimumSize: Size.zero),
          child: const Text('确认收货', style: TextStyle(fontSize: 11)),
        );
      default:
        return Text('查看详情', style: TextStyle(fontSize: 12, color: Colors.grey.shade500));
    }
  }
}

class _PRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? vc;
  const _PRow(this.label, this.value, {this.isBold = false, this.vc});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: isBold ? 14 : 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: vc ?? Colors.black87)),
    ]),
  );
}
