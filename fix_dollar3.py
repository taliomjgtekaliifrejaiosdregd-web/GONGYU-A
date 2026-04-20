with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\my_favorites_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find the exact bytes
idx = data.find("_Count('")
print("Found _Count at:", idx)
snippet = data[idx:idx+20]
print("Snippet:", repr(snippet))

# Replace using exact match
old = "_Count('$'),"
new = "_Count(''),"
if old in data:
    data = data.replace(old, new)
    print("Replaced!")
else:
    print("NOT FOUND:", repr(old))
    # Find all occurrences of $ in the area
    for i, ch in enumerate(data[idx:idx+50]):
        if ch == '$':
            print(f"$ found at offset {i}:", repr(data[idx+i-5:idx+i+10]))

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\my_favorites_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("done")
