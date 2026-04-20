with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\property_edit_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find the RoomType section using a unique anchor
anchor_start = "final lbl = t == RoomType.whole"
anchor_end = ".toList())),"

idx_start = data.find(anchor_start)
idx_end = data.find(anchor_end, idx_start) + len(anchor_end)

print(f"Found section: {idx_start} to {idx_end}")

old_section = data[idx_start:idx_end]
print(f"Section length: {len(old_section)}")
print(repr(old_section[:200]))

# Replace with correct version
new_section = """final lbl = t == RoomType.whole ? '整租' : t == RoomType.shared ? '合租' : '独栋';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(lbl),
                      selected: _selectedType == t,
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(fontSize: 12, color: _selectedType == t ? AppColors.primary : Colors.black87),
                      onSelected: (_) => setState(() => _selectedType = t),
                    ),
                  );
                }),
              ])),
              const Divider(height: 1),
              _FieldRow('房源状态', child: Row(children: [
                ...[RoomStatus.available, RoomStatus.rented, RoomStatus.unavailable].map((s) {
                  final lbl = s == RoomStatus.available ? '未出租' : s == RoomStatus.rented ? '已出租' : '不可租';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(lbl),
                      selected: _selectedStatus == s,
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(fontSize: 12, color: _selectedStatus == s ? AppColors.primary : Colors.black87),
                      onSelected: (_) => setState(() => _selectedStatus = s),
                    ),
                  );
                }),
              ])),"""

data = data[:idx_start] + new_section + data[idx_end:]

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\property_edit_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
