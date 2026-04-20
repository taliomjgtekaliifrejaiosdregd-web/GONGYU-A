with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find all imports
idx = 0
while True:
    idx = data.find("import '", idx)
    if idx < 0:
        break
    end = data.find("'", idx + 8)
    if end < 0:
        break
    imp = data[idx:end+1]
    print(imp)
    idx = end + 1
