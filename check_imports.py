with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_property_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()
# Show first 15 lines
for i, line in enumerate(data.split('\n')[:15]):
    print(f'{i+1}: {line}')
