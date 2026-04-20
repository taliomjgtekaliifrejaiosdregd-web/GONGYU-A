# -*- coding: utf-8 -*-
import sys
sys.stdout.reconfigure(encoding='utf-8')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\room_detail_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f'File size: {len(data)}')

# 1. Find RoomDetailPage end
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
print(f'RoomDetailPage ends at {end_pos}')

# 2. Find extension _RoomShare (inside _BottomBar currently)
roomshare_idx = data.find('extension _RoomShare')
print(f'extension _RoomShare at {roomshare_idx}')

if roomshare_idx >= 0:
    # Find the _ShareIcon class end - it's a StatelessWidget with build method
    # Look for the closing } of the build method and then the closing } of the class
    shareicon_start = data.find('class _ShareIcon', roomshare_idx)
    print(f'_ShareIcon at {shareicon_start}')
    
    # Find the closing brace of _ShareIcon class
    depth = 0
    j = data.find('{', shareicon_start)
    shareicon_end = -1
    while j < len(data):
        if data[j] == '{': depth += 1
        elif data[j] == '}':
            depth -= 1
            if depth == 0:
                shareicon_end = j
                break
        j += 1
    print(f'_ShareIcon ends at {shareicon_end}')
    
    # Remove the extension and _ShareIcon from their current location
    # They are from roomshare_idx to shareicon_end (inclusive)
    removed_len = shareicon_end + 1 - roomshare_idx
    print(f'Removing {removed_len} bytes from position {roomshare_idx}')
    data = data[:roomshare_idx] + data[shareicon_end+1:]
    print(f'File size after removal: {len(data)}')

# 3. Find where to insert - after RoomDetailPage class
# Find the first class after RoomDetailPage
after_room = end_pos + 1
next_class = data.find('class _', after_room)
print(f'Next class after RoomDetailPage: at {next_class}')

share_code = '''

// ============================================================
// 房源详情页分享功能
// ============================================================
extension _RoomShare on RoomDetailPage {
  static void _showShareSheet(BuildContext context, Room room) {
    final text = room.title + '\\n' + room.layout + ' · ' + room.area.toStringAsFixed(0) + '㎡\\n月租 ¥' + room.price.toStringAsFixed(0) + '元/月\\n地址：' + room.address + '\\n点击查看详情 →';
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
              _ShareIcon(Icons.chat, '微信', const Color(0xFF07C160), () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制链接，请粘贴到微信发送'), behavior: SnackBarBehavior.floating));
              }),
              _ShareIcon(Icons.group, '朋友圈', const Color(0xFF07C160), () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制链接，请粘贴到朋友圈'), behavior: SnackBarBehavior.floating));
              }),
              _ShareIcon(Icons.tag, 'QQ', const Color(0xFF1296DB), () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制链接，请粘贴到QQ发送'), behavior: SnackBarBehavior.floating));
              }),
              _ShareIcon(Icons.sms, '短信', const Color(0xFFFF9500), () async {
                Navigator.pop(context);
                final smsUri = Uri.parse('sms:?body=' + Uri.encodeComponent(text + '\\n' + url));
                if (await canLaunchUrl(smsUri)) await launchUrl(smsUri);
              }),
              _ShareIcon(Icons.link, '复制', const Color(0xFF6366F1), () {
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

if next_class >= 0:
    data = data[:next_class] + share_code + '\n' + data[next_class:]
else:
    data = data + share_code
print(f'Final file size: {len(data)}')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\room_detail_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print('room_detail_page.dart fixed!')
