// 订单状态枚举
enum OrderStatus { pending, confirmed, completed, cancelled }

// 租赁订单模型
class Order {
  final String id;
  final String tenantName;
  final String tenantPhone;
  final String roomTitle;
  final String roomType;
  final double amount;
  final DateTime createdAt;
  final String status;

  const Order({
    required this.id,
    required this.tenantName,
    required this.tenantPhone,
    required this.roomTitle,
    required this.roomType,
    required this.amount,
    required this.createdAt,
    required this.status,
  });

  String get amountText => '¥${amount.toStringAsFixed(2)}';
  String get createdText => '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

  static List<Order> getMockOrders() {
    return [
      Order(id: 'o1', tenantName: '张三', tenantPhone: '138****1234', roomTitle: '阳光公寓 3号楼 A户型', roomType: '整租', amount: 3200, createdAt: DateTime.now().subtract(const Duration(hours: 2)), status: '待确认'),
      Order(id: 'o2', tenantName: '李四', tenantPhone: '139****5678', roomTitle: '都市花园 5号楼 B户型', roomType: '整租', amount: 2800, createdAt: DateTime.now().subtract(const Duration(days: 1)), status: '已确认'),
      Order(id: 'o3', tenantName: '王五', tenantPhone: '137****9012', roomTitle: '滨江公寓 2号楼 单间', roomType: '合租', amount: 1800, createdAt: DateTime.now().subtract(const Duration(days: 3)), status: '已完成'),
    ];
  }
}
