with open(r'D:\Projects\gongyu_guanjia\lib\main.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Add imports
if 'help_center_page' not in data:
    data = data.replace(
        "import 'pages/tenant/browse_history_page.dart';",
        "import 'pages/tenant/browse_history_page.dart';\nimport 'pages/tenant/help_center_page.dart';\nimport 'pages/tenant/feedback_page.dart';"
    )
    print("Added imports")

# Add routes
if '/help-center' not in data:
    data = data.replace(
        "'/browse-history': (_) => const BrowseHistoryPage(),",
        "'/browse-history': (_) => const BrowseHistoryPage(),\n        '/help-center': (_) => const HelpCenterPage(),\n        '/feedback': (_) => const FeedbackPage(),"
    )
    print("Added routes")
else:
    print("Routes already present")

with open(r'D:\Projects\gongyu_guanjia\lib\main.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
