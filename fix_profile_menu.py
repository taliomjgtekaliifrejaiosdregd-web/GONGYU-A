with open(r'D:\Projects\gongyu_guanjia\lib\pages\profile_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Add imports
if 'help_center_page' not in data:
    data = data.replace(
        "import 'package:gongyu_guanjia/pages/tenant/browse_history_page.dart';",
        "import 'package:gongyu_guanjia/pages/tenant/browse_history_page.dart';\nimport 'package:gongyu_guanjia/pages/tenant/help_center_page.dart';\nimport 'package:gongyu_guanjia/pages/tenant/feedback_page.dart';"
    )
    print("Added imports")

# Find the '浏览历史' menu item
if '帮助中心' not in data:
    idx = data.find("浏览历史")
    if idx >= 0:
        # Find the end of the 浏览历史 line
        # The pattern is: " _MenuTile(Icons.history, '浏览历史', '最近查看的房源', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BrowseHistoryPage()))),"
        # We want to add after this
        line_end = data.find('});', idx) + 2
        new_items = "\n              _MenuTile(Icons.help_outline, '帮助中心', '常见问题与解答', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage()))),\n              _MenuTile(Icons.feedback_outlined, '意见反馈', '提交问题与建议', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackPage()))),"
        data = data[:line_end] + new_items + data[line_end:]
        print("Added menu items at position", line_end)
    else:
        print("浏览历史 not found")
else:
    print("Menu items already present")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\profile_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
