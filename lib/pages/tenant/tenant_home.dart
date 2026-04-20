import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/models/room.dart';
import 'package:gongyu_guanjia/core/theme/app_theme.dart';
import 'package:gongyu_guanjia/pages/login_page.dart';
import 'package:gongyu_guanjia/pages/room_detail_page.dart';
import 'package:gongyu_guanjia/pages/ai_chat_page.dart';
import 'package:gongyu_guanjia/pages/shopping_page.dart';
import 'package:gongyu_guanjia/pages/map_page.dart';
import 'package:gongyu_guanjia/pages/profile_page.dart';
import 'package:gongyu_guanjia/pages/tenant/bill_payment_page.dart';
import 'package:gongyu_guanjia/pages/tenant/utility_payment_page.dart';
import 'package:gongyu_guanjia/pages/tenant/repair_report_page.dart';

// ==================== 房源数据辅助 ====================
/// 获取已发布且可租的房源（对接房东端房源管理）
List<Room> _getPublishedRooms() {
  return MockService.rooms.where((r) => r.isPublished && r.isAvailable).toList();
}


// ==================== 顶部横幅轮播 ====================

// 账户名称辅助函数
String _avatarInitial(String name) {
  if (name.isEmpty) return '?';
  final clean = name.replaceFirst(RegExp(r'^(先生|女士|小姐|老板|房东|租客)'), '').trim();
  if (clean.isEmpty) return name[0];
  return clean[0];
}

String _shortName(String name) {
  if (name.isEmpty) return '访客';
  final clean = name.replaceFirst(RegExp(r'^(先生|女士|小姐|老板|房东)'), '').trim();
  if (clean.isEmpty) return name.length <= 2 ? name : name.substring(0, 2);
  return clean.length <= 2 ? clean : clean.substring(0, 2);
}


// ==================== è´¦æ·åç§°è¾å©å½æ° ====================
class _BannerItem {
  final String title;
  final String subtitle;
  final Color color1;
  final Color color2;
  final IconData icon;
  final Widget? viewRoute;  // 立即查看跳转的目标页面

  const _BannerItem(this.title, this.subtitle, this.color1, this.color2, this.icon, [this.viewRoute]);
}

