# -*- coding: utf-8 -*-
"""
Add publish toggle to landlord_property_page.dart:
1. Add _togglePublish method to _LandlordPropertyPageState
2. Add publish button to room card
"""
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_property_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# 1. Add _togglePublish method to the State class
# Find the end of _LandlordPropertyPageState class body (before the next class)
state_end_marker = "class _FChip extends StatelessWidget"
state_end_idx = data.find(state_end_marker)

if state_end_idx < 0:
    print("ERROR: _FChip class not found!")
    exit(1)

toggle_method = '''
  /// 上下架房源
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

'''

if '_togglePublish' not in data:
    data = data[:state_end_idx] + toggle_method + data[state_end_idx:]
    print("Added _togglePublish method!")
else:
    print("_togglePublish already exists")

# 2. Replace the room card to add publish button
# The old card ends with the three buttons + closing ])
# Let's find the Row with the three action buttons and replace it

old_buttons = """Row(children: [
              Expanded(child: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyEditPage(room: r))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit, size: 16, color: AppColors.primary), SizedBox(width: 4), Text('\ufffde\ufffd\ufffd', style: TextStyle(fontSize: 12, color: AppColors.primary))]))),
              Container(width: 1, height: 20, color: Colors.grey.shade200),
              Expanded(child: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomContractPage(room: r))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.description, size: 16, color: AppColors.primary), SizedBox(width: 4), Text('\ufffd\ufffd\ufffd', style: TextStyle(fontSize: 12, color: AppColors.primary))]))),
              Container(width: 1, height: 20, color: Colors.grey.shade200),
              Expanded(child: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyStatsPage(room: r))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bar_chart, size: 16, color: AppColors.primary), SizedBox(width: 4), Text('\ufffd\ufffd\ufffd', style: TextStyle(fontSize: 12, color: AppColors.primary))]))),
            ]),"""

# Search for the actual pattern (with escaped unicode)
# Find the Divider and the Row after it
divider_idx = data.find('const Divider(height: 16),')
if divider_idx < 0:
    print("ERROR: Divider not found!")
else:
    # Find the Row after the Divider
    row_start = data.find('Row(children: [', divider_idx)
    row_end = data.find(']),\n          ]));', row_start)
    if row_start > 0 and row_end > 0:
        old_row = data[row_start:row_end+len(']),')]
        print(f"Found Row: {repr(old_row[:100])}")
        
        # Build new row with 4 buttons
        new_row = """Row(children: [
              Expanded(child: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyEditPage(room: r))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit, size: 16, color: AppColors.primary), SizedBox(width: 4), Text('编辑', style: TextStyle(fontSize: 12, color: AppColors.primary))]))),
              Container(width: 1, height: 20, color: Colors.grey.shade200),
              Expanded(child: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomContractPage(room: r))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.description, size: 16, color: AppColors.primary), SizedBox(width: 4), Text('合同', style: TextStyle(fontSize: 12, color: AppColors.primary))]))),
              Container(width: 1, height: 20, color: Colors.grey.shade200),
              Expanded(child: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyStatsPage(room: r))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bar_chart, size: 16, color: AppColors.primary), SizedBox(width: 4), Text('统计', style: TextStyle(fontSize: 12, color: AppColors.primary))]))),
              Container(width: 1, height: 20, color: Colors.grey.shade200),
              Expanded(child: GestureDetector(onTap: () => _togglePublish(r), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(r.isPublished ? Icons.visibility_off : Icons.visibility, size: 16, color: r.isPublished ? const Color(0xFF10B981) : const Color(0xFFF59E0B)), SizedBox(width: 4), Text(r.isPublished ? '下架' : '上架', style: TextStyle(fontSize: 12, color: r.isPublished ? const Color(0xFF10B981) : const Color(0xFFF59E0B)))]))),
            ]),"""
        
        if old_row in data:
            data = data.replace(old_row, new_row)
            print("Replaced row with 4 buttons!")
        else:
            print("ERROR: old_row not found in data!")
            # Print actual content
            print(repr(old_row[:200]))
    else:
        print(f"ERROR: row_start={row_start}, row_end={row_end}")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_property_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
