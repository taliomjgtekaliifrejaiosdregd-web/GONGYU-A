with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\tenant_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find all class definitions in the file
classes = []
idx = 0
while True:
    idx = data.find('class _', idx)
    if idx < 0:
        break
    # Find the class name
    end = data.find(' ', idx + 6)
    class_name = data[idx+6:end].strip()
    if '(' in class_name:
        class_name = class_name[:class_name.find('(')]
    classes.append((idx, class_name.strip()))
    idx += 1

print(f"Total classes found: {len(classes)}")
for pos, name in classes:
    print(f"  {name} at {pos}")
