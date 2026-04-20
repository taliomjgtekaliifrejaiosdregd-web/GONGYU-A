d = open(r'D:\Projects\gongyu_guanjia\lib\main.dart', 'r', encoding='utf-8', errors='replace').read()
for kw in ['repair-manage', 'termination-manage', '/alert', 'repair-list']:
    print(f'{kw}: {kw in d}')
