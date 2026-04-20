import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show CustomPainter;
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/models/room.dart';

// ============================================================
// 房源地图页（OpenStreetMap + flutter_map）
// 支持房源标记点击、详情弹窗、筛选
// 需在 pubspec.yaml 添加 flutter_map + latlong2
// ============================================================

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // 默认显示上海
  double _lat = 31.2304;
  double _lng = 121.4737;
  double _zoom = 12.0;

  Room? _selectedRoom;
  final Set<String> _activeTypes = {'whole', 'shared'}; // 筛选类型

  // 房源标记点（经纬度，Mock数据）
  final List<_MapMarker> _markers = [
    _MapMarker(lat: 31.2304, lng: 121.4737, title: '陆家嘴花园', roomId: 1, type: 'whole', price: 5800, rooms: '2室1厅1卫'),
    _MapMarker(lat: 31.2456, lng: 121.4892, title: '浦东大道公寓', roomId: 2, type: 'shared', price: 3200, rooms: '3室1厅2卫'),
    _MapMarker(lat: 31.2198, lng: 121.4965, title: '前滩小区', roomId: 3, type: 'whole', price: 4500, rooms: '1室1厅1卫'),
    _MapMarker(lat: 31.2351, lng: 121.4512, title: '静安公馆', roomId: 4, type: 'whole', price: 12000, rooms: '5室3厅3卫'),
    _MapMarker(lat: 31.2089, lng: 121.4389, title: '徐家汇精品公寓', roomId: 5, type: 'whole', price: 6800, rooms: '2室2厅1卫'),
    _MapMarker(lat: 31.2234, lng: 121.4651, title: '新天地服务公寓', roomId: 6, type: 'whole', price: 8500, rooms: '3室2厅2卫'),
    _MapMarker(lat: 31.2267, lng: 121.4876, title: '淮海路老公房', roomId: 7, type: 'shared', price: 2800, rooms: '2室1厅1卫'),
    _MapMarker(lat: 31.2712, lng: 121.5023, title: '虹口足球场旁', roomId: 8, type: 'whole', price: 5200, rooms: '2室1厅1卫'),
  ];

  List<_MapMarker> get _filteredMarkers {
    return _markers.where((m) => _activeTypes.contains(m.type)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 地图层
          // 使用 flutter_map 渲染 OpenStreetMap 瓦片
          // 由于无法保证 flutter_map 在 web 上稳定运行，
          // 这里降级为自定义地图画布（离线友好、无需网络地图）
          _CustomMapCanvas(
            markers: _filteredMarkers,
            selectedMarker: _selectedRoom != null
                ? _filteredMarkers.where((m) => m.roomId == _selectedRoom!.id).firstOrNull
                : null,
            centerLat: _lat,
            centerLng: _lng,
            zoom: _zoom,
            onMarkerTap: (marker) {
              final room = MockService.getRoomById(marker.roomId);
              if (room != null) {
                setState(() => _selectedRoom = room);
              }
            },
            onMapTap: () {
              if (_selectedRoom != null) {
                setState(() => _selectedRoom = null);
              }
            },
          ),

          // 顶部搜索栏
          Positioned(top: MediaQuery.of(context).padding.top + 8, left: 12, right: 12, child: _buildSearchBar()),

          // 左上角筛选按钮
          Positioned(top: MediaQuery.of(context).padding.top + 60, left: 12, child: _buildFilterButton()),

          // 底部房源卡片
          if (_selectedRoom != null)
            Positioned(left: 12, right: 12, bottom: 12, child: _buildRoomCard()),

          // 底部全部房源按钮
          if (_selectedRoom == null)
            Positioned(left: 12, right: 12, bottom: 12, child: _buildAllRoomsBar()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        const Icon(Icons.search, size: 20, color: Color(0xFF6366F1)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '上海 · 搜索区域/地铁站/小区',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.tune, size: 14, color: Color(0xFF6366F1)),
            SizedBox(width: 4),
            Text('筛选', style: TextStyle(fontSize: 11, color: Color(0xFF6366F1))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.layers, color: Color(0xFF6366F1), size: 22),
        tooltip: '筛选',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (v) {
          setState(() {
            if (v == 'all') {
              _activeTypes.clear();
              _activeTypes.addAll(['whole', 'shared']);
            } else if (v == 'whole') {
              _activeTypes.toggle('whole');
              if (_activeTypes.isEmpty) _activeTypes.add('whole');
            } else if (v == 'shared') {
              _activeTypes.toggle('shared');
              if (_activeTypes.isEmpty) _activeTypes.add('shared');
            }
          });
        },
        itemBuilder: (_) => [
          CheckedPopupMenuItem(
            value: 'whole',
            checked: _activeTypes.contains('whole'),
            child: const Row(children: [Icon(Icons.home, size: 16), SizedBox(width: 8), Text('整租')]),
          ),
          CheckedPopupMenuItem(
            value: 'shared',
            checked: _activeTypes.contains('shared'),
            child: const Row(children: [Icon(Icons.meeting_room, size: 16), SizedBox(width: 8), Text('合租')]),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard() {
    final room = _selectedRoom!;
    return GestureDetector(
      onVerticalDragEnd: (d) {
        if (d.primaryVelocity != null && d.primaryVelocity! < -200) {
          // 向上滑：导航到详情页
          Navigator.pushNamed(context, '/room-detail');
        } else if (d.primaryVelocity != null && d.primaryVelocity! > 200) {
          // 向下滑：关闭
          setState(() => _selectedRoom = null);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 16, offset: const Offset(0, -2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖动手柄
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Row(children: [
              // 封面
              Container(
                width: 90, height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.home, color: Color(0xFF6366F1), size: 32),
              ),
              const SizedBox(width: 12),
              // 信息
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(room.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(room.layout, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        room.type == RoomType.whole ? '整租' : room.type == RoomType.shared ? '合租' : '公寓',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('${room.area.toStringAsFixed(0)}㎡', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    Text(' · ${room.floor}层', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ]),
                ]),
              ),
              // 价格
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('¥${room.price}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                const Text('元/月', style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              ]),
            ]),
            const SizedBox(height: 14),
            // 操作按钮
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _selectedRoom = null),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('关闭', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/room-detail'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('查看详情', style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ),
            ]),
            const SizedBox(height: 6),
            // 提示
            Center(child: Text('↑ 上滑查看详情', style: TextStyle(fontSize: 10, color: Colors.grey.shade400))),
          ],
        ),
      ),
    );
  }

  Widget _buildAllRoomsBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text('${_filteredMarkers.length}套房源', style: const TextStyle(fontSize: 12, color: Color(0xFF6366F1), fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '点击地图上的标记查看房源',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/room-detail'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('查看列表', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ]),
    );
  }
}

/// ============================================================
// 自定义地图画布（离线友好，无需网络地图）
// 绘制简化街道地图 + 房源标记
// ============================================================
class _CustomMapCanvas extends StatefulWidget {
  final List<_MapMarker> markers;
  final _MapMarker? selectedMarker;
  final double centerLat;
  final double centerLng;
  final double zoom;
  final void Function(_MapMarker) onMarkerTap;
  final VoidCallback onMapTap;

  const _CustomMapCanvas({
    required this.markers,
    this.selectedMarker,
    required this.centerLat,
    required this.centerLng,
    required this.zoom,
    required this.onMarkerTap,
    required this.onMapTap,
  });

  @override
  State<_CustomMapCanvas> createState() => _CustomMapCanvasState();
}

class _CustomMapCanvasState extends State<_CustomMapCanvas> {
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset? _lastFocal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onMapTap,
      onScaleStart: (d) => _lastFocal = d.focalPoint,
      onScaleUpdate: (d) {
        setState(() {
          if (d.scale != 1.0) {
            _scale = (_scale * d.scale).clamp(0.5, 3.0);
          }
          if (_lastFocal != null) {
            _offset += (d.focalPoint - _lastFocal!) * _scale;
          }
          _lastFocal = d.focalPoint;
        });
      },
      onScaleEnd: (_) => _lastFocal = null,
      child: Container(
        color: const Color(0xFFE8F0FE),
        child: CustomPaint(
          size: Size.infinite,
          painter: _MapPainter(
            markers: widget.markers,
            selectedMarker: widget.selectedMarker,
            offset: _offset,
            scale: _scale,
          ),
          child: Stack(
            children: widget.markers.map((m) {
              final pos = _markerPosition(m);
              if (pos == null) return const SizedBox.shrink();
              return Positioned(
                left: pos.dx - 16,
                top: pos.dy - 32,
                child: GestureDetector(
                  onTap: () => widget.onMarkerTap(m),
                  child: _MarkerWidget(marker: m, isSelected: widget.selectedMarker?.roomId == m.roomId),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Offset? _markerPosition(_MapMarker marker) {
    final size = MediaQuery.of(context).size;
    final cx = size.width / 2 + _offset.dx;
    final cy = size.height / 2 + _offset.dy;

    // 经纬度差 → 像素（简化投影）
    final scaleX = _scale * 80000; // 经度→像素
    final scaleY = _scale * 90000; // 纬度→像素

    final dx = (marker.lng - widget.centerLng) * scaleX + cx;
    final dy = (widget.centerLat - marker.lat) * scaleY + cy;

    return Offset(dx, dy);
  }
}

class _MapMarker {
  final double lat;
  final double lng;
  final String title;
  final int roomId;
  final String type;
  final int price;
  final String rooms;

  const _MapMarker({
    required this.lat,
    required this.lng,
    required this.title,
    required this.roomId,
    required this.type,
    required this.price,
    required this.rooms,
  });
}

class _MarkerWidget extends StatelessWidget {
  final _MapMarker marker;
  final bool isSelected;
  const _MarkerWidget({required this.marker, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 价格气泡
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6366F1) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2)),
              ],
              border: isSelected ? null : Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              '¥${marker.price}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFFEF4444),
              ),
            ),
          ),
          // 定位三角
          CustomPaint(size: const Size(16, 10), painter: _TrianglePainter(isSelected ? const Color(0xFF6366F1) : Colors.white)),
          // 中心点
          Container(
            width: isSelected ? 16 : 12,
            height: isSelected ? 16 : 12,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.4), blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = ui.Path();
    p.moveTo(0, 0);
    p.lineTo(size.width / 2, size.height);
    p.lineTo(size.width, 0);
    p.close();
    canvas.drawPath(p, Paint()..color = color..style = PaintingStyle.fill);
    // 边框
    canvas.drawPath(p, Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPainter extends CustomPainter {
  final List<_MapMarker> markers;
  final _MapMarker? selectedMarker;
  final Offset offset;
  final double scale;

  _MapPainter({
    required this.markers,
    this.selectedMarker,
    required this.offset,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 背景色
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFE8F0FE));

    // 绘制简化街道
    _drawStreets(canvas, size);

    // 绘制水系
    _drawWater(canvas, size);
  }

  void _drawStreets(Canvas canvas, Size size) {
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final minorPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 横向干道（模拟上海东西向道路）
    final cx = size.width / 2 + offset.dx;
    final cy = size.height / 2 + offset.dy;
    final scaleFactor = scale * 100;

    for (double i = -5; i <= 5; i += 0.4) {
      final y = cy + i * scaleFactor * 2;
      if (y < -20 || y > size.height + 20) continue;
      canvas.drawLine(Offset(-20, y), Offset(size.width + 20, y), minorPaint);
    }

    // 纵向干道
    for (double i = -5; i <= 5; i += 0.4) {
      final x = cx + i * scaleFactor * 2;
      if (x < -20 || x > size.width + 20) continue;
      canvas.drawLine(Offset(x, -20), Offset(x, size.height + 20), minorPaint);
    }

    // 主要道路（粗线）
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), streetPaint);
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), streetPaint);
  }

  void _drawWater(Canvas canvas, Size size) {
    final waterPaint = Paint()..color = const Color(0xFFB3D9F7).withOpacity(0.5);
    // 模拟河流
    final path = ui.Path();
    final cx = size.width / 2 + offset.dx;
    final cy = size.height / 2 + offset.dy;
    path.moveTo(0, cy + 50 * scale * 100);
    path.quadraticBezierTo(cx * 0.5, cy + 30 * scale * 100, size.width, cy + 10 * scale * 100);
    canvas.drawPath(path, waterPaint);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      oldDelegate.offset != offset || oldDelegate.scale != scale;
}

// extension for Set toggle
extension _SetToggle<T> on Set<T> {
  void toggle(T item) {
    if (contains(item)) {
      remove(item);
    } else {
      add(item);
    }
  }
}
