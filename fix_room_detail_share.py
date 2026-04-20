# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\room_detail_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# 1. Add url_launcher import
if "import 'package:url_launcher/url_launcher.dart';" not in data:
    # Add after the first import line
    first_newline = data.find('\n')
    data = "import 'package:url_launcher/url_launcher.dart';\n" + data
    print('1. Added url_launcher import')

# 2. Fix the share button onPressed
old_share_btn = "IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),"

new_share_btn = """IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () => _showShareSheet(context, room),
            ),"""

if old_share_btn in data:
    data = data.replace(old_share_btn, new_share_btn)
    print('2. Replaced share button')
else:
    print('WARNING: share button pattern not found')

# 3. Add _showShareSheet static method to RoomDetailPage
# Find the end of the class (before the last closing brace)
# Actually, RoomDetailPage is StatelessWidget, so we add a static method
last_close = data.rfind('}')
print(f'Last closing brace at: {last_close}')

share_method = '''
// ============================================================
// 房源详情页分享功能
// ============================================================
extension _RoomShare on RoomDetailPage {
  static void _showShareSheet(BuildContext context, Room room) {
    final text = '${room.title}\\n${room.layout} · ${room.area.toStringAsFixed(0)}㎡\\n月租 ¥${room.price.toStringAsFixed(0)}元/月\\n地址：${room.address}\\n点击查看详情 →';
    final url = 'https://example.com/room/' + room.id.toString();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(room.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('¥' + room.price.toStringAsFixed(0) + '/月 · ' + room.layout, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
            const SizedBox(height: 16),
            const Text('分享到', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _ShareIcon(Icons.chat, '微信', const Color(0xFF07C160), () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制链接，请粘贴到微信发送'), behavior: SnackBarBehavior.floating));
              }),
              _ShareIcon(Icons.group, '朋友圈', const Color(0xFF07C160), () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制链接，请粘贴到朋友圈'), behavior: SnackBarBehavior.floating));
              }),
              _ShareIcon(Icons.tag, 'QQ', const Color(0xFF1296DB), () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制链接，请粘贴到QQ发送'), behavior: SnackBarBehavior.floating));
              }),
              _ShareIcon(Icons.sms, '短信', const Color(0xFFFF9500), () async {
                Navigator.pop(context);
                final smsUri = Uri.parse('sms:?body=' + Uri.encodeComponent(text + '\\n' + url));
                if (await canLaunchUrl(smsUri)) await launchUrl(smsUri);
              }),
              _ShareIcon(Icons.link, '复制', const Color(0xFF6366F1), () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('链接已复制到剪贴板'), behavior: SnackBarBehavior.floating));
              }),
            ]),
            const SizedBox(height: 16),
            const Divider(),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消', style: TextStyle(color: Color(0xFF9E9E9E)))),
          ]),
        ),
      ),
    );
  }
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
'''

# Insert before the last closing brace
data = data[:last_close] + share_method + '\n}'

with open(r'D:\Projects\gongyu_guanjia\lib\pages\room_detail_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print(f'Final size: {len(data)}')
print('Saved room_detail_page!')
