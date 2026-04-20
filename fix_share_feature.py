# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    home_data = f.read()

# ============================================================
# 1. Add url_launcher and room import to landlord_home.dart
# ============================================================
if "import 'package:url_launcher/url_launcher.dart';" not in home_data:
    # Add after the first import
    first_import_end = home_data.find("\n")
    home_data = "import 'package:url_launcher/url_launcher.dart';\n" + home_data
    print('1. Added url_launcher import')

if "import 'package:gongyu_guanjia/models/room.dart';" not in home_data:
    home_data = "import 'package:gongyu_guanjia/models/room.dart';\n" + home_data
    print('1b. Added room import')

# ============================================================
# 2. Replace _showShare() method completely
# ============================================================
old_show_share = """  void _showShare() {
    showModalBottomSheet(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (_) => Container(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('空房分享', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      const Text('房源类型', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [Chip(label: const Text('全部')), Chip(label: const Text('整租')), Chip(label: const Text('合租')), Chip(label: const Text('独栋'))]),
      const SizedBox(height: 16),
      const Text('出租状态', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [Chip(label: const Text('未出租')), Chip(label: const Text('已出租')), Chip(label: const Text('预定中'))]),
    ])));
  }"""

new_show_share = """  void _showShare() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _VacantRoomShareSheet(
        onRoomTap: (room) {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => RoomDetailPage(room: room),
          ));
        },
      ),
    );
  }"""

if old_show_share in home_data:
    home_data = home_data.replace(old_show_share, new_show_share)
    print('2. Replaced _showShare() method')
else:
    print('WARNING: _showShare() pattern not found')
    print(repr(home_data[home_data.find('void _showShare'):home_data.find('void _showShare')+500]))

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'w', encoding='utf-8') as f:
    f.write(home_data)
print(f'home_data size: {len(home_data)}')
print('Part 1 saved!')
