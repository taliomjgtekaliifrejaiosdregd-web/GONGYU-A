import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/goods.dart';

class GoodsManagePage extends StatefulWidget {
  const GoodsManagePage({super.key});

  @override
  State<GoodsManagePage> createState() => _GoodsManagePageState();
}

class _GoodsManagePageState extends State<GoodsManagePage> {
  List<Goods> _goods = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _goods = Goods.getMockGoods();
  }

  void _editGoods(int index) {
    final goods = _goods[index];
    final nameController = TextEditingController(text: goods.name);
    final priceController = TextEditingController(text: goods.price.toString());
    final stockController = TextEditingController(text: '100');
    final categoryController = TextEditingController(text: goods.category);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('编辑商品', style: TextStyle(fontSize: 12)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '商品名称',
                  labelStyle: TextStyle(fontSize: 9),
                  helperStyle: TextStyle(fontSize: 7),
                ),
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: '分类',
                  labelStyle: TextStyle(fontSize: 9),
                  helperText: '如：厨房电器、智能穿戴、居家日用',
                  helperStyle: TextStyle(fontSize: 7),
                ),
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: '价格（元）',
                  labelStyle: TextStyle(fontSize: 9),
                ),
                style: const TextStyle(fontSize: 10),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: '库存',
                  labelStyle: TextStyle(fontSize: 9),
                ),
                style: const TextStyle(fontSize: 10),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(fontSize: 10)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _goods[index] = Goods(
                  id: goods.id,
                  name: nameController.text,
                  subtitle: goods.subtitle,
                  category: categoryController.text,
                  price: double.tryParse(priceController.text) ?? goods.price,
                  originalPrice: goods.originalPrice,
                  image: goods.image,
                  rating: goods.rating,
                  sales: goods.sales,
                  brand: goods.brand,
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('商品已更新'), behavior: SnackBarBehavior.floating));
            },
            child: const Text('保存', style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  void _addGoods() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('添加商品', style: TextStyle(fontSize: 12)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '商品名称',
                  labelStyle: TextStyle(fontSize: 9),
                ),
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: '分类',
                  labelStyle: TextStyle(fontSize: 9),
                  helperText: '如：厨房电器、智能穿戴、居家日用',
                  helperStyle: TextStyle(fontSize: 7),
                ),
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: '价格（元）',
                  labelStyle: TextStyle(fontSize: 9),
                ),
                style: const TextStyle(fontSize: 10),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(fontSize: 10)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0;
              final category = categoryController.text.trim();
              if (name.isEmpty || price <= 0 || category.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写完整信息'), behavior: SnackBarBehavior.floating));
                return;
              }
              setState(() {
                _goods.add(Goods(
                  id: 'g${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  subtitle: '',
                  category: category,
                  price: price,
                  originalPrice: price * 1.2,
                  image: '',
                  rating: 5.0,
                  sales: 0,
                ));
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('商品已添加'), behavior: SnackBarBehavior.floating));
            },
            child: const Text('添加', style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  void _deleteGoods(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除商品', style: TextStyle(fontSize: 12)),
        content: Text('确定删除「${_goods[index].name}」？', style: const TextStyle(fontSize: 10)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消', style: TextStyle(fontSize: 10))),
          TextButton(
            onPressed: () {
              setState(() => _goods.removeAt(index));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('商品已删除'), behavior: SnackBarBehavior.floating));
            },
            child: const Text('删除', style: TextStyle(fontSize: 10, color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5722),
        foregroundColor: Colors.white,
        title: const Text('商品管理', style: TextStyle(fontSize: 12)),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, size: 18), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.add, size: 18), onPressed: _addGoods),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _goods.length,
        itemBuilder: (context, index) {
          final g = _goods[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(6)),
                  child: Icon(Icons.inventory_2, size: 24, color: const Color(0xFFE0E0E0)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(color: const Color(0xFFFF5722).withOpacity(0.1), borderRadius: BorderRadius.circular(3)),
                            child: Text(g.category, style: const TextStyle(fontSize: 7, color: Color(0xFFFF5722))),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.star, size: 8, color: const Color(0xFFFF9800)),
                          Text(g.rating.toString(), style: const TextStyle(fontSize: 7, color: Color(0xFF757575))),
                          const SizedBox(width: 4),
                          Text('销量${g.sales}', style: const TextStyle(fontSize: 7, color: Color(0xFF9E9E9E))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(g.priceText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                          const SizedBox(width: 4),
                          Text(g.originalPriceText, style: const TextStyle(fontSize: 8, color: Color(0xFFBDBDBD), decoration: TextDecoration.lineThrough)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF757575)),
                      onPressed: () => _editGoods(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                      onPressed: () => _deleteGoods(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGoods,
        backgroundColor: const Color(0xFFFF5722),
        icon: const Icon(Icons.add, size: 16),
        label: const Text('添加商品', style: TextStyle(fontSize: 9)),
      ),
    );
  }
}
