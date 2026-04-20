# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f'File size before: {len(data)}')

# Strategy:
# 1. Find and REMOVE the _showTemplateSheet from _CreateContractPageState (it's unused since we use _TemplateSelector widget)
# 2. Fix _TemplateSelectorState._openSheet to create the sheet directly (remove the static helper approach)
# 3. Fix const const issues
# 4. Fix nullable fileSize
# 5. Fix MockService reference
# 6. Fix _formatDate in _TemplateCard

# 1. Remove _showTemplateSheet from _CreateContractPageState
# Find both occurrences
idx_list = []
idx = data.find('void _showTemplateSheet')
while idx >= 0:
    idx_list.append(idx)
    idx = data.find('void _showTemplateSheet', idx+1)

print(f'_showTemplateSheet occurrences: {len(idx_list)} at {idx_list}')

if len(idx_list) >= 2:
    # Keep the one at the FIRST position (in _TemplateSelectorState - it's actually the SECOND in the file)
    # Remove the one in _CreateContractPageState (the LAST one)
    # Actually let me find which one is in _CreateContractPageState
    # The one BEFORE _TemplateSheetContent is in _TemplateSelectorState
    # The one AFTER _showRoomPicker but BEFORE _TemplateSheetContent is in _CreateContractPageState
    
    # Find _TemplateSheetContent position
    tsc_pos = data.find('class _TemplateSheetContent')
    print(f'_TemplateSheetContent at {tsc_pos}')
    
    # The _showTemplateSheet closest BEFORE tsc_pos is in _TemplateSelectorState
    # The one BEFORE that is in _CreateContractPageState
    # Find the one closest to but before tsc_pos
    candidates = [i for i in idx_list if i < tsc_pos]
    print(f'Candidates before _TemplateSheetContent: {candidates}')
    # candidates[0] is in _TemplateSelectorState, candidates[1] is in _CreateContractPageState
    
    if len(candidates) >= 2:
        # Remove candidates[1] (the one in _CreateContractPageState)
        # Find its exact boundaries
        remove_start = data.rfind('\n  ', 0, candidates[1]+1)
        remove_start = data.rfind('\n', 0, remove_start)
        # Find where it ends - before 'class _TemplateSheetContent'
        remove_end = candidates[0]  # end before the first occurrence
        print(f'Removing from {remove_start} to {remove_end}')
        data = data[:remove_start] + data[remove_end:]
        print(f'Removed _showTemplateSheet from _CreateContractPageState')

# 2. Fix _openSheet in _TemplateSelectorState to create sheet directly (no Navigator.pop needed in callback)
# Find the _openSheet method
old_opensheet = """  void _openSheet() {
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
          selectedTemplate: widget.selectedTemplate,
          versionCtrl: widget.versionCtrl,
          onSelected: (t) => widget.onChanged(t),
        ),
      ),
    );
  }"""

new_opensheet = """  void _openSheet() {
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
  }"""

if old_opensheet in data:
    data = data.replace(old_opensheet, new_opensheet)
    print('Fixed _openSheet method')
else:
    print('WARNING: _openSheet pattern not found')

# 3. Fix double const
data = data.replace('const const SizedBox', 'const SizedBox')
data = data.replace('const const const SizedBox', 'const SizedBox')
data = data.replace('const const ', 'const ')
print('Fixed const const')

# 4. Fix nullable fileSize
data = data.replace('t.fileSize > 0', 't.fileSize != null && t.fileSize! > 0')
data = data.replace('template.fileSize > 0', 'template.fileSize != null && template.fileSize! > 0')
print('Fixed nullable fileSize')

# 5. Fix MockService reference
data = data.replace('MockService._mockVersions', 'MockService.getContractVersions()')
print('Fixed MockService reference')

# 6. Fix _formatDate in _TemplateCard - add static method or use top-level _formatDate
# Find _TemplateCard class and add static _fmtDate method
old_card = """class _TemplateCard extends StatelessWidget {
  final ContractVersion template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.isSelected, required this.onTap});

  @override"""

new_card = """class _TemplateCard extends StatelessWidget {
  final ContractVersion template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.isSelected, required this.onTap});

  String _fmtDate(DateTime d) {
    return '\${d.year}-\${d.month.toString().padLeft(2, '0')}-\${d.day.toString().padLeft(2, '0')}';
  }

  @override"""

if old_card in data:
    data = data.replace(old_card, new_card)
    print('Added _fmtDate to _TemplateCard')
    data = data.replace('_formatDate(template.createdAt)', '_fmtDate(template.createdAt)')
    print('Updated _formatDate calls in _TemplateCard')
else:
    print('WARNING: _TemplateCard pattern not found')

# 7. Remove the _showTemplateSheet static helper if it exists
old_static = """  /// 静态方法：打开模板选择弹窗（供外部调用）
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
if old_static in data:
    data = data.replace(old_static, '')
    print('Removed static helper')

# 8. Remove _openTemplateSheet in _CreateContractPageState if it exists
if 'void _openTemplateSheet' in data:
    # Find and remove
    idx = data.find('void _openTemplateSheet')
    if idx >= 0:
        end = data.find('\n  ', idx+20)
        if end < 0:
            end = data.find('\n\n', idx)
        if end < 0: end = idx + 500
        data = data[:idx] + data[end:]
        print('Removed _openTemplateSheet from _CreateContractPageState')

print(f'File size after: {len(data)}')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print('Saved!')
