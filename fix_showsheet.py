# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find _showTemplateSheet in _CreateContractPageState
idx = data.find('void _showTemplateSheet(BuildContext context) {')
print(f'_showTemplateSheet at {idx}')

# Find its end - before 'void _showDatePicker'
end_idx = data.find('void _showDatePicker')
print(f'_showDatePicker at {end_idx}')

# Find the method boundaries
# The method starts at 'void _showTemplateSheet' 
# Find the start of the previous line
start_method = data.rfind('\n  ', 0, idx)
start_method = data.rfind('\n', 0, start_method)
print(f'Method starts at {start_method}')
print(f'Method content: {repr(data[start_method:end_idx])}')

# Remove it
new_data = data[:start_method] + data[end_idx:]
print(f'Before: {len(data)}, After: {len(new_data)}')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'w', encoding='utf-8') as f:
    f.write(new_data)
print('Saved!')
