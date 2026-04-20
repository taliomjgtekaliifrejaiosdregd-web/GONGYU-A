with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\my_favorites_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Fix the $ string issue - escape the dollar sign
data = data.replace("_Count('\$'),", "_Count(''),")

# Also check for other $ issues
if "$" in data and "favorite" in data.lower():
    idx = data.find("_Count('")
    print("Found _Count at", idx, ":", repr(data[idx:idx+20]))

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\my_favorites_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("done")
