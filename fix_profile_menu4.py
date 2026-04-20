with open(r'D:\Projects\gongyu_guanjia\lib\pages\profile_page.dart', 'rb') as f:
    data = f.read()

# Fix 意见反馈 - exact bytes from the file
old_feedback = b"_MenuTile(Icons.feedback_outlined, '\xe6\x84\x8f\xe8\xa7\x81\xe5\x8f\x8d\xe9\xa6\x88', '\xe6\x82\xa8\xe7\x9a\x84\xe5\xbb\xba\xe8\xae\xae\xe6\x98\xaf\xe6\x88\x91\xe4\xbb\xac\xe8\xbf\x9b\xe6\xad\xa5\xe7\x9a\x84\xe5\x8a\xa8\xe5\x8a\x9b', () {}),"
new_feedback = b"_MenuTile(Icons.feedback_outlined, '\xe6\x84\x8f\xe8\xa7\x81\xe5\x8f\x8d\xe9\xa6\x88', '\xe6\x82\xa8\xe7\x9a\x84\xe5\xbb\xba\xe8\xae\xae\xe6\x98\xaf\xe6\x88\x91\xe4\xbb\xac\xe8\xbf\x9b\xe6\xad\xa5\xe7\x9a\x84\xe5\x8a\xa8\xe5\x8a\x9b', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackPage()))),"

if old_feedback in data:
    data = data.replace(old_feedback, new_feedback)
    print("Fixed 意见反馈!")
else:
    print("Pattern not found!")
    # Try shorter pattern
    short = b"_MenuTile(Icons.feedback_outlined"
    idx = data.find(short)
    if idx >= 0:
        print("Found at", idx, ":", repr(data[idx:idx+250]))

if b'FeedbackPage' in data:
    print("FeedbackPage found!")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\profile_page.dart', 'wb') as f:
    f.write(data)
print("Saved!")
