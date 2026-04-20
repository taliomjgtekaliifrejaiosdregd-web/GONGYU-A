with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\property_edit_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find the build method section and fix it
# The issue is in the build method - the RoomType and RoomStatus sections

# Let's look at the exact bytes of the problematic area
idx = data.find('final lbl = t == RoomType')
print(f"RoomType lbl at: {idx}")
if idx >= 0:
    print(repr(data[idx:idx+600]))
