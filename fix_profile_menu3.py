with open(r'D:\Projects\gongyu_guanjia\lib\pages\profile_page.dart', 'rb') as f:
    data = f.read()

# Fix 帮助中心: () {}) -> Navigator.push...
old_help = b"_MenuTile(Icons.help_outline, '\xe5\xb8\xae\xe5\x8a\xa9\xe4\xb8\xad\xe5\xbf\x83', '\xe5\xb8\xb8\xe8\xa7\x81\xe9\x97\xae\xe9\xa2\x98\xe8\xa7\xa3\xe7\xad\x94', () {}),"
new_help = b"_MenuTile(Icons.help_outline, '\xe5\xb8\xae\xe5\x8a\xa9\xe4\xb8\xad\xe5\xbf\x83', '\xe5\xb8\xb8\xe8\xa7\x81\xe9\x97\xae\xe9\xa2\x98\xe8\xa7\xa3\xe7\xad\x94', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage()))),"

if old_help in data:
    data = data.replace(old_help, new_help)
    print("Fixed 帮助中心")
else:
    print("帮助中心 pattern not found!")

# Fix 意见反馈
old_feedback = b"_MenuTile(Icons.feedback_outlined, '\xe6\x84\x8f\xe8\xa7\x81\xe5\x8f\x8d\xe9\xa6\x88', '\xe6\x82\xa8\xe7\x9a\x84\xe5\xbb\xba\xe8\xae\xae\xe6\x98\xaf\xe6\x88\x91\xe4\xbb\xac\xe8\xbf\x99\xe4\xb8\x80\xe5\x90\x8d\xe6\x88\x90\xe4\xb8\xba\xe6\x82\xa8\xe5\xbb\xba\xe8\xae\xae', () {}),"
new_feedback = b"_MenuTile(Icons.feedback_outlined, '\xe6\x84\x8f\xe8\xa7\x81\xe5\x8f\x8d\xe9\xa6\x88', '\xe6\x82\xa8\xe7\x9a\x84\xe5\xbb\xba\xe8\xae\xae\xe6\x98\xaf\xe6\x88\x91\xe4\xbb\xac\xe8\xbf\x99\xe4\xb8\x80\xe5\x90\x8d\xe6\x88\x90\xe4\xb8\xba\xe6\x82\xa8\xe5\xbb\xba\xe8\xae\xae', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackPage()))),"

if old_feedback in data:
    data = data.replace(old_feedback, new_feedback)
    print("Fixed 意见反馈")
else:
    print("意见反馈 pattern not found!")

# Verify
if b'HelpCenterPage' in data:
    print("HelpCenterPage found in file!")
if b'FeedbackPage' in data:
    print("FeedbackPage found in file!")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\profile_page.dart', 'wb') as f:
    f.write(data)
print("Saved!")
