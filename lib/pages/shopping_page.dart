import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/goods.dart';
import 'package:gongyu_guanjia/pages/login_page.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Goods> _allGoods = Goods.getMockGoods();
  final List<CartItem> _cart = [];
  String _selectedCategory = '全部';

  final _categories = ['全部', '厨房电器', '智能穿戴', '居家日用', '口腔护理', '零食', '电工电气'];

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

  List<Goods> get _filteredGoods {
    if (_selectedCategory == '全部') return _allGoods;
    return _allGoods.where((g) => g.category == _selectedCategory).toList();
  }

  void _addToCart(Goods goods) {
    setState(() {
      final existing = _cart.where((c) => c.goods.id == goods.id).firstOrNull;
      if (existing != null) {
        existing.quantity++;
      } else {
        _cart.add(CartItem(goods: goods));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('${goods.name} 已加入购物车')),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: '查看购物车',
          textColor: const Color(0xFFEF4444),
          onPressed: () => _tabController.animateTo(1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // 顶部搜索
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 100,
            backgroundColor: const Color(0xFFEF4444),
            leading: const SizedBox(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFFF8A65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_bag, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            const Text('尖叫好货', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _tabController.animateTo(1),
                              child: Stack(
                                children: [
                                  const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
                                  if (_cart.isNotEmpty)
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Color(0xFFFFD600), shape: BoxShape.circle),
                                        child: Text('${_cart.fold(0, (s, c) => s + c.quantity)}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: '搜索商品',
                            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFFBDBDBD), size: 20),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          ),
                          onSubmitted: (_) {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: const Color(0xFFEF4444),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  tabs: const [
                    Tab(text: '精选推荐'),
                    Tab(text: '购物车'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // 精选推荐
            _GoodsTab(goods: _filteredGoods, categories: _categories, selectedCategory: _selectedCategory, onCategoryChanged: (c) => setState(() => _selectedCategory = c), onAddToCart: _addToCart),
            // 购物车
            _CartTab(cart: _cart, onRemove: (item) => setState(() => _cart.remove(item)), onQuantityChanged: (item, delta) => setState(() => item.quantity = (item.quantity + delta).clamp(1, 99))),
          ],
        ),
      ),
    );
  }
}

// ==================== 商品列表 ====================
class _GoodsTab extends StatelessWidget {
  final List<Goods> goods;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<Goods> onAddToCart;

  const _GoodsTab({required this.goods, required this.categories, required this.selectedCategory, required this.onCategoryChanged, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 分类横滑
        Container(
          height: 48,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat == selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onCategoryChanged(cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEF4444) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(cat, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : const Color(0xFF757575), fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                  ),
                ),
              );
            },
          ),
        ),
        // 商品网格
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.68,
            ),
            itemCount: goods.length,
            itemBuilder: (context, index) => _GoodsCard(goods: goods[index], onAdd: () => onAddToCart(goods[index])),
          ),
        ),
      ],
    );
  }
}

class _GoodsCard extends StatelessWidget {
  final Goods goods;
  final VoidCallback onAdd;

  const _GoodsCard({required this.goods, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(_getCategoryIcon(goods.category), size: 60, color: const Color(0xFFE0E0E0))),
                  if (goods.discount < 95)
                    Positioned(
                      left: 6, top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('${goods.discount}折', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goods.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Row(
                    children: [
                      Text(goods.priceText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                      const SizedBox(width: 4),
                      Text(goods.originalPriceText, style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD), decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 12, color: const Color(0xFFF59E0B)),
                      const SizedBox(width: 2),
                      Text(goods.rating.toString(), style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                      const SizedBox(width: 4),
                      Text('销量${goods.sales}', style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: onAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('加入购物车', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '厨房电器': return Icons.kitchen;
      case '智能穿戴': return Icons.watch;
      case '居家日用': return Icons.chair;
      case '口腔护理': return Icons.medical_services;
      case '零食': return Icons.cookie;
      case '电工电气': return Icons.electrical_services;
      default: return Icons.inventory_2;
    }
  }
}

// ==================== 购物车 ====================
class _CartTab extends StatelessWidget {
  final List<CartItem> cart;
  final ValueChanged<CartItem> onRemove;
  final void Function(CartItem, int) onQuantityChanged;

  const _CartTab({required this.cart, required this.onRemove, required this.onQuantityChanged});

  double get _total => cart.fold(0, (s, c) => s + c.total);

  @override
  Widget build(BuildContext context) {
    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: const Color(0xFFE0E0E0)),
            const SizedBox(height: 16),
            const Text('购物车是空的', style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 8),
            const Text('去选购心仪好物吧~', style: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD))),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cart.length,
            itemBuilder: (context, index) {
              final item = cart[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.inventory_2, size: 30, color: const Color(0xFFE0E0E0)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.goods.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(item.goods.priceText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            _QtyBtn(icon: Icons.remove, onTap: () { if (item.quantity > 1) onQuantityChanged(item, -1); }),
                            SizedBox(
                              width: 32,
                              child: Center(child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold))),
                            ),
                            _QtyBtn(icon: Icons.add, onTap: () => onQuantityChanged(item, 1)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => onRemove(item),
                          child: const Icon(Icons.delete_outline, color: Color(0xFF9E9E9E), size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // 结算栏
        Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('合计', style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
                  Text('¥${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text('去结算（${cart.fold(0, (s, c) => s + c.quantity)}件）', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 26, height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: const Color(0xFF757575)),
      ),
    );
  }
}


class GoodsOrderPage extends StatelessWidget {
  const GoodsOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {'id': 'ORD20240101001', 'title': '小米手环8', 'status': '已发货', 'price': '¥199'},
      {'id': 'ORD20240101002', 'title': '电动牙刷', 'status': '处理中', 'price': '¥129'},
      {'id': 'ORD20240101003', 'title': '空气炸锅', 'status': '已完成', 'price': '¥399'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('好物订单'), backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (ctx, i) {
          final o = orders[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(o['id']!, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                    Text(o['status']!, style: TextStyle(fontSize: 12, color: o['status'] == '已完成' ? const Color(0xFF10B981) : const Color(0xFFF59E0B))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(o['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(o['price']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
              ],
            ),
          );
        },
      ),
    );
  }
}
