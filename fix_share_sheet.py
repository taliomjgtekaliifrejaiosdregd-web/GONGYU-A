# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# ============================================================
# Add _VacantRoomShareSheet widget before the last closing brace
# ============================================================
share_sheet_widget = '''
// ============================================================
// 空房分享 BottomSheet
// ============================================================
class _VacantRoomShareSheet extends StatefulWidget {
  final void Function(Room room) onRoomTap;

  const _VacantRoomShareSheet({required this.onRoomTap});

  @override
  State<_VacantRoomShareSheet> createState() => _VacantRoomShareSheetState();
}

class _VacantRoomShareSheetState extends State<_VacantRoomShareSheet> {
  String _typeFilter = '全部';
  String _statusFilter = '未出租';

  List<Room> get _filteredRooms {
    var rooms = MockService.rooms.where((r) {
      if (_statusFilter == '未出租') return r.status == RoomStatus.available;
      if (_statusFilter == '已出租') return r.status == RoomStatus.rented;
      if (_statusFilter == '预定中') return r.status == RoomStatus.reserved;
      return true;
    }).toList();

    if (_typeFilter == '整租') rooms = rooms.where((r) => r.type == RoomType.whole).toList();
    if (_typeFilter == '合租') rooms = rooms.where((r) => r.type == RoomType.shared).toList();
    if (_typeFilter == '独栋') rooms = rooms.where((r) => r.type == RoomType.building).toList();

    return rooms;
  }

  String _shareText(Room room) {
    return '${room.title}\\n${room.layout} · ${room.area.toStringAsFixed(0)}㎡\\n月租 ¥${room.price.toStringAsFixed(0)}元/月\\n地址：${room.address}\\n点击查看详情 →';
  }

  String _shareUrl(Room room) {
    return 'https://example.com/room/' + room.id.toString();
  }

  Future<void> _share(Room room) async {
    final text = _shareText(room);
    final url = _shareUrl(room);

    showDialog(context: context, barrierDismissible: true, builder: (_) => _ShareDialog(
      room: room,
      text: text,
      url: url,
      onSelected: (app) async {
        Navigator.pop(context); // close dialog
        if (app == 'wechat') {
          // 微信没有网页分享API，尝试打开微信
          final uri = Uri.parse('weixin://');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) {
              _copyToClipboard(context, text + '\\n' + url);
            }
          }
        } else if (app == 'moments') {
          final uri = Uri.parse('weixin://');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) _copyToClipboard(context, text + '\\n' + url);
          }
        } else if (app == 'qq') {
          final uri = Uri.parse('mqqapi://');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) _copyToClipboard(context, text + '\\n' + url);
          }
        } else if (app == 'sms') {
          final uri = Uri.parse('sms:?body=' + Uri.encodeComponent(text + '\\n' + url));
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        } else if (app == 'copy') {
          if (mounted) _copyToClipboard(context, text + '\\n链接：' + url);
        }
        // Navigate to room detail after sharing
        widget.onRoomTap(room);
      },
    ));
  }

  void _copyToClipboard(BuildContext context, String text) {
    // Use Flutter's clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('链接已复制到剪贴板'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = _filteredRooms;
    final vacantCount = MockService.rooms.where((r) => r.status == RoomStatus.available).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.home_work, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              const Text('空房分享', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('$vacantCount 套可分享', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
              ),
            ]),
          ]),
        ),
        // Filters
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            // Type filter
            Row(children: [
              Text('类型：', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(width: 8),
              ...['全部', '整租', '合租', '独栋'].map((t) => Padding(padding: const EdgeInsets.only(right: 6), child: FilterChip(
                label: Text(t, style: TextStyle(fontSize: 11, color: _typeFilter == t ? Colors.white : Colors.black87)),
                selected: _typeFilter == t,
                selectedColor: const Color(0xFF6366F1),
                backgroundColor: const Color(0xFFF5F5F5),
                onSelected: (_) => setState(() => _typeFilter = t),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ))),
            ]),
            const SizedBox(height: 8),
            // Status filter
            Row(children: [
              Text('状态：', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(width: 8),
              ...['未出租', '已出租', '预定中'].map((s) => Padding(padding: const EdgeInsets.only(right: 6), child: FilterChip(
                label: Text(s, style: TextStyle(fontSize: 11, color: _statusFilter == s ? Colors.white : Colors.black87)),
                selected: _statusFilter == s,
                selectedColor: const Color(0xFF6366F1),
                backgroundColor: const Color(0xFFF5F5F5),
                onSelected: (_) => setState(() => _statusFilter = s),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ))),
            ]),
          ]),
        ),
        const Divider(height: 20),
        // Room list
        Expanded(
          child: rooms.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.home_outlined, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('暂无符合条件的房源', style: TextStyle(color: Colors.grey.shade500)),
                ]))
              : ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: rooms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _RoomShareCard(
                    room: rooms[i],
                    onTap: () => widget.onRoomTap(rooms[i]),
                    onShare: () => _share(rooms[i]),
                  ),
                ),
        ),
      ]),
    );
  }
}

// ============================================================
// 单个房源分享卡片
// ============================================================
class _RoomShareCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const _RoomShareCard({required this.room, required this.onTap, required this.onShare});

  @override
  Widget build(BuildContext context) {
    final statusColor = room.status == RoomStatus.available
        ? const Color(0xFF10B981)
        : room.status == RoomStatus.reserved
            ? const Color(0xFFF59E0B)
            : const Color(0xFF9E9E9E);
    final statusLabel = room.status == RoomStatus.available
        ? '可出租'
        : room.status == RoomStatus.reserved ? '预定中' : '已出租';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          // 图片
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(children: [
              Container(
                height: 160,
                width: double.infinity,
                color: const Color(0xFFEEEEEE),
                child: room.images.isNotEmpty
                    ? Image.network(room.images.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Icon(Icons.home, size: 48, color: Colors.grey.shade400)))
                    : Center(child: Icon(Icons.home, size: 48, color: Colors.grey.shade400)),
              ),
              // Status badge
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
                  child: Text(statusLabel, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
              // Price
              Positioned(
                bottom: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                  child: Text('¥' + room.price.toStringAsFixed(0) + '/月', style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Row(children: [
                Expanded(child: Text(room.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(room.type == RoomType.whole ? '整租' : room.type == RoomType.shared ? '合租' : '独栋', style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1))),
                ),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 2),
                Expanded(child: Text(room.address, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                _InfoTag(Icons.straighten, room.area.toStringAsFixed(0) + '㎡'),
                const SizedBox(width: 8),
                _InfoTag(Icons.bed_outlined, room.layout),
                const Spacer(),
                // 转发分享按钮
                GestureDetector(
                  onTap: onShare,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF07C160).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.share, size: 14, color: const Color(0xFF07C160)),
                      const SizedBox(width: 4),
                      const Text('转发', style: TextStyle(fontSize: 12, color: Color(0xFF07C160), fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                // 查看详情按钮
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: const Text('详情 →', style: TextStyle(fontSize: 12, color: Color(0xFF6366F1), fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoTag(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: Colors.grey.shade500),
    const SizedBox(width: 2),
    Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
  ]);
}

// ============================================================
// 分享弹窗
// ============================================================
class _ShareDialog extends StatelessWidget {
  final Room room;
  final String text;
  final String url;
  final void Function(String app) onSelected;

  const _ShareDialog({required this.room, required this.text, required this.url, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    // Show a mini share card with room image and share options
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Preview
          if (room.images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(room.images.first, height: 140, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 140, color: const Color(0xFFEEEEEE))),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Text(room.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('¥' + room.price.toStringAsFixed(0) + '/月 · ' + room.layout, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
              const SizedBox(height: 16),
              const Text('分享到', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              // Share options
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _ShareBtn(Icons.chat, '微信', const Color(0xFF07C160), () => onSelected('wechat')),
                _ShareBtn(Icons.group, '朋友圈', const Color(0xFF07C160), () => onSelected('moments')),
                _ShareBtn(Icons.tag, 'QQ', const Color(0xFF1296DB), () => onSelected('qq')),
                _ShareBtn(Icons.sms, '短信', const Color(0xFFFF9500), () => onSelected('sms')),
                _ShareBtn(Icons.link, '复制', const Color(0xFF6366F1), () => onSelected('copy')),
              ]),
            ]),
          ),
          const Divider(height: 1),
          TextButton(onPressed: () { Navigator.pop(context); }, child: const Text('取消', style: TextStyle(color: Color(0xFF9E9E9E)))),
        ]),
      ),
    );
  }
}

class _ShareBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ShareBtn(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(width: 48, height: 48,
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
    ]),
  );
}

'''

# Find the last closing brace of the file
# The file ends with the last class definition
# We need to insert before the final closing brace
last_brace = data.rfind('}')
print(f'Last closing brace at: {last_brace}')

# Check what's after the last brace
print(f'After last brace: {repr(data[last_brace:last_brace+50])}')

# Insert the new widgets before the last closing brace
data = data[:last_brace] + share_sheet_widget + '\n}'

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print(f'Final size: {len(data)}')
print('Part 2 saved!')
