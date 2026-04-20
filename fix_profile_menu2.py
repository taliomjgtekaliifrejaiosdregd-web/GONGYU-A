with open(r'D:\Projects\gongyu_guanjia\lib\pages\profile_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Fix 帮助中心 menu item
data = data.replace(
    "Icons.help_outline, '帮助中心', '常见问题与解答', () {})",
    "Icons.help_outline, '帮助中心', '常见问题与解答', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage())))"
)

# Fix 意见反馈 menu item
data = data.replace(
    "Icons.feedback_outlined, '意见反馈', '提交问题与建议', () {})",
    "Icons.feedback_outlined, '意见反馈', '提交问题与建议', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackPage())))"
)

# Verify
for pattern in ['HelpCenterPage', 'FeedbackPage', 'Navigator.push']:
    idx = data.find(pattern)
    if idx >= 0:
        print(f"Found: {pattern} at {idx}")
    else:
        print(f"NOT FOUND: {pattern}")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\profile_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
