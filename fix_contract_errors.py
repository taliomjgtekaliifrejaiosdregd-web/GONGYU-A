# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

errors = 0

# 1. Fix duplicate _showTemplateSheet - rename the one in _TemplateSelectorState
old = """class _TemplateSelectorState extends State<_TemplateSelector> {
  void _openSheet() {"""
new = """class _TemplateSelectorState extends State<_TemplateSelector> {
  void _openTemplateSheet() {"""
if old in data:
    data = data.replace(old, new)
    print('1. Renamed _openSheet to _openTemplateSheet')
    errors += 1

# Fix the call to _openSheet -> _openTemplateSheet
old2 = "onTap: _openSheet,"
new2 = "onTap: _openTemplateSheet,"
if old2 in data:
    data = data.replace(old2, new2)
    print('2. Fixed _openSheet call')

# 2. Fix double 'const const SizedBox'
# These came from the template selector string having const, and the fix script also adding const
data = data.replace('const const SizedBox', 'const SizedBox')
print('3. Fixed const const SizedBox')

# 3. Fix nullable fileSize comparisons
data = data.replace('t.fileSize > 0', 't.fileSize! > 0')
data = data.replace('template.fileSize > 0', 'template.fileSize! > 0')
print('4. Fixed nullable fileSize comparisons')

# 4. Fix MockService._mockVersions -> MockService.getContractVersions()
# First add a getter to MockService, then fix the reference
# Add getter to MockService
with open(r'D:\Projects\gongyu_guanjia\lib\services\mock_service.dart', 'r', encoding='utf-8', errors='replace') as f:
    ms_data = f.read()

if 'getContractVersions' not in ms_data:
    # Find a good place to add the getter
    insert_marker = '// ==================== 租客房租订单'
    getter = '''

  /// 获取所有合同版本模板
  static List<ContractVersion> getContractVersions() => _mockVersions;

'''
    if insert_marker in ms_data:
        ms_data = ms_data.replace(insert_marker, getter + insert_marker)
        print('5a. Added getContractVersions() to MockService')
        with open(r'D:\Projects\gongyu_guanjia\lib\services\mock_service.dart', 'w', encoding='utf-8') as f:
            f.write(ms_data)
    else:
        print('5a. WARNING: Could not find insertion point in MockService')
else:
    print('5a. getContractVersions already in MockService')

# Fix reference in create_contract_page.dart
data = data.replace('MockService._mockVersions', 'MockService.getContractVersions()')
print('5b. Fixed MockService._mockVersions -> getContractVersions()')

# 5. Fix _formatDate accessibility in _TemplateCard
# _formatDate is a top-level function in create_contract_page.dart
# _TemplateCard is a top-level class and should be able to call _formatDate
# But _TemplateCard is defined BEFORE _formatDate in the file
# Let's move _formatDate before _TemplateCard, or add it as a static method
# Easiest: add a static method to _TemplateCard
old_format = """class _TemplateCard extends StatelessWidget {
  final ContractVersion template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.isSelected, required this.onTap});

  @override"""
new_format = """class _TemplateCard extends StatelessWidget {
  final ContractVersion template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.isSelected, required this.onTap});

  static String _fmtDate(DateTime d) {
    return '\${d.year}-\${d.month.toString().padLeft(2, '0')}-\${d.day.toString().padLeft(2, '0')}';
  }

  @override"""
if old_format in data:
    data = data.replace(old_format, new_format)
    print('6a. Added _fmtDate static method to _TemplateCard')
    # Also update the usage
    data = data.replace('_formatDate(template.createdAt)', '_fmtDate(template.createdAt)')
    print('6b. Updated _formatDate calls in _TemplateCard')
else:
    print('6. WARNING: _TemplateCard pattern not found')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print(f'Final size: {len(data)}')
print('Done!')
