with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\feedback_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Fix the broken SnackBar
old = "        const SnackBar(content: Text('请详细描述问题（至少10个字）', behavior: SnackBarBehavior.floating),\n          backgroundColor: Color(0xFFEF4444)),"
new = "        SnackBar(\n          content: Text('请详细描述问题（至少10个字）'),\n          behavior: SnackBarBehavior.floating,\n          backgroundColor: const Color(0xFFEF4444),\n        ),"

if old in data:
    data = data.replace(old, new)
    print("Fixed SnackBar!")
else:
    print("Pattern not found")
    # Show the actual content
    idx = data.find('SnackBarBehavior.floating')
    if idx >= 0:
        print(repr(data[max(0,idx-100):idx+200]))

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\feedback_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
