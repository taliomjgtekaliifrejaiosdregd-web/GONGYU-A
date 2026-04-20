with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\tenant_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

idx = data.find('_banners = [')
if idx >= 0:
    content = data[idx:idx+3000]
    # Write to file
    with open(r'D:\Projects\gongyu_guanjia\banners_output.txt', 'w', encoding='utf-8') as out:
        out.write(content)
    print("Written to banners_output.txt")