class _BannerCarousel extends StatefulWidget {
  final VoidCallback onMapTap;
  const _BannerCarousel({required this.onMapTap});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _banners = [
    _BannerItem(
      '新用户首月租金立减 ¥500',
      '认证即享优惠，快来体验吧',
      const Color(0xFF6366F1),
      const Color(0xFFA5B4FC),
      Icons.campaign,
      UtilityPaymentPage(tenantPhone: MockService.currentUser.phone),
    ),
    _BannerItem(
      '押一付一房源特惠',
      '海量精选房源，租金月付无忧',
      const Color(0xFFEF4444),
      const Color(0xFFFF8A65),
      Icons.local_offer,
      const ShoppingPage(),
    ),
    _BannerItem(
      '地铁沿线房源推荐',
      '出门即地铁，通勤零压力',
      const Color(0xFF06B6D4),
      const Color(0xFF64B5F6),
      Icons.subway,
      const MapPage(),
    ),
    _BannerItem(
      '精装修公寓集合',
      '品质生活，从这里开始',
      const Color(0xFF7B61FF),
      const Color(0xFFB39DDB),
      Icons.home_work,
      const RepairReportPage(),
    ),
  ];
  int _current = 0;
  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: 0);
    // Auto-scroll
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted || !_pageCtrl.hasClients) return false;
      final next = (_current + 1) % _banners.length;
      _pageCtrl.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      setState(() => _current = next);
      return true;
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _banners.length,
            itemBuilder: (context, i) => _BannerCard(banner: _banners[i], onTap: widget.onMapTap),
          ),
          // Page indicators
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (i) => Container(
                width: i == _current ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i == _current ? Colors.white : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final _BannerItem banner;
  final VoidCallback onTap;
  const _BannerCard({required this.banner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [banner.color1, banner.color2], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(banner.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(banner.subtitle, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 9)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      if (banner.viewRoute != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => banner.viewRoute!));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        banner.viewRoute != null ? '立即查看' : '',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(banner.icon, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 搜索框（参考贝壳） ====================
class _BeikeSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCity;
  final VoidCallback onCityTap;
  final VoidCallback onMapTap;
  final void Function(String) onSearch;

  const _BeikeSearchBar({
    required this.searchController,
    required this.selectedCity,
    required this.onCityTap,
    required this.onMapTap,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          child: Row(
            children: [
              // 城市选择
              GestureDetector(
                onTap: onCityTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(selectedCity, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),
              // 搜索框（缩短一半）
              SizedBox(
                width: 130,
                child: GestureDetector(
                  onTap: () => _showBeikeSearchSheet(context),
                  child: Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on, color: Color(0xFF6366F1), size: 15),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onSubmitted: onSearch,
                            decoration: const InputDecoration(
                              hintText: '搜索',
                              hintStyle: TextStyle(fontSize: 9.5, color: Color(0xFFBDBDBD)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 9.5),
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // 搜房按钮
              GestureDetector(
                onTap: onMapTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 15),
                      SizedBox(width: 4),
                      Text('搜房', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              // è´¦æ·å¤´å + ç®ç§°
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ä¸ªäººä¸­å¿'), behavior: SnackBarBehavior.floating),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _avatarInitial(MockService.currentUser.name),
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 30),
                      child: Text(
                        _shortName(MockService.currentUser.name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
    ],
          ),
        ),
      ),
    );
  }

  void _showBeikeSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => _BeikeSearchSheet(searchController: searchController, onSearch: onSearch),
      ),
    );
  }
}

class _BeikeSearchSheet extends StatefulWidget {
  final TextEditingController searchController;
  final void Function(String) onSearch;
  const _BeikeSearchSheet({required this.searchController, required this.onSearch});

  @override
  State<_BeikeSearchSheet> createState() => _BeikeSearchSheetState();
}

class _BeikeSearchSheetState extends State<_BeikeSearchSheet> {
  final TextEditingController _ctrl = TextEditingController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索头
        Container(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on, color: Color(0xFF6366F1), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: '输入小区名/地铁站/商圈/房源',
                            hintStyle: TextStyle(fontSize: 10),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 10),
                          onSubmitted: (v) {
                            Navigator.pop(context);
                            widget.onSearch(v);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  if (_ctrl.text.isNotEmpty) widget.onSearch(_ctrl.text);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(16)),
                  child: const Text('搜索', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        // 内容
        Expanded(
          child: ListView(
            controller: null,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              // 快捷筛选
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _QuickFilter('整租', Icons.home_work),
                    _QuickFilter('合租', Icons.meeting_room),
                    _QuickFilter('月付', Icons.calendar_month),
                    _QuickFilter('近地铁', Icons.subway),
                    _QuickFilter('精装修', Icons.star),
                    _QuickFilter('押一付一', Icons.payment),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 热门搜索
              Row(children: [
                const Icon(Icons.local_fire_department, size: 14, color: Color(0xFFEF4444)),
                const SizedBox(width: 4),
                const Text('热搜', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.refresh, size: 12, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                const Text('换一换', style: TextStyle(fontSize: 8, color: Color(0xFF9E9E9E))),
              ]),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  _HotTag('陆家嘴', Icons.subway, const Color(0xFF06B6D4)),
                  _HotTag('浦东大道', Icons.subway, const Color(0xFF06B6D4)),
                  _HotTag('前滩', Icons.trending_up, const Color(0xFFEF4444)),
                  _HotTag('张江高科', Icons.subway, const Color(0xFF06B6D4)),
                  _HotTag('静安寺', Icons.business, const Color(0xFF7B61FF)),
                  _HotTag('徐家汇', Icons.subway, const Color(0xFF06B6D4)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('猜你想找', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  _GuessTag('精装修', Icons.star),
                  _GuessTag('押一付一', Icons.payment),
                  _GuessTag('近地铁', Icons.subway),
                  _GuessTag('月付', Icons.calendar_month),
                  _GuessTag('高层', Icons.apartment),
                  _GuessTag('有电梯', Icons.elevator),
                  _GuessTag('南向', Icons.wb_sunny),
                  _GuessTag('停车位', Icons.local_parking),
                ],
              ),
              const SizedBox(height: 16),
              // 区域
              const Text('热门区域', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _DistrictRow('浦东新区', '1200+ 套', true),
              _DistrictRow('黄浦区', '800+ 套', false),
              _DistrictRow('徐汇区', '900+ 套', false),
              _DistrictRow('静安区', '700+ 套', false),
              _DistrictRow('长宁区', '600+ 套', false),
              const SizedBox(height: 16),
              // 地铁线
              const Text('地铁沿线', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _SubwayRow('2号线', '世纪大道 · 南京西路', const Color(0xFF4CAF50)),
              _SubwayRow('1号线', '徐家汇 · 人民广场', const Color(0xFFEF4444)),
              _SubwayRow('11号线', '迪士尼 · 江苏路', const Color(0xFFF59E0B)),
              _SubwayRow('7号线', '龙华中路 · 静安寺', const Color(0xFF9C27B0)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickFilter extends StatelessWidget {
  final String label;
  final IconData icon;
  const _QuickFilter(this.label, this.icon);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3))),
    child: Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFF6366F1)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF6366F1))),
      ],
    ),
  );
}

class _HotTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _HotTag(this.label, this.icon, this.color);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('搜索：$label'), behavior: SnackBarBehavior.floating));
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );
}

