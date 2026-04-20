import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gongyu_guanjia/models/room.dart';
import 'package:gongyu_guanjia/pages/room_detail_page.dart';
import 'package:gongyu_guanjia/pages/login_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  Room? _selectedRoom;
  final List<Room> _rooms = MockService.rooms.where((r) => r.latitude != 0).toList();

  // 上海中心点
  static const _shanghaiCenter = LatLng(31.2304, 121.4737);

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _selectRoom(Room room) {
    setState(() => _selectedRoom = room);
    _mapController.move(LatLng(room.latitude, room.longitude), 15);
  }

  void _openRoom(Room room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomDetailPage(
          room: room,
          onLoginRequired: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          // 真实地图层
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _shanghaiCenter,
              initialZoom: 11.5,
              minZoom: 10,
              maxZoom: 18,
              onTap: (_, __) => setState(() => _selectedRoom = null),
            ),
            children: [
              // OpenStreetMap 瓦片（免费，无需API Key）
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.gongyu_guanjia',
              ),
              // 房源标记层
              MarkerLayer(
                markers: _rooms.map((room) {
                  final isSelected = _selectedRoom?.id == room.id;
                  return Marker(
                    point: LatLng(room.latitude, room.longitude),
                    width: isSelected ? 60 : 50,
                    height: isSelected ? 50 : 42,
                    child: GestureDetector(
                      onTap: () => _selectRoom(room),
                      child: _PriceMarker(
                        price: room.price,
                        isSelected: isSelected,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 顶部搜索栏
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: Color(0xFF00C853), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: '搜索区域、地铁站、小区名',
                        hintStyle: TextStyle(fontSize: 14, color: Color(0xFFBDBDBD)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('搜索', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 左上角定位按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 16,
            child: Column(
              children: [
                _MapBtn(
                  icon: Icons.my_location,
                  onTap: () => _mapController.move(_shanghaiCenter, 11.5),
                ),
                const SizedBox(height: 8),
                _MapBtn(
                  icon: Icons.layers,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // 右上角筛选按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            right: 16,
            child: Column(
              children: [
                _MapBtn(
                  icon: Icons.filter_list,
                  onTap: () {},
                  badge: '3',
                ),
                const SizedBox(height: 8),
                _MapBtn(
                  icon: Icons.refresh,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // 底部选中房源卡片（点击地图空白处消失）
          if (_selectedRoom != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _RoomCard(
                room: _selectedRoom!,
                onClose: () => setState(() => _selectedRoom = null),
                onTap: () => _openRoom(_selectedRoom!),
              ),
            ),

          // 底部房源列表（无选中时显示）
          if (_selectedRoom == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, -4))],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF00C853), size: 16),
                          const SizedBox(width: 4),
                          const Text('附近房源', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text('共 ${_rooms.length} 套', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _rooms.length,
                        itemBuilder: (context, index) {
                          final room = _rooms[index];
                          return GestureDetector(
                            onTap: () => _selectRoom(room),
                            child: Container(
                              width: 220,
                              margin: const EdgeInsets.only(right: 12, bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE0E0E0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(child: Icon(Icons.apartment, size: 32, color: const Color(0xFF00C853).withOpacity(0.5))),
                                        Positioned(
                                          left: 8, top: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF00C853),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(room.roomType, style: const TextStyle(color: Colors.white, fontSize: 10)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(room.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text('${room.district} · ${room.community}', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text('¥${room.price.toInt()}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                                            const Text('元/月', style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
    );
  }
}

class _PriceMarker extends StatelessWidget {
  final double price;
  final bool isSelected;
  const _PriceMarker({required this.price, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 12 : 9, vertical: isSelected ? 8 : 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF5722) : const Color(0xFF00C853),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isSelected ? 0.3 : 0.15), blurRadius: isSelected ? 8 : 4, offset: const Offset(0, 3))],
          ),
          child: Text(
            '¥${price.toInt()}',
            style: TextStyle(color: Colors.white, fontSize: isSelected ? 13 : 11, fontWeight: FontWeight.bold),
          ),
        ),
        CustomPaint(size: const Size(14, 8), painter: _ArrowPainter(color: isSelected ? const Color(0xFFFF5722) : const Color(0xFF00C853))),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  _ArrowPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawPath(ui.Path()..moveTo(0, 0)..lineTo(size.width / 2, size.height)..lineTo(size.width, 0)..close(), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onClose;
  final VoidCallback onTap;
  const _RoomCard({required this.room, required this.onClose, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF00C853), borderRadius: BorderRadius.circular(4)),
                  child: Text(room.roomType, style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
                const SizedBox(width: 8),
                Text(room.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${room.district} · ${room.community}', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('¥${room.price.toInt()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                const Text(' 元/月', style: TextStyle(fontSize: 12, color: const Color(0xFF9E9E9E))),
                const SizedBox(width: 12),
                Text(room.layout, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                const SizedBox(width: 8),
                Text('${room.area.toInt()}㎡', style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('查看详情', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;
  const _MapBtn({required this.icon, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF424242)),
          ),
        ),
        if (badge != null)
          Positioned(
            top: -4, right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(color: const Color(0xFFFF5722), borderRadius: BorderRadius.circular(10)),
              child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}
