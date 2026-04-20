# -*- coding: utf-8 -*-
import re

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f'File size: {len(data)}')

# ============================================================
# 1. Add imports
# ============================================================
if "import 'package:file_picker/file_picker.dart';" not in data:
    # Find the contract import line and add file_picker after it
    if "import 'package:gongyu_guanjia/models/contract.dart';" in data:
        data = data.replace(
            "import 'package:gongyu_guanjia/models/contract.dart';",
            "import 'package:gongyu_guanjia/models/contract.dart';\nimport 'package:file_picker/file_picker.dart';"
        )
        print('Added file_picker import')

# ============================================================
# 2. Add _selectedTemplate field to _CreateContractPageState
# ============================================================
if 'ContractVersion? _selectedTemplate;' not in data:
    data = data.replace(
        "  DateTime _startDate = DateTime.now();",
        "  DateTime _startDate = DateTime.now();\n  ContractVersion? _selectedTemplate; // 选中的合同模板"
    )
    print('Added _selectedTemplate field')

# ============================================================
# 3. Replace the contract version row section
# ============================================================
# Find the contract version FormTextField row
# Pattern: Row([ Expanded(_FormTextField('合同版本 *', ...)) ])
old_ver = """            Row(children: [
              Expanded(
                child: _FormTextField(
                  label: '合同版本 *',
                  hint: '如 V1.0',
                  controller: _contractVersionCtrl,
                  icon: Icons.history,
                  validator: (v) => v == null || v.isEmpty ? '请输入版本号' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: '起租日期',
                  value: _formatDate(_startDate),
                  onTap: () => _showDatePicker(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: '到期日期',
                  value: _formatDate(_endDate),
                  onTap: () => _showDatePicker(context, false),
                ),
              ),
            ]),"""

new_ver = """            Row(children: [
              Expanded(
                child: _FormTextField(
                  label: '合同版本',
                  hint: '如 V1.0',
                  controller: _contractVersionCtrl,
                  icon: Icons.history,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: '起租日期',
                  value: _formatDate(_startDate),
                  onTap: () => _showDatePicker(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: '到期日期',
                  value: _formatDate(_endDate),
                  onTap: () => _showDatePicker(context, false),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            // 合同模板选择
            _TemplateSelector(
              selectedTemplate: _selectedTemplate,
              versionCtrl: _contractVersionCtrl,
              onChanged: (t) => setState(() => _selectedTemplate = t),
            ),"""

if old_ver in data:
    data = data.replace(old_ver, new_ver)
    print('Replaced contract version row with template selector')
else:
    print('WARNING: contract version row not found')
    # Try partial
    if "label: '合同版本 *'" in data:
        print("Found '合同版本 *' in file")
    if "_contractVersionCtrl," in data:
        print("Found _contractVersionCtrl in file")

# ============================================================
# 4. Add _showTemplateSheet method before _showDatePicker
# ============================================================
showdatepicker = "  void _showDatePicker(BuildContext context, bool isStart) {"

showtemplatesheet = """  void _showTemplateSheet(BuildContext context) {
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
          selectedTemplate: _selectedTemplate,
          versionCtrl: _contractVersionCtrl,
          onSelected: (t) {
            setState(() => _selectedTemplate = t);
            if (t != null) _contractVersionCtrl.text = t.version;
          },
        ),
      ),
    );
  }

"""

if showtemplatesheet not in data:
    if showdatepicker in data:
        data = data.replace(showdatepicker, showtemplatesheet + showdatepicker)
        print('Added _showTemplateSheet method')
    else:
        print('WARNING: _showDatePicker not found')
else:
    print('_showTemplateSheet already in file')

# ============================================================
# 5. Add new widget classes before _SummaryRow
# ============================================================
# Find the location to insert - before the date field section
date_field_comment = "// ============================================================\n// 日期选择字段\n// ============================================================"

