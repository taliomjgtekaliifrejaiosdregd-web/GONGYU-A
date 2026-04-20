# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find _openSheet
idx = data.find('void _openSheet() {')
print(f'_openSheet at {idx}')

# Read the actual content
method_end = data.find('\n\n  @override', idx)
print(f'Method ends at {method_end}')

old_method = data[idx:method_end]
print(f'Old method length: {len(old_method)}')
print(f'Old method: {repr(old_method[:300])}')

# New method
new_method = """void _openSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _TemplateSheetContent(
        selectedTemplate: widget.selectedTemplate,
        versionCtrl: widget.versionCtrl,
        onSelected: (t) {
          widget.onChanged(t);
          Navigator.pop(context);
        },
      ),
    );
  }

"""

if old_method in data:
    data = data.replace(old_method, new_method)
    print('Fixed _openSheet!')
else:
    print('WARNING: method not found')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print('Saved!')
