# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# 1. Remove duplicate _showTemplateSheet from _TemplateSelectorState
# The second _showTemplateSheet (at 13391) is in _TemplateSelectorState and duplicates the one in _CreateContractPageState
# Find and remove the second occurrence
# It starts at 'void _showTemplateSheet(BuildContext context) {'
# and ends before 'class _TemplateSheetContent'
# We need to find where it starts and ends

# Find the second _showTemplateSheet
idx1 = data.find('void _showTemplateSheet')
idx2 = data.find('void _showTemplateSheet', idx1+1)
print(f'First _showTemplateSheet at {idx1}')
print(f'Second _showTemplateSheet at {idx2}')

# Find where the second one ends - before 'class _TemplateSheetContent'
if idx2 >= 0:
    end_of_second = data.find('class _TemplateSheetContent', idx2)
    if end_of_second >= 0:
        # The method starts at the method declaration
        # Find the 'void _showTemplateSheet(BuildContext context) {' start
        method_start = data.rfind('\n  ', 0, idx2+1)
        method_start = data.rfind('\n', 0, method_start+1)
        print(f'Second _showTemplateSheet method: {method_start} to {end_of_second}')
        # Remove the second method (from method_start to end_of_second)
        data = data[:method_start] + data[end_of_second:]
        print(f'Removed duplicate _showTemplateSheet')
    else:
        print('WARNING: class _TemplateSheetContent not found after second method')

# 2. Fix _showTemplateSheet in _CreateContractPageState to use _openTemplateSheet
# Find the _showTemplateSheet in _CreateContractPageState and update it
idx = data.find('void _showTemplateSheet')
if idx >= 0:
    # This should be the one in _CreateContractPageState
    # Change its body to call _openTemplateSheet
    # Find the method body
    body_start = data.find('{', idx)
    # Find the matching closing brace
    depth = 0
    i = body_start
    while i < len(data):
        if data[i] == '{': depth += 1
        elif data[i] == '}':
            depth -= 1
            if depth == 0:
                break
        i += 1
    # The method body is from body_start to i (inclusive)
    old_method = data[idx:i+1]
    new_method = """void _openTemplateSheet(BuildContext context) {
    _TemplateSelector.openTemplateSheetStatic(context, _selectedTemplate, (t) {
      setState(() => _selectedTemplate = t);
      if (t != null) _contractVersionCtrl.text = t.version;
    });
  }
"""
    if old_method in data:
        data = data.replace(old_method, new_method)
        print('Replaced _showTemplateSheet with _openTemplateSheet')
    else:
        print('WARNING: Could not replace _showTemplateSheet')
        print('Old method:', repr(old_method[:100]))

# 3. Add static helper to _TemplateSelector for static access
# Find class _TemplateSelector
selector_start = data.find('class _TemplateSelector')
if selector_start >= 0:
    # Add static open method after the class definition
    insert_pos = data.find('{', selector_start)
    # Find the end of the class opening
    depth = 0
    i = insert_pos
    while i < len(data):
        if data[i] == '{': 
            depth += 1
        elif data[i] == '}':
            depth -= 1
            if depth == 0:
                break
        i += 1
    static_method = """
  /// 静态方法：打开模板选择弹窗（供外部调用）
  static void openTemplateSheetStatic(BuildContext context, ContractVersion? selected, void Function(ContractVersion?) onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => _TemplateSheetContent(
          selectedTemplate: selected,
          versionCtrl: TextEditingController(),
          onSelected: onChanged,
        ),
      ),
    );
  }
"""
    data = data[:i+1] + static_method + data[i+1:]
    print('Added openTemplateSheetStatic helper')

# 4. Fix double 'const const'
data = data.replace('const const SizedBox', 'const SizedBox')
data = data.replace('const const const SizedBox', 'const SizedBox')
print('Fixed const const')

# 5. Fix nullable fileSize comparisons
data = data.replace('t.fileSize > 0', 't.fileSize != null && t.fileSize! > 0')
data = data.replace('template.fileSize > 0', 'template.fileSize != null && template.fileSize! > 0')
print('Fixed nullable fileSize')

# 6. Fix MockService reference
data = data.replace('MockService._mockVersions', 'MockService.getContractVersions()')
print('Fixed MockService._mockVersions')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print(f'Final size: {len(data)}')
print('Saved!')
