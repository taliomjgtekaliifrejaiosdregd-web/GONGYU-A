with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\tenant_home.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

idx = data.find('_banners = [')
if idx >= 0:
    print(data[idx:idx+3000])
