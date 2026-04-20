# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\room_detail_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# 1. Remove extension _RoomShare
ext_start = data.find('extension _RoomShare')
if ext_start < 0:
    print('Extension not found')
else:
    icon_start = data.find('class _ShareIcon', ext_start)
    if icon_start >= 0:
        depth = 0
        i = data.find('{', icon_start)
        icon_end = -1
        while i < len(data):
            if data[i] == '{': depth += 1
            elif data[i] == '}':
                depth -= 1
                if depth == 0:
                    icon_end = i
                    break
            i += 1
        data = data[:ext_start] + data[icon_end+1:]
        print('Removed extension')

# 2. Fix share button call
data = data.replace(
    "onPressed: () => this._showShareSheet(context, room),",
    "onPressed: () => _showRoomShareSheet(context, room),"
)
print('Fixed share button')

# 3. Add share function and dialog widget AFTER RoomDetailPage
idx = data.find('class RoomDetailPage')
depth = 0
i = data.find('{', idx)
end_pos = -1
while i < len(data):
    if data[i] == '{': depth += 1
    elif data[i] == '}':
        depth -= 1
        if depth == 0:
            end_pos = i
            break
    i += 1
next_class = data.find('class _', end_pos+1)

# Use double backslash for \n to get literal \n in Dart
share_func = """

// ============================================================
// 房源分享功能
// ============================================================
void _showRoomShareSheet(BuildContext context, Room room) {
  showDialog(
    context: context,
    builder: (_) => _ShareSheetDialog(room: room),
  );
}

class _ShareSheetDialog extends StatelessWidget {
  final Room room;
  const _ShareSheetDialog({required this.room});

  String get _shareText =>
      room.title + "\\n" + room.layout + " · " + room.area.toStringAsFixed(0) + "\\u7ac  "\\n" +
      "月租 \\u00a5" + room.price.toStringAsFixed(0) + "/月\\n" +
      "地址：" + room.address + "\\n" +
      "点击查看详情 \\u2192";
  String get _shareUrl => "https://example.com/room/" + room.id.toString();

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(room.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          "\\u00a5" + room.price.toStringAsFixed(0) + "/月 · " + room.layout,
          style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
        const SizedBox(height: 16),
        const Text('分享到', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _ShareIcon(Icons.chat, '微信', const Color(0xFF07C160), () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已复制链接，请粘贴到微信发送'), behavior: SnackBarBehavior.floating),
            );
          }),
          _ShareIcon(Icons.group, '朋友圈', const Color(0xFF07C160), () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已复制链接，请粘贴到朋友圈'), behavior: SnackBarBehavior.floating),
            );
          }),
          _ShareIcon(Icons.tag, 'QQ', const Color(0xFF1296DB), () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已复制链接，请粘贴到QQ发送'), behavior: SnackBarBehavior.floating),
            );
          }),
          _ShareIcon(Icons.sms, '短信', const Color(0xFFFF9500), () async {
            Navigator.pop(context);
            final smsUri = Uri.parse("sms:?body=" + Uri.encodeComponent(_shareText + "\\n" + _shareUrl));
            if (await canLaunchUrl(smsUri)) await launchUrl(smsUri);
          }),
          _ShareIcon(Icons.link, '复制', const Color(0xFF6366F1), () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('链接已复制到剪贴板'), behavior: SnackBarBehavior.floating),
            );
          }),
        ]),
        const SizedBox(height: 16),
        const Divider(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(color: Color(0xFF9E9E9E))),
        ),
      ]),
    ),
  );
}

class _ShareIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ShareIcon(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
    ]),
  );
}

"""

if next_class >= 0:
    data = data[:next_class] + share_func + '\n' + data[next_class:]
else:
    data = data + share_func

with open(r'D:\Projects\gongyu_guanjia\lib\pages\room_detail_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print('Done! File size:', len(data))
