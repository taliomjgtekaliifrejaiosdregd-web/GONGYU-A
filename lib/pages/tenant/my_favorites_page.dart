import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/tenant_order.dart';

/// ============================================================
//  租客 - 我的收藏
// ============================================================
class MyFavoritesPage extends StatefulWidget {
  const MyFavoritesPage({super.key});
  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<FavoriteItem> _favorites = [
    FavoriteItem(id: 'F1', type: FavoriteType.room, title: '阳光城 A座 301', subtitle: '朝阳区望京街道 · 2室1厅1卫 · 78m\u00b2', price: 4500, addedAt: DateTime(2026, 4, 10)),
    FavoriteItem(id: 'F2', type: FavoriteType.room, title: '龙湖时代 2号楼 1502', subtitle: '海淀区中关村 · 1室1厅1卫 · 52m\u00b2', price: 3800, addedAt: DateTime(2026, 4, 8)),
    FavoriteItem(id: 'F3', type: FavoriteType.room, title: '华润橡树湾 5号楼 801', subtitle: '天河区珠江新城 · 2室1厅1卫 · 65m\u00b2', price: 5200, addedAt: DateTime(2026, 4, 5)),
    FavoriteItem(id: 'F4', type: FavoriteType.goods, title: '小米智能手环9', subtitle: '小米官方旗舰店 · 石墨黑', price: 249, addedAt: DateTime(2026, 4, 12)),
    FavoriteItem(id: 'F5', type: FavoriteType.goods, title: 'AirPods Pro 2', subtitle: 'Apple授权专营店 · MagSafe充电盒', price: 1799, addedAt: DateTime(2026, 3, 28)),
    FavoriteItem(id: 'F6', type: FavoriteType.goods, title: '美的电热水壶', subtitle: '美的官方旗舰店 · 白色 1.7L', price: 129, addedAt: DateTime(2026, 3, 20)),
  ];

  List<FavoriteItem> get _roomFavs => _favorites.where((f) => f.type == FavoriteType.room).toList();
  List<FavoriteItem> get _goodsFavs => _favorites.where((f) => f.type == FavoriteType.goods).toList();

  void _remove(int index, FavoriteType type) {
    setState(() {
      if (type == FavoriteType.room) {
        _roomFavs.removeAt(index);
      } else {
        _goodsFavs.removeAt(index);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已取消收藏'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: '撤销', onPressed: () {}),
      ),
    );
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

  String _dateStr(DateTime d) => '${d.month}-${d.day}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('我的收藏', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: const Color(0xFF9E9E9E),
          indicatorColor: const Color(0xFF6366F1),
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: [
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('全部'),
              const SizedBox(width: 4),
              _Count(''),
            ])),
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('房源'),
              const SizedBox(width: 4),
              _Count('${_roomFavs.length}'),
            ])),
            Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('好物'),
              const SizedBox(width: 4),
              _Count('${_goodsFavs.length}'),
            ])),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FavList(favorites: _favorites, onRemove: (i) => _remove(i, _favorites[i].type)),
          _FavList(favorites: _roomFavs, onRemove: (i) => _remove(i, FavoriteType.room), showRoom: true),
          _FavList(favorites: _goodsFavs, onRemove: (i) => _remove(i, FavoriteType.goods)),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  final String label;
  const _Count(this.label);
  @override
  Widget build(BuildContext context) {
    final n = int.tryParse(label) ?? 0;
    if (n == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }
}

class _FavList extends StatelessWidget {
  final List<FavoriteItem> favorites;
  final Function(int) onRemove;
  final bool showRoom;

  const _FavList({required this.favorites, required this.onRemove, this.showRoom = false});

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.favorite_outline, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('暂无收藏', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
      ]));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: showRoom ? 1 : 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: showRoom ? 2.8 : 0.72,
      ),
      itemCount: favorites.length,
      itemBuilder: (_, i) {
        final f = favorites[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 图片区
            Expanded(
              flex: showRoom ? 1 : 3,
              child: Container(
                decoration: BoxDecoration(
                  color: f.type == FavoriteType.room ? const Color(0xFFE8E0FF) : const Color(0xFFE0F0FF),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Stack(children: [
                  Center(child: Icon(
                    f.type == FavoriteType.room ? Icons.home : Icons.shopping_bag,
                    size: showRoom ? 40 : 36,
                    color: const Color(0xFF6366F1).withValues(alpha: 0.6),
                  )),
                  Positioned(top: 6, right: 6, child: GestureDetector(
                    onTap: () => onRemove(i),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                      child: const Icon(Icons.favorite, color: Color(0xFFEF4444), size: 16),
                    ),
                  )),
                  if (f.type == FavoriteType.goods)
                    Positioned(top: 6, left: 6, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(6)),
                      child: const Text('好物', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
                    )),
                  if (showRoom || f.type == FavoriteType.room)
                    Positioned(top: 6, left: 6, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(6)),
                      child: const Text('房源', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
                    )),
                ]),
              ),
            ),
            // 信息区
            Expanded(
              flex: showRoom ? 1 : 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (showRoom || f.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(f.subtitle ?? '', style: TextStyle(fontSize: 10, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                  const Spacer(),
                  Row(children: [
                    Text('\u00a5${f.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                    if (showRoom) const Text('/月', style: TextStyle(fontSize: 10, color: Color(0xFFEF4444))),
                    const Spacer(),
                    Text('${f.addedAt.month}-${f.addedAt.day}', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                  ]),
                ]),
              ),
            ),
          ]),
        );
      },
    );
  }
}
