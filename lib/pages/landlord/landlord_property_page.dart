// landlord_property_page.dart - 房源管理页面
import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';
import 'package:gongyu_guanjia/models/room.dart';
import 'package:gongyu_guanjia/pages/landlord/property_edit_page.dart';
import 'package:gongyu_guanjia/pages/landlord/room_contract_page.dart';
import 'package:gongyu_guanjia/pages/landlord/property_stats_page.dart';

class LandlordPropertyPage extends StatefulWidget {
  const LandlordPropertyPage({super.key});
  @override State<LandlordPropertyPage> createState() => _LandlordPropertyPageState();
}

class _LandlordPropertyPageState extends State<LandlordPropertyPage> {
  RoomType? _filterType;
  RoomStatus? _filterStatus;
  String _search = '';

  List<Room> get _filtered {
    return MockService.rooms.where((r) {
      if (_filterType != null && r.type != _filterType) return false;
      if (_filterStatus != null && r.status != _filterStatus) return false;
      if (_search.isNotEmpty && !r.title.contains(_search)) return false;
      return true;
    }).toList();
  }

  void _togglePublish(Room r) {
    final idx = MockService.rooms.indexWhere((room) => room.id == r.id);
    if (idx < 0) return;
    final updated = r.copyWith(isPublished: !r.isPublished);
    MockService.rooms[idx] = updated;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(updated.isPublished ? '已上架「${r.title}」' : '已下架「${r.title}」'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: updated.isPublished ? const Color(0xFF10B981) : Colors.grey.shade600,
      ),
    );
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('房源管理', style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const PropertyEditPage()),
              );
              if (result == true && mounted) setState(() {});
            },
          ),
        ],
      ),
      body: Column(children: [
        Container(color: Colors.white, padding: const EdgeInsets.all(12), child: Column(children: [
          TextField(
            decoration: InputDecoration(
              hintText: '搜索房源...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              filled: true,
              fillColor: AppColors.background,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _FChip('全部', _filterType == null && _filterStatus == null, () => setState(() { _filterType = null; _filterStatus = null; })),
              _FChip('整租', _filterType == RoomType.whole, () => setState(() => _filterType = RoomType.whole)),
              _FChip('合租', _filterType == RoomType.shared, () => setState(() => _filterType = RoomType.shared)),
              _FChip('未出租', _filterStatus == RoomStatus.available, () => setState(() => _filterStatus = RoomStatus.available)),
              _FChip('已出租', _filterStatus == RoomStatus.rented, () => setState(() => _filterStatus = RoomStatus.rented)),
            ]),
          ),
        ])),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _filtered.length,
          itemBuilder: (_, i) {
            final r = _filtered[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                Row(children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: AppColors.primaryBg, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.home, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(r.communityName + ' | ' + r.layout, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text(r.priceText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.danger)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: r.isAvailable ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(r.statusLabel, style: TextStyle(fontSize: 10, color: r.isAvailable ? AppColors.success : AppColors.warning)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: r.isPublished ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(r.isPublished ? Icons.visibility : Icons.visibility_off, size: 10, color: r.isPublished ? const Color(0xFF10B981) : Colors.grey.shade500),
                          const SizedBox(width: 3),
                          Text(r.isPublished ? '已上架' : '未上架', style: TextStyle(fontSize: 10, color: r.isPublished ? const Color(0xFF10B981) : Colors.grey.shade500)),
                        ]),
                      ),
                    ]),
                  ])),
                ]),
                const Divider(height: 16),
                Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyEditPage(room: r))),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.edit, size: 16, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('编辑', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                    ]),
                  )),
                  Container(width: 1, height: 20, color: Colors.grey.shade200),
                  Expanded(child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomContractPage(room: r))),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.description, size: 16, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('合同', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                    ]),
                  )),
                  Container(width: 1, height: 20, color: Colors.grey.shade200),
                  Expanded(child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyStatsPage(room: r))),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.bar_chart, size: 16, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('统计', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                    ]),
                  )),
                  Container(width: 1, height: 20, color: Colors.grey.shade200),
                  Expanded(child: GestureDetector(
                    onTap: () => _togglePublish(r),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(r.isPublished ? Icons.visibility_off : Icons.visibility, size: 16, color: r.isPublished ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(r.isPublished ? '下架' : '上架', style: TextStyle(fontSize: 12, color: r.isPublished ? const Color(0xFF10B981) : const Color(0xFFF59E0B))),
                    ]),
                  )),
                ]),
              ]),
            );
          },
        )),
      ]),
    );
  }
}

class _FChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FChip(this.label, this.selected, this.onTap);
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.grey.shade700)),
    ),
  );
}