template_widgets = """// ============================================================
// 合同模板选择器
// ============================================================
class _TemplateSelector extends StatefulWidget {
  final ContractVersion? selectedTemplate;
  final TextEditingController versionCtrl;
  final void Function(ContractVersion?) onChanged;

  const _TemplateSelector({
    required this.selectedTemplate,
    required this.versionCtrl,
    required this.onChanged,
  });

  @override
  State<_TemplateSelector> createState() => _TemplateSelectorState();
}

class _TemplateSelectorState extends State<_TemplateSelector> {
  void _openSheet() {
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
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.selectedTemplate;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('合同模板', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
        const SizedBox(width: 4),
        Text('（选填）', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
      ]),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _openSheet,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t != null ? AppColors.primary.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: t != null ? AppColors.primary.withOpacity(0.3) : const Color(0xFFE0E0E0),
            ),
          ),
          child: t == null
              ? Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.description_outlined, color: Colors.grey.shade400, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('点击选择模板', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                    const SizedBox(height: 2),
                    Text('从历史版本或上传新合同', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                  ])),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                ])
              : Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: t.isLocked ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      t.isLocked ? Icons.lock : Icons.description,
                      color: t.isLocked ? const Color(0xFF10B981) : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(t.fileName ?? '未命名模板', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: t.isLocked ? const Color(0xFF10B981).withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(t.lockLabel, style: TextStyle(fontSize: 9, color: t.isLocked ? const Color(0xFF10B981) : AppColors.primary, fontWeight: FontWeight.w500)),
                      ),
                    ]),
                    const SizedBox(height: 2),
                    Text(
                      t.fileSize > 0 ? '版本 ' + t.version + ' · ' + t.fileSizeLabel : '版本 ' + t.version,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Text('修改', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                ]),
        ),
      ),
      if (t != null) ...[
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.check_circle, color: const Color(0xFF10B981), size: 14),
          const SizedBox(width: 4),
          Text(
            t.isLocked ? '已锁定（' + (t.lockedBy ?? '') + '），不可修改内容' : '可编辑合同内容',
            style: TextStyle(fontSize: 11, color: t.isLocked ? Colors.grey.shade500 : const Color(0xFF10B981)),
          ),
        ]),
      ],
    ]);
  }
}

// ============================================================
// 合同模板选择弹窗内容
// ============================================================
class _TemplateSheetContent extends StatefulWidget {
  final ContractVersion? selectedTemplate;
  final TextEditingController versionCtrl;
  final void Function(ContractVersion?) onSelected;

  const _TemplateSheetContent({
    required this.selectedTemplate,
    required this.versionCtrl,
    required this.onSelected,
  });

  @override
  State<_TemplateSheetContent> createState() => _TemplateSheetContentState();
}

class _TemplateSheetContentState extends State<_TemplateSheetContent> {
  final _uploadVersionCtrl = TextEditingController();
  bool _isUploading = false;
  String? _uploadedFileName;

  @override
  void dispose() {
    _uploadVersionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _uploadedFileName = file.name;
          _uploadVersionCtrl.text = 'V1.0';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择文件失败: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _confirmUpload() {
    if (_uploadedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要上传的合同文件'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final newTemplate = ContractVersion(
      id: "upload-" + DateTime.now().millisecondsSinceEpoch.toString(),
      version: _uploadVersionCtrl.text.isEmpty ? 'V1.0' : _uploadVersionCtrl.text,
      fileName: _uploadedFileName,
      fileUrl: '/uploads/' + _uploadedFileName!,
      fileSize: 0,
      createdAt: DateTime.now(),
      isLocked: false,
    );
    widget.onSelected(newTemplate);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final templates = MockService._mockVersions;

    return Column(children: [
      // Header
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(children: [
          const Text('选择合同模板', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ]),
      ),
      Expanded(
        child: ListView(
          controller: ScrollController(),
          padding: const EdgeInsets.all(16),
          children: [
            // 历史模板
            const Text('历史模板', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            if (templates.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: [
                  Icon(Icons.description_outlined, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text('暂无历史模板', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('请上传新的合同文件', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                ]),
              )
            else
              ...templates.map((t) => _TemplateCard(
                template: t,
                isSelected: widget.selectedTemplate?.id == t.id,
                onTap: () {
                  widget.onSelected(t);
                  widget.versionCtrl.text = t.version;
                  Navigator.pop(context);
                },
              )),

            const SizedBox(height: 20),
            // 上传新模板
            const Text('上传新模板', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _uploadVersionCtrl,
                      decoration: const InputDecoration(
                        labelText: '模板版本',
                        hintText: '如 V1.0',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: Text(_uploadedFileName == null ? '选择文件' : '重新选择'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ]),
                if (_uploadedFileName != null) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.insert_drive_file, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(_uploadedFileName!, style: const TextStyle(fontSize: 12, color: AppColors.primary))),
                    const SizedBox(width: 8),
                    const Text('待上传', style: TextStyle(fontSize: 11, color: Color(0xFF10B981))),
                  ]),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _confirmUpload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isUploading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('确认使用此模板', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: Text('支持 PDF / Word / 图片格式', style: TextStyle(fontSize: 11, color: Colors.grey.shade400))),
              ]),
            ),
          ],
        ),
      ),
    ]);
  }
}

class _TemplateCard extends StatelessWidget {
  final ContractVersion template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: template.isLocked ? const Color(0xFF10B981).withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              template.isLocked ? Icons.lock : Icons.description,
              color: template.isLocked ? const Color(0xFF10B981) : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(
                    template.fileName ?? '模板 ' + template.version,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? AppColors.primary : Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: template.isLocked ? const Color(0xFF10B981).withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    template.version,
                    style: TextStyle(fontSize: 10, color: template.isLocked ? const Color(0xFF10B981) : AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Text(
                  template.fileSize > 0 ? template.fileSizeLabel : '未知大小',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(template.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
                if (template.isLocked) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.lock, size: 11, color: Color(0xFF10B981)),
                  const SizedBox(width: 2),
                  Text(
                    template.lockedBy ?? '已锁定',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF10B981)),
                  ),
                ],
              ]),
            ]),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
        ]),
      ),
    );
  }
}

"""

if date_field_comment in data:
    if "// ============================================================\n// 合同模板选择器" not in data:
        data = data.replace(date_field_comment, template_widgets + date_field_comment)
        print('Added template selector widgets')
    else:
        print('Template widgets already in file')
else:
    print('WARNING: date field comment not found')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\create_contract_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print(f'Final size: {len(data)}')
print('Saved!')
