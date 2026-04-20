with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\property_edit_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Fix RoomType - replace the entire Row with choices
# Find and replace the map for RoomType
old_type_map = "RoomType.values.map((t) => Padding(\n                padding: const EdgeInsets.only(right: 8),\n                child: ChoiceChip(\n                  label: Text(t.label),"
new_type_map = "RoomType.values.map((t) {\n                final lbl = t == RoomType.whole ? '整租' : t == RoomType.shared ? '合租' : '独栋';\n                return Padding(\n                padding: const EdgeInsets.only(right: 8),\n                child: ChoiceChip(\n                  label: Text(lbl),"

if old_type_map in data:
    data = data.replace(old_type_map, new_type_map)
    print("Fixed RoomType map!")
else:
    print("RoomType map pattern not found")

# Also need to close the map differently
# Replace the closing ') )).toList())))'
old_close = "              )).toList()))"
new_close = "              )).toList())"
if old_close in data:
    data = data.replace(old_close, new_close)
    print("Fixed closing")
else:
    print("Closing pattern not found")

# Fix RoomStatus - same approach
old_status_map = "[RoomStatus.available, RoomStatus.rented, RoomStatus.unavailable].map((s) => Padding(\n                  padding: const EdgeInsets.only(right: 8),\n                  child: ChoiceChip(\n                    label: Text(s.statusLabel),"
new_status_map = "[RoomStatus.available, RoomStatus.rented, RoomStatus.unavailable].map((s) {\n                  final lbl = s == RoomStatus.available ? '未出租' : s == RoomStatus.rented ? '已出租' : '不可租';\n                  return Padding(\n                  padding: const EdgeInsets.only(right: 8),\n                  child: ChoiceChip(\n                    label: Text(lbl),"

if old_status_map in data:
    data = data.replace(old_status_map, new_status_map)
    print("Fixed RoomStatus map!")
else:
    print("RoomStatus map pattern not found")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\property_edit_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
