// 产品模型
class Goods {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final double price;
  final double originalPrice;
  final String image;
  final String category;
  final double rating;
  final int sales;
  final String brand;
  final String origin;
  final String spec;

  const Goods({
    required this.id,
    required this.name,
    required this.subtitle,
    this.description = '',
    required this.price,
    required this.originalPrice,
    required this.image,
    required this.category,
    required this.rating,
    required this.sales,
    this.brand = '',
    this.origin = '中国',
    this.spec = '标准规格',
  });

  String get priceText => '¥${price.toStringAsFixed(2)}';
  String get originalPriceText => '¥${originalPrice.toStringAsFixed(2)}';
  int get discount => ((price / originalPrice) * 10 * 10).round();

  // 演示数据
  static List<Goods> getMockGoods() {
    return [
      const Goods(id: 'g1', name: '小米手环8 NFC', subtitle: '全天候健康监测 150+运动模式', price: 249, originalPrice: 299, image: 'wristband', category: '智能穿戴', rating: 4.8, sales: 23800, brand: '小米'),
      const Goods(id: 'g2', name: '美的空气炸锅 5L', subtitle: '无油烹饪 低脂健康 触控款', price: 299, originalPrice: 499, image: 'airfryer', category: '厨房电器', rating: 4.9, sales: 15600, brand: '美的'),
      const Goods(id: 'g3', name: '得力桌面收纳盒', subtitle: '三层抽屉式 办公桌面整理', price: 39.9, originalPrice: 69, image: 'storage', category: '居家日用', rating: 4.7, sales: 8900, brand: '得力'),
      const Goods(id: 'g4', name: '飞利浦电动牙刷 HX6730', subtitle: '声波震动 净齿护龈', price: 199, originalPrice: 399, image: 'toothbrush', category: '口腔护理', rating: 4.8, sales: 31200, brand: '飞利浦'),
      const Goods(id: 'g5', name: '苏泊尔电饭煲 4L', subtitle: '智能预约 一键柴火饭', price: 259, originalPrice: 459, image: 'cooker', category: '厨房电器', rating: 4.6, sales: 12400, brand: '苏泊尔'),
      const Goods(id: 'g6', name: '公牛插排 8位+4USB', subtitle: '防过载保护 线长1.8米', price: 59.9, originalPrice: 89, image: 'powerstrip', category: '电工电气', rating: 4.9, sales: 45600, brand: '公牛'),
      const Goods(id: 'g7', name: '三只松鼠坚果礼盒 1478g', subtitle: '每日坚果 送礼佳品', price: 79, originalPrice: 128, image: 'nuts', category: '零食', rating: 4.7, sales: 28900, brand: '三只松鼠'),
      const Goods(id: 'g8', name: '九阳破壁机 Y1', subtitle: '免洗破壁 静音低噪', price: 599, originalPrice: 899, image: 'blender', category: '厨房电器', rating: 4.8, sales: 9800, brand: '九阳'),
    ];
  }
}

// 购物车项
class CartItem {
  final Goods goods;
  int quantity;

  CartItem({required this.goods, this.quantity = 1});

  double get total => goods.price * quantity;
}
