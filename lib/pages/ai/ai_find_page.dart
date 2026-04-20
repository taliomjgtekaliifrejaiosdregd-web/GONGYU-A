import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/models/room.dart';
import 'package:gongyu_guanjia/pages/room_detail_page.dart';
import 'package:gongyu_guanjia/pages/login_page.dart';

class AiFindPage extends StatefulWidget {
  const AiFindPage({super.key});

  @override
  State<AiFindPage> createState() => _AiFindPageState();
}

class _AiFindPageState extends State<AiFindPage> {
  final _controller = TextEditingController();
  bool _isSearching = false;
  String? _result;
  List<Room>? _matchedRooms;
  String _selectedDistrict = '不限';
  String _selectedType = '不限';
  String _priceRange = '不限';
  String _sort = '综合排序';

  final _districts = ['不限', '浦东新区', '徐汇区', '静安区', '黄浦区', '长宁区', '普陀区', '虹口区', '杨浦区', '闵行区', '宝山区', '嘉定区', '松江区'];
  final _types = ['不限', '整租', '合租', '公寓'];
  final _prices = ['不限', '1000以下', '1000-2000', '2000-3000', '3000-5000', '5000以上'];

  void _search() {
    setState(() => _isSearching = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final rooms = MockService.rooms.where((r) {
        bool match = true;
        if (_selectedDistrict != '不限') match = match && r.district.contains(_selectedDistrict);
        if (_selectedType != '不限') match = match && r.roomType == _selectedType;
        if (_priceRange != '不限') {
          if (_priceRange == '1000以下') match = match && r.price < 1000;
          if (_priceRange == '1000-2000') match = match && r.price >= 1000 && r.price < 2000;
          if (_priceRange == '2000-3000') match = match && r.price >= 2000 && r.price < 3000;
          if (_priceRange == '3000-5000') match = match && r.price >= 3000 && r.price < 5000;
          if (_priceRange == '5000以上') match = match && r.price >= 5000;
        }
        return match;
      }).toList();

      setState(() {
        _isSearching = false;
        _matchedRooms = rooms;
        _result = rooms.isEmpty
            ? '未找到符合条件的房源'
            : '为您找到 ${rooms.length} 套符合条件的房源，AI正在分析最佳选择...';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B61FF),
        foregroundColor: Colors.white,
        title: const Text('AI智能找房'),
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI 对话区域
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI 头像
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF9C27B0)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI智能管家', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('随时为您推荐最优房源', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 搜索框
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '输入您的找房需求，如：浦东新区 整租 3000以内 近地铁',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF7B61FF)),
                        onPressed: _search,
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                  const SizedBox(height: 16),
                  // 筛选条件
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(label: _selectedDistrict, options: _districts, onSelect: (v) => setState(() => _selectedDistrict = v)),
                      _FilterChip(label: _selectedType, options: _types, onSelect: (v) => setState(() => _selectedType = v)),
                      _FilterChip(label: _priceRange, options: _prices, onSelect: (v) => setState(() => _priceRange = v)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('AI帮我找'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B61FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: _search,
                    ),
                  ),
                  // AI 结果
                  if (_isSearching) ...[
                    const SizedBox(height: 20),
                    const Center(child: CircularProgressIndicator(color: Color(0xFF7B61FF))),
                    const SizedBox(height: 12),
                    const Center(child: Text('AI正在为您分析最佳房源...', style: TextStyle(color: Color(0xFF9E9E9E)))),
                  ],
                  if (_result != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B61FF).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF7B61FF).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Color(0xFF7B61FF), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_result!, style: const TextStyle(fontSize: 13, color: Color(0xFF424242))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 推荐列表
            if (_matchedRooms != null && _matchedRooms!.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text('为您推荐', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ...(_matchedRooms!).map((room) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _AiRoomCard(room: room),
                  )),
            ],

            // 快捷标签
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text('猜您喜欢', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ...MockService.rooms.take(3).map((room) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _AiRoomCard(room: room),
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String> onSelect;

  const _FilterChip({required this.label, required this.options, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF757575)),
          ],
        ),
      ),
      itemBuilder: (_) => options.map((o) => PopupMenuItem(value: o, child: Text(o))).toList(),
    );
  }
}

class _AiRoomCard extends StatelessWidget {
  final Room room;
  const _AiRoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailPage(room: room, onLoginRequired: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()))))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 120,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(Icons.apartment, size: 40, color: const Color(0xFFBDBDBD))),
                  Positioned(
                    left: 8, top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B61FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('AI推荐', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${room.district} · ${room.community}', style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                    const SizedBox(height: 4),
                    Text(room.layoutText, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(room.priceText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                        const Text('元/月', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFF7B61FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, size: 10, color: Color(0xFF7B61FF)),
                              const SizedBox(width: 3),
                              const Text('AI匹配', style: TextStyle(fontSize: 10, color: Color(0xFF7B61FF))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
