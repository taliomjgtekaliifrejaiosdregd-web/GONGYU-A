# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\room_detail_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Fix 1: Change _RoomShare._showShareSheet to _showRoomShareSheet
data = data.replace(
    "onPressed: () => _RoomShare._showShareSheet(context, room),",
    "onPressed: () => _showRoomShareSheet(context, room),"
)

# Fix 2: Fix the _shareText getter - replace mangled lines with clean ASCII version
# Find and replace the _shareText getter
old_sharetext = '''  String get _shareText =>
      room.title + "\\n" + room.layout + " �� " + room.area.toStringAsFixed(0) + "\\u7ac  "\\n" +
      "���� \\u00a5" + room.price.toStringAsFixed(0) + "/��\\n" +
      "��ַ��" + room.address + "\\n" +
      "����鿴���� \\u2192";'''

new_sharetext = '''  String get _shareText =>
      room.title + "\\n" + room.layout + " PINGMIAN " + room.area.toStringAsFixed(0) + "\\u5e73\\u7c73\\n" +
      "\\u6708\\u79df \\u00a5" + room.price.toStringAsFixed(0) + "/\\u6708\\n" +
      "\\u5730\\u5740\\uff1a" + room.address + "\\n" +
      "\\u70b9\\u51fb\\u67e5\\u770b\\u8be6\\u60c5 \\u2192";'''

if old_sharetext in data:
    data = data.replace(old_sharetext, new_sharetext)
    print('Fixed _shareText getter')
else:
    print('WARNING: _shareText pattern not found')
    # Try partial
    if '_shareText' in data:
        idx = data.find('_shareText')
        print('Found _shareText at', idx)
        # Find the getter and replace it
        start = data.find('=>', idx)
        end = data.find(';', idx)
        print('Getter:', repr(data[start:end+1]))
        # Replace with fixed version
        old_getter = data[start:end+1]
        new_getter = '''=> room.title + "\\n" + room.layout + " PINGMIAN " + room.area.toStringAsFixed(0) + "\\u5e73\\u7c73\\n" + "\\u6708\\u79df \\u00a5" + room.price.toStringAsFixed(0) + "/\\u6708\\n" + "\\u5730\\u5740\\uff1a" + room.address + "\\n" + "\\u70b9\\u51fb\\u67e5\\u770b\\u8be6\\u60c5 \\u2192";'''
        if old_getter in data:
            data = data.replace(old_getter, new_getter)
            print('Fixed via partial replacement')
        else:
            print('Could not fix _shareText getter')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\room_detail_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print('Saved!')