class _GuessTag extends StatelessWidget {
  final String label;
  final IconData icon;
  const _GuessTag(this.label, this.icon);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('筛选：$label'), behavior: SnackBarBehavior.floating));
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF757575)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF424242))),
        ],
      ),
    ),
  );
}

class _DistrictRow extends StatelessWidget {
  final String name;
  final String count;
  final bool selected;
  const _DistrictRow(this.name, this.count, this.selected);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: selected ? const Color(0xFF6366F1).withOpacity(0.08) : const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.location_city, size: 14, color: selected ? const Color(0xFF6366F1) : const Color(0xFF757575)),
        const SizedBox(width: 8),
        Expanded(child: Text(name, style: TextStyle(fontSize: 10, color: selected ? const Color(0xFF6366F1) : const Color(0xFF424242)))),
        Text(count, style: TextStyle(fontSize: 8, color: selected ? const Color(0xFF6366F1) : const Color(0xFF9E9E9E))),
        if (selected) ...[
          const SizedBox(width: 6),
          const Icon(Icons.check_circle, size: 14, color: Color(0xFF6366F1)),
        ],
      ],
    ),
  );
}

class _SubwayRow extends StatelessWidget {
  final String line;
  final String stations;
  final Color color;
  const _SubwayRow(this.line, this.stations, this.color);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
    child: Row(
      children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          child: Center(child: Text(line, style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(stations, style: const TextStyle(fontSize: 9))),
        const Icon(Icons.chevron_right, size: 14, color: Color(0xFFBDBDBD)),
      ],
    ),
  );
}

