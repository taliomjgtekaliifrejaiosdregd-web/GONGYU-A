with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'rb') as f:
    data = f.read()

# The floor + 层 issue
old = " r.floor + '层'".encode('utf-8')
new = " r.floorText + '层'".encode('utf-8')

if old in data:
    data = data.replace(old, new)
    print('Fixed: r.floor -> r.floorText')
else:
    print('NOT FOUND, searching...')
    idx = data.find(b'floor')
    print(data[idx-10:idx+40])

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'wb') as f:
    f.write(data)
print('done')
