import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/models/room.dart';
import 'package:gongyu_guanjia/pages/room_detail_page.dart';
import 'package:gongyu_guanjia/pages/map_page.dart';
import 'package:gongyu_guanjia/pages/services_page.dart';
import 'package:gongyu_guanjia/pages/profile_page.dart';
import 'package:gongyu_guanjia/pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _selectedType = '全部';
  String _sortBy = '默认排序';
  final TextEditingController _searchController = TextEditingController();
  List<Room> _rooms = [];

  @override
  void initState() {
    super.initState();
    _rooms = MockService.rooms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: '地图'),
          BottomNavigationBarItem(icon: Icon(Icons.miscellaneous_services_outlined), activeIcon: Icon(Icons.miscellaneous_services), label: '服务'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const MapPage();
      case 2:
        return const ServicesPage();
      case 3:
        return const ProfilePage();
      default:
        return _buildHomeTab();
    }
  }

  // ==================== 首页 ====================
  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        // 搜索栏
        SliverAppBar(
          floating: true,
          pinned: true,
          expandedHeight: 130,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF009624)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text('上海', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                          Spacer(),
                          GestureDetector(
                            onTap: () => _showLoginPrompt(),
                            child: Row(
                              children: [
                                Icon(Icons.login, color: Colors.white, size: 18),
                                SizedBox(width: 4),
                                Text('登录', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('品质租房选自优租', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('让租房更简单', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索区域、小区、地铁站',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF00C853)),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.tune, color: Color(0xFF757575)),
                    onPressed: () => _showFilterSheet(),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (v) => _search(),
              ),
            ),
          ),
        ),
        // 分类标签
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // 房源类型
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['全部', '整租', '合租', '公寓'].map((type) {
                      final isSelected = _selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedType = type),
                          selectedColor: Color(0xFF00C853).withOpacity(0.15),
                          checkmarkColor: Color(0xFF00C853),
                          backgroundColor: Color(0xFFF5F5F5),
                          labelStyle: TextStyle(
                            color: isSelected ? Color(0xFF00C853) : Color(0xFF757575),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide.none,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 8),
                // 排序
                Row(
                  children: ['默认排序', '价格低→高', '价格高→低', '最新发布'].map((sort) {
                    final isSelected = _sortBy == sort;
                    return GestureDetector(
                      onTap: () => setState(() => _sortBy = sort),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          sort,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Color(0xFF00C853) : Color(0xFF757575),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        // 房源列表
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildRoomCard(_rooms[index]),
              childCount: _rooms.length,
            ),
          ),
        ),
        // 底部间距
        SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildRoomCard(Room room) {
    return GestureDetector(
      onTap: () => _openRoomDetail(room),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            Stack(
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Icon(Icons.apartment, size: 48, color: Color(0xFFBDBDBD)),
                  ),
                ),
                // 类型标签
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: room.roomType == '整租' ? Color(0xFF00C853) : Color(0xFFFF6D00),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      room.roomType,
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                // 收藏按钮
                Positioned(
                  right: 12,
                  top: 12,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(room),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        room.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: room.isFavorite ? Color(0xFFFF5252) : Color(0xFF757575),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 信息区域
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Text(room.district, style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                      SizedBox(width: 8),
                      Text('·', style: TextStyle(color: Color(0xFFBDBDBD))),
                      SizedBox(width: 8),
                      Text(room.community, style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(room.layoutText, style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        room.priceText,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF5722)),
                      ),
                      Text('/月', style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                      Spacer(),
                      Icon(Icons.access_time, size: 12, color: Color(0xFF9E9E9E)),
                      SizedBox(width: 4),
                      Text(_formatTime(room.publishedAt), style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRoomDetail(Room room) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailPage(room: room)));
  }

  void _toggleFavorite(Room room) {
    setState(() {
      final index = _rooms.indexWhere((r) => r.id == room.id);
      if (index != -1) {
        _rooms[index] = Room(
          id: room.id,
          title: room.title,
          type: room.type,
          address: room.address,
          communityId: room.communityId,
          communityName: room.communityName,
          area: room.area,
          layout: room.layout,
          price: room.price,
          status: room.status,
          images: room.images,
          facilities: room.facilities,
          description: room.description,
          tenantName: room.tenantName,
          tenantPhone: room.tenantPhone,
          rentExpireDate: room.rentExpireDate,
          publishedAt: room.publishedAt,
        );
      }
    });
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '未知';
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 1) return '刚刚';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${time.month}-${time.day}';
  }

  void _search() {
    // TODO: 搜索
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('筛选', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: 16),
            Text('租金范围', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Row(
              children: ['不限', '1000以下', '1000-2000', '2000-3000', '3000-5000', '5000以上']
                  .map((r) => Padding(padding: const EdgeInsets.only(right: 8, bottom: 8), child: FilterChip(label: Text(r, style: TextStyle(fontSize: 12)), selected: false, onSelected: (_) {})))
                  .toList(),
            ),
            SizedBox(height: 16),
            Text('户型', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Wrap(
              children: ['不限', '单间', '一室', '两室', '三室', '四室+']
                  .map((t) => Padding(padding: const EdgeInsets.only(right: 8, bottom: 8), child: FilterChip(label: Text(t, style: TextStyle(fontSize: 12)), selected: false, onSelected: (_) {})))
                  .toList(),
            ),
            Spacer(),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text('重置'))),
                SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('确定'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginPrompt() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }
}
