with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\feedback_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Fix syntax error
data = data.replace("const SizedBox width: 4)", "const SizedBox(width: 4)")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\feedback_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("done")
