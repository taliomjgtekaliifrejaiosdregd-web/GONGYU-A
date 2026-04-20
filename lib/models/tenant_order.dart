// ============================================================
// 租客端订单 & 收藏模型（Mock 数据）
// ============================================================

/// 租房订单状态
enum RentOrderStatus { active, expiringSoon, expired, terminated }

/// 租房订单
class RentOrder {
  final String id;
  final String contractNo;
  final String roomTitle;
  final String roomAddress;
  final String layout;
  final double area;
  final double rentAmount;
  final double depositAmount;
  final DateTime startDate;
  final DateTime endDate;
  final RentOrderStatus status;
  final double? nextBillAmount;
  final DateTime? nextBillDate;
  final bool hasUnpaidBill;

  const RentOrder({
    required this.id,
    required this.contractNo,
    required this.roomTitle,
    required this.roomAddress,
    required this.layout,
    required this.area,
    required this.rentAmount,
    required this.depositAmount,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.nextBillAmount,
    this.nextBillDate,
    this.hasUnpaidBill = false,
  });

  int get daysToExpire => endDate.difference(DateTime.now()).inDays;
  int get daysToNextBill => nextBillDate != null ? nextBillDate!.difference(DateTime.now()).inDays : 0;

  String get statusLabel {
    switch (status) {
      case RentOrderStatus.active: return '生效中';
      case RentOrderStatus.expiringSoon: return '即将到期';
      case RentOrderStatus.expired: return '已到期';
      case RentOrderStatus.terminated: return '已终止';
    }
  }

  String get statusColor {
    switch (status) {
      case RentOrderStatus.active: return '#10B981';
      case RentOrderStatus.expiringSoon: return '#F59E0B';
      case RentOrderStatus.expired: return '#EF4444';
      case RentOrderStatus.terminated: return '#9E9E9E';
    }
  }

  String get periodText =>
    '${startDate.year}.${startDate.month.toString().padLeft(2, '0')}-${endDate.year}.${endDate.month.toString().padLeft(2, '0')}';
}

/// 好物订单状态
enum GoodsOrderStatus { pendingPayment, pendingShip, shipped, completed, cancelled, refunded }

/// 好物订单商品项
class GoodsOrderItem {
  final String name;
  final String spec;
  final int quantity;
  final double price;
  final String? thumbUrl;

  const GoodsOrderItem({
    required this.name,
    required this.spec,
    required this.quantity,
    required this.price,
    this.thumbUrl,
  });

  double get total => price * quantity;
}

/// 好物订单
class GoodsOrder {
  final String id;
  final String orderNo;
  final DateTime createdAt;
  final GoodsOrderStatus status;
  final String merchantName;
  final List<GoodsOrderItem> items;
  final double freight;
  final double discount;
  final String? trackingNo;
  final String? trackingCompany;

  const GoodsOrder({
    required this.id,
    required this.orderNo,
    required this.createdAt,
    required this.status,
    required this.merchantName,
    required this.items,
    this.freight = 0,
    this.discount = 0,
    this.trackingNo,
    this.trackingCompany,
  });

  double get totalAmount => items.fold(0.0, (s, i) => s + i.total) + freight - discount;

  String get statusLabel {
    switch (status) {
      case GoodsOrderStatus.pendingPayment: return '待付款';
      case GoodsOrderStatus.pendingShip: return '待发货';
      case GoodsOrderStatus.shipped: return '配送中';
      case GoodsOrderStatus.completed: return '已完成';
      case GoodsOrderStatus.cancelled: return '已取消';
      case GoodsOrderStatus.refunded: return '已退款';
    }
  }

  String get statusColor {
    switch (status) {
      case GoodsOrderStatus.pendingPayment: return '#F59E0B';
      case GoodsOrderStatus.pendingShip: return '#6366F1';
      case GoodsOrderStatus.shipped: return '#06B6D4';
      case GoodsOrderStatus.completed: return '#10B981';
      case GoodsOrderStatus.cancelled: return '#9E9E9E';
      case GoodsOrderStatus.refunded: return '#EF4444';
    }
  }
}

/// 收藏项
enum FavoriteType { room, goods }

class FavoriteItem {
  final String id;
  final FavoriteType type;
  final String title;
  final String? subtitle;
  final double price;
  final String? imageUrl;
  final DateTime addedAt;

  const FavoriteItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.price,
    this.imageUrl,
    required this.addedAt,
  });
}

/// 浏览历史项
class HistoryItem {
  final String id;
  final FavoriteType type;
  final String title;
  final String? subtitle;
  final double? price;
  final DateTime viewedAt;

  const HistoryItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.price,
    required this.viewedAt,
  });
}
