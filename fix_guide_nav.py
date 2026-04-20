with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Check if guide_page is imported
if 'guide_page' in data:
    print("guide_page already imported")
else:
    print("Need to add guide_page import")
    # Add import
    data = data.replace(
        "import 'package:gongyu_guanjia/pages/landlord/landlord_device_page.dart';",
        "import 'package:gongyu_guanjia/pages/landlord/landlord_device_page.dart';\nimport 'package:gongyu_guanjia/pages/landlord/guide_page.dart';"
    )
    print("Added import")

# Fix the onTap: () {} in _buildGuide
# The pattern to find:
# old: GestureDetector(onTap: () {}, behavior: HitTestBehavior.opaque,
# new: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidePage())), behavior: HitTestBehavior.opaque,

old_pattern = "GestureDetector(onTap: () {}, behavior: HitTestBehavior.opaque,"
new_pattern = "GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidePage())), behavior: HitTestBehavior.opaque,"

if old_pattern in data:
    data = data.replace(old_pattern, new_pattern)
    print("Fixed onTap navigation!")
else:
    print("onTap pattern not found - checking actual text")
    # Find the actual pattern
    idx = data.find('onTap: () {}')
    if idx >= 0:
        print(repr(data[max(0,idx-50):idx+100]))

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
