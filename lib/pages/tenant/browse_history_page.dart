import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/tenant_order.dart';

/// ============================================================
//  租客 - 浏览历史
// ============================================================
class BrowseHistoryPage extends StatefulWidget {
  const BrowseHistoryPage({super.key});
  @override
  State<BrowseHistoryPage> createState() => _BrowseHistoryPageState();
}

class _BrowseHistoryPageState extends State<BrowseHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 按日期分组
  final Map<String, List<HistoryItem>> _historyByDate = {
    '今天': [
      HistoryItem(id: 'H1', type: FavoriteType.room, title: '阳光城 A座 301', subtitle: '朝阳区望京 · 2室1厅', price: 4500, viewedAt: DateTime.now()),
      HistoryItem(id: 'H2', type: FavoriteType.goods, title: '小米智能手环9', subtitle: '小米官方旗舰店', price: 249, viewedAt: DateTime.now()),
      HistoryItem(id: 'H3', type: FavoriteType.goods, title: 'AirPods Pro 2', subtitle: 'Apple授权专营店', price: 1799, viewedAt: DateTime.now()),
    ],
    '昨天': [
      HistoryItem(id: 'H4', type: FavoriteType.room, title: '龙湖时代 2号楼 1502', subtitle: '海淀区中关村 · 1室1厅', price: 3800, viewedAt: DateTime(2026, 4, 18)),
      HistoryItem(id: 'H5', type: FavoriteType.room, title: '万科城市花园 7单元 1201', subtitle: '浦东新区陆家嘴 · 3室2厅', price: 6800, viewedAt: DateTime(2026, 4, 18)),
    ],
    '4月15日': [
      HistoryItem(id: 'H6', type: FavoriteType.goods, title: 'OLAY淡斑小白瓶', subtitle: 'OLAY玉兰油官方旗舰店', price: 259, viewedAt: DateTime(2026, 4, 15)),
      HistoryItem(id: 'H7', type: FavoriteType.goods, title: '安踏运动T恤', subtitle: '安踏官方outlets店', price: 89, viewedAt: DateTime(2026, 4, 15)),
    ],
    '4月10日': [
      HistoryItem(id: 'H8', type: FavoriteType.room, title: '华润橡树湾 5号楼 801', subtitle: '天河区珠江新城 · 2室1厅', price: 5200, viewedAt: DateTime(2026, 4, 10)),
    ],
    '更早': [
      HistoryItem(id: 'H9', type: FavoriteType.goods, title: '美的电热水壶', subtitle: '美的官方旗舰店', price: 129, viewedAt: DateTime(2026, 3, 28)),
      HistoryItem(id: 'H10', type: FavoriteType.goods, title: 'ThinkPad蓝牙鼠标', subtitle: '联想官方旗舰店', price: 89, viewedAt: DateTime(2026, 3, 15)),
    ],
  };

  bool _showRooms = true;
  bool _showGoods = true;

  void _removeItem(String dateKey, int index) {
    setState(() {
      final items = _historyByDate[dateKey]!;
      items.removeAt(index);
      if (items.isEmpty) _historyByDate.remove(dateKey);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('已删除'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)),
    );
  }

  void _clearAll() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('清空历史'),
      content: const Text('确定清空全部浏览历史？此操作不可撤销'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        TextButton(onPressed: () {
          Navigator.pop(context);
          setState(() => _historyByDate.clear());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已清空全部历史'), behavior: SnackBarBehavior.floating),
          );
        }, style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('清空')),
      ],
    ));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _timeStr(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('浏览历史', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(onPressed: _clearAll, child: const Text('清空', style: TextStyle(fontSize: 13, color: Color(0xFFEF4444)))),
        ],
      ),
      body: Column(children: [
        // 过滤器
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(children: [
            const Text('显示：', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('房源', style: TextStyle(fontSize: 12)),
              selected: _showRooms,
              onSelected: (v) => setState(() => _showRooms = v),
              selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
              checkmarkColor: const Color(0xFF6366F1),
              labelStyle: TextStyle(fontSize: 12, color: _showRooms ? const Color(0xFF6366F1) : Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('好物', style: TextStyle(fontSize: 12)),
              selected: _showGoods,
              onSelected: (v) => setState(() => _showGoods = v),
              selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
              checkmarkColor: const Color(0xFF6366F1),
              labelStyle: TextStyle(fontSize: 12, color: _showGoods ? const Color(0xFF6366F1) : Colors.grey.shade600),
            ),
          ]),
        ),
        const Divider(height: 1),
        // 历史列表
        Expanded(
          child: _historyByDate.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('暂无浏览历史', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _historyByDate.length,
                  itemBuilder: (_, i) {
                    final dateKey = _historyByDate.keys.elementAt(i);
                    var items = _historyByDate[dateKey]!;
                    if (!_showRooms) items = items.where((it) => it.type != FavoriteType.room).toList();
                    if (!_showGoods) items = items.where((it) => it.type != FavoriteType.goods).toList();
                    if (items.isEmpty) return const SizedBox.shrink();

                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8, top: i == 0 ? 0 : 8),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(6)),
                            child: Text(dateKey, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ),
                      ...items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return _HistoryCard(
                          item: item,
                          onRemove: () => _removeItem(dateKey, idx),
                          timeStr: _timeStr(item.viewedAt),
                        );
                      }),
                    ]);
                  },
                ),
        ),
      ]),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback onRemove;
  final String timeStr;

  const _HistoryCard({required this.item, required this.onRemove, required this.timeStr});

  @override
  Widget build(BuildContext context) {
    final isRoom = item.type == FavoriteType.room;
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: isRoom ? const Color(0xFFE8E0FF) : const Color(0xFFE0F0FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isRoom ? Icons.home : Icons.shopping_bag,
              size: 28,
              color: const Color(0xFF6366F1).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(color: isRoom ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFF6366F1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                child: Text(isRoom ? '房源' : '好物', style: TextStyle(fontSize: 9, color: isRoom ? const Color(0xFF10B981) : const Color(0xFF6366F1), fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 4),
            Text(item.subtitle ?? '', style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              Text('\u00a5${item.price?.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
              if (isRoom) const Text('/月', style: TextStyle(fontSize: 10, color: Color(0xFFEF4444))),
              const Spacer(),
              Text(timeStr, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ]),
          ])),
        ]),
      ),
    );
  }
}
