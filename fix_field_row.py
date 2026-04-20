with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\property_edit_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# The broken section (lines 151-177) - rewrite it entirely
# The pattern to find is the entire _FieldRow for房源类型 through _FieldRow for房源状态

# Find and replace the broken section
old_section = """              _FieldRow('房源类型', child: Row(children: RoomType.values.map((t) {
                final lbl = t == RoomType.whole ? '整租' : t == RoomType.shared ? '合租' : '独栋';
                return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(lbl),
                  selected: _selectedType == t,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(fontSize: 12, color: _selectedType == t ? AppColors.primary : Colors.black87),
                  onSelected: (_) => setState(() => _selectedType = t),
                ),
              )).toList())),
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
                )),
              ])),"""

new_section = """              _FieldRow('房源类型', child: Row(children: [
                ...RoomType.values.map((t) {
                  final lbl = t == RoomType.whole ? '整租' : t == RoomType.shared ? '合租' : '独栋';
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

if old_section in data:
    data = data.replace(old_section, new_section)
    print("Fixed section!")
else:
    print("Pattern not found, trying shorter patterns")
    # Try shorter patterns
    if "RoomType.values.map((t) {" in data:
        print("Found RoomType.map lambda")
    if "房源类型" in data:
        print("Found 房源类型")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\property_edit_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