// ==================== 房源卡片 ====================
class _RoomCard extends StatelessWidget {
  final Room room;
  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _TenantRoomDetail(room: room))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // 图片
            Container(
              width: 100, height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(Icons.apartment, size: 36, color: const Color(0xFF6366F1).withOpacity(0.4))),
                  if (room.isFavorite)
                    Positioned(
                      top: 4, left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(3)),
                        child: const Text('优选', style: TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 10, color: Color(0xFF9E9E9E)),
                      const SizedBox(width: 2),
                      Expanded(child: Text(room.address, style: const TextStyle(fontSize: 8, color: Color(0xFF9E9E9E)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4, runSpacing: 3,
                    children: [
                      if (room.facilities.isNotEmpty) _Tag(Icons.subway, '近地铁', const Color(0xFF06B6D4)),
                      ...room.facilities.take(2).map((t) => _Tag(Icons.label, t, const Color(0xFF9E9E9E))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(room.priceText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                      const Text(' · ', style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                      Text(room.layout, style: const TextStyle(fontSize: 8, color: Color(0xFF757575))),
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
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Tag(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(3)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 8, color: color),
        const SizedBox(width: 2),
        Text(label, style: TextStyle(fontSize: 7, color: color)),
      ],
    ),
  );
}


// ==================== 精选房源网格卡片(竖版) ====================
class _RoomGridCard extends StatelessWidget {
  final Room room;
  const _RoomGridCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final img = room.images.isNotEmpty
        ? room.images.first
        : 'https://picsum.photos/seed/${room.id}/400/300';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _TenantRoomDetail(room: room))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                img,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 110,
                  color: const Color(0xFFE8EAFE),
                  child: const Center(child: Icon(Icons.apartment, size: 40, color: Color(0xFF6366F1))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 10, color: Color(0xFF9E9E9E)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          room.communityName,
                          style: const TextStyle(fontSize: 9, color: Color(0xFF9E9E9E)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '¥${room.price.toInt()}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                      ),
                      const Text('/月', style: TextStyle(fontSize: 9, color: Color(0xFF9E9E9E))),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          room.layout,
                          style: const TextStyle(fontSize: 9, color: Color(0xFF6366F1)),
                        ),
                      ),
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
}

// ==================== 房源详情 ====================
class _TenantRoomDetail extends StatelessWidget {
  final Room room;
  const _TenantRoomDetail({required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF6366F1),
            leading: IconButton(
              icon: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle), child: const Icon(Icons.arrow_back, size: 16, color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(icon: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle), child: const Icon(Icons.favorite_border, size: 16, color: Colors.white)), onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已添加收藏'), behavior: SnackBarBehavior.floating),
                );
              }),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFE8F5E9),
                child: Center(child: Icon(Icons.apartment, size: 80, color: const Color(0xFF6366F1).withOpacity(0.3))),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(color: Colors.white, padding: const EdgeInsets.all(14), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(room.priceText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                      const Text('/月', style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                      const Spacer(),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('已认证', style: TextStyle(fontSize: 8, color: Color(0xFF6366F1)))),
                    ]),
                    const SizedBox(height: 8),
                    Text(room.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on, size: 12, color: Color(0xFF9E9E9E)),
                      const SizedBox(width: 2),
                      Expanded(child: Text(room.address, style: const TextStyle(fontSize: 9, color: Color(0xFF9E9E9E)))),
                    ]),
                    const SizedBox(height: 10),
                    Wrap(spacing: 6, runSpacing: 6, children: room.facilities.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(4)), child: Text(t, style: const TextStyle(fontSize: 9, color: Color(0xFF757575))))).toList()),
                  ],
                )),
                const SizedBox(height: 10),
                Container(color: Colors.white, padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('房屋配置', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(children: [_Cf(Icons.bed, '床'), _Cf(Icons.kitchen, '厨房'), _Cf(Icons.wifi, 'WiFi'), _Cf(Icons.ac_unit, '空调'), _Cf(Icons.local_laundry_service, '洗衣')]),
                  const SizedBox(height: 8),
                  Row(children: [_Cf(Icons.tv, '电视'), _Cf(Icons.hot_tub, '热水器'), _Cf(Icons.elevator, '电梯'), _Cf(Icons.local_parking, '车位'), _Cf(Icons.cleaning_services, '保洁')]),
                ])),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]),
        child: SafeArea(
          child: Row(
            children: [
              OutlinedButton.icon(onPressed: () => _showContactSheet(context), icon: const Icon(Icons.phone, size: 14), label: const Text('联系房东'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF6366F1), side: const BorderSide(color: Color(0xFF6366F1)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(onPressed: () => _showReserveSheet(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10)), child: const Text('立即预约', style: TextStyle(fontSize: 11)))),
            ],
          ),
        ),
      ),
    );
  }

  void _showReserveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('立即预约看房', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Container(
                width: 60,
                height: 50,
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.apartment, color: Color(0xFF6366F1), size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(room.title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(room.address, style: const TextStyle(fontSize: 8, color: Color(0xFF9E9E9E))),
              ])),
              Text(room.priceText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
            ]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('预约成功！我们将尽快联系您'), behavior: SnackBarBehavior.floating),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('确认预约', style: TextStyle(fontSize: 11)),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(30)),
            child: const Icon(Icons.person, color: Color(0xFF6366F1), size: 30),
          ),
          const SizedBox(height: 12),
          const Text('房东联系方式', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${room.landlordName.isEmpty ? "房东" : room.landlordName}', style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ContactBtn(Icons.phone, '电话联系', const Color(0xFF10B981), () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('拨打电话：${room.landlordPhone.isEmpty ? "暂无" : room.landlordPhone}'), behavior: SnackBarBehavior.floating),
                );
              }),
              _ContactBtn(Icons.chat, '在线沟通', const Color(0xFF6366F1), () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('即将跳转到聊天页面'), behavior: SnackBarBehavior.floating),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

class _Cf extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Cf(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [Icon(icon, size: 20, color: const Color(0xFF6366F1)), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 8, color: Color(0xFF757575)))]));
}

class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ContactBtn(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(26)),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    ]),
  );
}

