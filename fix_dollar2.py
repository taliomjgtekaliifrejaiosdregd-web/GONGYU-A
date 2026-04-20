with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\my_favorites_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find and show the problematic line
idx = data.find("_Count('")
print("Found _Count at:", idx)
print("Content:", repr(data[idx:idx+30]))

# The issue is _Count('$'):  - need to escape $ or use a different approach
# Replace with empty string since _Count is just for showing badge when count > 0
data = data.replace("_Count('\$'),", "_Count(''),")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\my_favorites_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("done")
