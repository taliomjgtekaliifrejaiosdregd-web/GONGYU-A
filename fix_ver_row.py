# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f'File size: {len(data)}')

# 1. Fix the contract version field - remove the * and validator
old_ver = """                  label: '合同版本 *',
                  hint: '如 V1.0',
                  controller: _contractVersionCtrl,
                  icon: Icons.history,
                  validator: (v) => v == null || v.isEmpty ? '请输入版本号' : null,"""

new_ver = """                  label: '合同版本',
                  hint: '如 V1.0',
                  controller: _contractVersionCtrl,
                  icon: Icons.history,"""

if old_ver in data:
    data = data.replace(old_ver, new_ver)
    print('Fixed contract version field (removed * and validator)')
else:
    print('WARNING: contract version field pattern not found')

# 2. Add template selector AFTER the contract version row (after the Row that ends with contract version)
# Find: "])," followed by "const SizedBox(height: 12)," followed by "// 日期选择"
# We want to insert our selector between the contract info row and the date row
old_after = """            ]),
            const SizedBox(height: 12),

            // 日期选择"""

new_after = """            ]),
            const SizedBox(height: 10),

            // 合同模板选择
            _TemplateSelector(
              selectedTemplate: _selectedTemplate,
              versionCtrl: _contractVersionCtrl,
              onChanged: (t) => setState(() => _selectedTemplate = t),
            ),

            const SizedBox(height: 12),

            // 日期选择"""

if old_after in data:
    data = data.replace(old_after, new_after)
    print('Added template selector section')
else:
    print('WARNING: could not find insertion point for template selector')
    # Try partial
    if '// 日期选择' in data:
        idx = data.find('// 日期选择')
        print(f'// 日期选择 found at {idx}')
        print(repr(data[idx-200:idx]))

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print(f'Final size: {len(data)}')
print('Saved!')