// ==================== 租客首页主体 ====================
class _TenantMainPage extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCity;
  final VoidCallback onCityTap;
  final void Function(String) onSearchSubmit;

  const _TenantMainPage({
    required this.searchController,
    required this.selectedCity,
    required this.onCityTap,
    required this.onSearchSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 顶部搜索 + 筛选
        SliverToBoxAdapter(
          child: _BeikeSearchBar(
            searchController: searchController,
            selectedCity: selectedCity,
            onCityTap: onCityTap,
            onMapTap: () => _showMapSheet(context),
            onSearch: onSearchSubmit,
          ),
        ),

        // 快捷筛选（横排）
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip('整租', true),
                  _FilterChip('合租', false),
                  _FilterChip('月付', false),
                  _FilterChip('押一付一', false),
                  _FilterChip('精装修', false),
                  _FilterChip('近地铁', false),
                ],
              ),
            ),
          ),
        ),

        // 轮播横幅
        SliverToBoxAdapter(
          child: _BannerCarousel(onMapTap: () => _showMapSheet(context)),
        ),

        // Banner
        SliverToBoxAdapter(child: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const UtilityPaymentPage(tenantPhone: '13800000001'),
              )),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('在线缴费', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('本月待缴水电费 ¥127.30，点击立即缴纳', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: const Text('去缴费', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )),

        // 热门分类
        SliverToBoxAdapter(child: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('热门服务', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _CatCard(Icons.home_work, '整租', const Color(0xFF6366F1))),
              Expanded(child: _CatCard(Icons.meeting_room, '合租', const Color(0xFF06B6D4))),
              Expanded(child: _CatCard(Icons.apartment, '公寓', const Color(0xFF9C27B0))),
              Expanded(child: _CatCard(Icons.shopping_bag, '好货', const Color(0xFFE91E63))),
              Expanded(child: _CatCard(Icons.payment, '缴费', const Color(0xFFF59E0B))),
              Expanded(child: _CatCard(Icons.build, '报修', const Color(0xFF10B981))),
            ]),
          ]),
        )),

        // 精选房源标题
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Row(children: [
            const Text('精选房源', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Text('查看更多', style: TextStyle(fontSize: 9, color: Color(0xFF9E9E9E))),
            const Icon(Icons.chevron_right, size: 14, color: Color(0xFFBDBDBD)),
          ]),
        )),

        // 精选房源列表 (两列网格)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final _hot = _getPublishedRooms();
                if (_hot.isEmpty) return const SizedBox();
                final room = _hot[index % _hot.length];
                return _RoomGridCard(room: room);
              },
              childCount: _getPublishedRooms().isEmpty ? 0 : 6,
            ),
          ),
        ),
      ],
    );
  }

  void _showMapSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, __) => Column(children: [
          Container(padding: const EdgeInsets.all(12), child: Row(children: [
            const Text('地图找房', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.pop(context)),
          ])),
          Expanded(child: MapPage()),
        ]),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _FilterChip(this.label, this.selected);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: selected ? const Color(0xFF6366F1).withOpacity(0.12) : Colors.white.withOpacity(0.25),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: selected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.4)),
    ),
    child: Text(label, style: TextStyle(fontSize: 9, color: selected ? const Color(0xFF6366F1) : Colors.white)),
  );
}

class _CatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _CatCard(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (label == '缴费') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const UtilityPaymentPage(tenantPhone: '13800000001')));
        } else if (label == '报修') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const RepairReportPage()));
        }
      },
      child: Column(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 22)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF424242))),
      ]),
    );
  }
}

// ==================== 租客首页入口 ====================
class TenantHomePage extends StatefulWidget {
  const TenantHomePage({super.key});

  @override
  State<TenantHomePage> createState() => _TenantHomePageState();
}

class _TenantHomePageState extends State<TenantHomePage> {
  int _currentIndex = 0;
  String _selectedCity = '上海';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _TenantMainPage(
            searchController: _searchController,
            selectedCity: _selectedCity,
            onCityTap: () => _showCitySheet(),
            onSearchSubmit: (k) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('搜索：$k'), behavior: SnackBarBehavior.floating)),
          ),
          const AiChatPage(),
          const ShoppingPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final labels = ['首页', 'AI找房', '好货', '我的'];
    final icons = [Icons.home_outlined, Icons.psychology_outlined, Icons.shopping_bag_outlined, Icons.person_outline];
    final activeIcons = [Icons.home, Icons.psychology, Icons.shopping_bag, Icons.person];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          child: Row(
            children: List.generate(4, (i) {
              final isActive = _currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isActive ? activeIcons[i] : icons[i], color: isActive ? const Color(0xFF6366F1) : const Color(0xFFBDBDBD), size: 20),
                      const SizedBox(height: 3),
                      Text(labels[i], style: TextStyle(fontSize: 9, color: isActive ? const Color(0xFF6366F1) : const Color(0xFFBDBDBD), fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showCitySheet() {
    final cities = ['上海', '北京', '深圳', '广州', '杭州', '成都', '南京', '武汉', '西安', '苏州', '重庆', '天津'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择城市', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: cities.map((city) => GestureDetector(
              onTap: () { setState(() => _selectedCity = city); Navigator.pop(context); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: city == _selectedCity ? const Color(0xFF6366F1) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(city, style: TextStyle(fontSize: 10, color: city == _selectedCity ? Colors.white : const Color(0xFF424242))),
              ),
            )).toList()),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
