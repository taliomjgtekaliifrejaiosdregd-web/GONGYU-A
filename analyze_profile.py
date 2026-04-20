with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\tenant_home.dart', 'rb') as f:
    data = f.read()

items = [
    (b'\xe7\xa7\x9f\xe6\x88\xbf\xe8\xae\xa2\xe5\x8d\x95', '租房订单'),
    (b'\xe5\xa5\xbd\xe7\x89\xa9\xe8\xae\xa2\xe5\x8d\x95', '好物订单'),
    (b'\xe5\xbf\x97\xe8\xb4\xa8', '快递查询'),
    (b'\xe6\x94\xb6\xe8\x97\x8f', '收藏'),
    (b'\xe6\xb5\x8f\xe8\xa7\x86\xe5\x8e\x86\xe5\x8f\xb2', '浏览历史'),
    (b'\xe6\x88\x90\xe4\xba\xba\xe8\xba\xab\xe4\xbb\xbd', '成年人'),
    (b'\xe7\x94\xb5\xe5\x95\x86', '电商'),
    (b'profile', 'profile'),
    (b'_buildProfile', 'profile'),
    (b'Navigator.push', 'nav'),
]

for bts, name in items:
    idx = data.find(bts)
    if idx >= 0:
        snippet = data[idx:idx+80].decode('utf-8', errors='replace')
        print(f'{name} @ {idx}: {snippet[:60]}')
    else:
        print(f'{name}: NOT FOUND')
