# -*- coding: utf-8 -*-
"""
Update tenant_home.dart to:
1. Add static helper getPublishedRooms()
2. Use it in hot listings
"""
with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\tenant_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# 1. Add static helper method after the imports (before the first class)
# Find the position after the last import
last_import_idx = data.rfind("import 'package:gongyu_guanjia/pages/tenant/repair_report_page.dart';")
# Find the newline after it
newline_after_imports = data.find('\n', last_import_idx) + 1

helper_code = '''
// ==================== 房源数据辅助 ====================
/// 获取已发布且可租的房源（对接房东端房源管理）
List<Room> _getPublishedRooms() {
  return MockService.rooms.where((r) => r.isPublished && r.isAvailable).toList();
}

'''

# Check if already added
if '_getPublishedRooms' not in data:
    data = data[:newline_after_imports] + helper_code + data[newline_after_imports:]
    print("Added _getPublishedRooms helper!")
else:
    print("_getPublishedRooms already exists")

# 2. Replace the room fetching logic
old_code = '''(context, index) {
                final room = MockService.rooms[index % MockService.rooms.length];
                return _RoomGridCard(room: room);
              },
              childCount: 6,'''

new_code = '''(context, index) {
                final _hot = _getPublishedRooms();
                if (_hot.isEmpty) return const SizedBox();
                final room = _hot[index % _hot.length];
                return _RoomGridCard(room: room);
              },
              childCount: _getPublishedRooms().isEmpty ? 0 : 6,'''

if old_code in data:
    data = data.replace(old_code, new_code)
    print("Updated room fetching logic!")
else:
    print("ERROR: old_code not found!")
    # Try to find what's actually there
    idx = data.find('MockService.rooms[index %')
    print(repr(data[idx-30:idx+200]))

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\tenant_home.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
