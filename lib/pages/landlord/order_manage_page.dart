import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/order.dart';

class OrderManagePage extends StatelessWidget {
  const OrderManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = Order.getMockOrders();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        title: const Text('订单管理'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          Color statusColor;
          switch (order.status) {
            case '待确认': statusColor = const Color(0xFFFF9800); break;
            case '已确认': statusColor = const Color(0xFF2196F3); break;
            case '已完成': statusColor = const Color(0xFF00C853); break;
            default: statusColor = const Color(0xFF9E9E9E);
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFE8F5E9),
                      child: const Icon(Icons.person, color: Color(0xFF00C853), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.tenantName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text(order.tenantPhone, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(order.status, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.roomTitle, style: const TextStyle(fontSize: 14, color: Color(0xFF424242))),
                          const SizedBox(height: 4),
                          Text('${order.roomType} · ${order.createdText}', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    ),
                    Text(order.amountText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                  ],
                ),
                if (order.status == '待确认') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('拒绝'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853)),
                          child: const Text('确认'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
