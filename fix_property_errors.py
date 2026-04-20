with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\property_edit_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Fix 1: RoomType.label -> switch statement
old_type_row = """              child: Row(children: RoomType.values.map((t) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(t.label),
                  selected: _selectedType == t,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(fontSize: 12, color: _selectedType == t ? AppColors.primary : Colors.black87),
                  onSelected: (_) => setState(() => _selectedType = t),
                ),
              )).toList())),"""

new_type_row = """              child: Row(children: RoomType.values.map((t) {
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
              }).toList())),"""

if old_type_row in data:
    data = data.replace(old_type_row, new_type_row)
    print("Fixed RoomType.label!")
else:
    print("WARNING: RoomType pattern not found")

# Fix 2: RoomStatus.statusLabel -> switch statement
old_status_row = """              child: Row(children: [
                ...[RoomStatus.available, RoomStatus.rented, RoomStatus.unavailable].map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s.statusLabel),
                    selected: _selectedStatus == s,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(fontSize: 12, color: _selectedStatus == s ? AppColors.primary : Colors.black87),
                    onSelected: (_) => setState(() => _selectedStatus = s),
                  ),
                )),
              ])),"""

new_status_row = """              child: Row(children: [
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

if old_status_row in data:
    data = data.replace(old_status_row, new_status_row)
    print("Fixed RoomStatus.statusLabel!")
else:
    print("WARNING: RoomStatus pattern not found")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\property_edit_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("property_edit_page.dart saved!")

# Fix 3: room_contract_page.dart - textAlign in TextStyle
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\room_contract_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

old_text = "const Text('租赁合同', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, textAlign: TextAlign.center)),"
new_text = "const Text('租赁合同', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),"

if old_text in data:
    data = data.replace(old_text, new_text)
    print("Fixed textAlign!")
else:
    print("WARNING: textAlign pattern not found")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\room_contract_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("room_contract_page.dart saved!")

# Fix 4: property_stats_page.dart - Icons.renew -> Icons.autorenew
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\property_stats_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

if 'Icons.renew' in data:
    data = data.replace('Icons.renew', 'Icons.autorenew')
    print("Fixed Icons.renew!")
else:
    print("WARNING: Icons.renew not found")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\property_stats_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("property_stats_page.dart saved!")
