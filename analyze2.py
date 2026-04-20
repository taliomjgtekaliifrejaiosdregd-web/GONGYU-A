with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\profile_page.dart', 'rb') as f:
    data = f.read()
print('File size:', len(data))

targets = [
    b'\xe7\xa7\x9f\xe6\x88\xbf',  # 租房
    b'\xe5\xa5\xbd\xe7\x89\xa9',  # 好物
    b'\xe5\xbf\x97\xe8\xb4\xa8',  # 快递
    b'\xe6\x94\xb6\xe8\x97\x8f',  # 收藏
    b'\xe6\xb5\x8f\xe8\xa7\x86',  # 浏览
    b'_build',
    b'Navigator.push',
    b'onTap',
]

for bts in targets:
    idx = data.find(bts)
    if idx >= 0:
        snippet = data[idx:idx+80].decode('utf-8', errors='replace')
        print('Found at', idx, ':', snippet[:70])
    else:
        print('NOT FOUND:', bts.decode('utf-8', errors='replace'))
