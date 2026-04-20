# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'rb') as f:
    raw = f.read()

# Find 合同版本 * (contract version)
needle = '合同版本 *'.encode('utf-8')
idx = raw.find(needle)
print(f'合同版本 * at {idx}')

# Show context
with open(r'D:\temp_ver8.txt', 'wb') as out:
    out.write(raw[idx-500:idx+800])
print('done')
