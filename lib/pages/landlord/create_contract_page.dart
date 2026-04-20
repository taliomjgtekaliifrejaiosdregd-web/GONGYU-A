import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gongyu_guanjia/models/room.dart';
import 'package:gongyu_guanjia/models/contract.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

// ============================================================
// 房东端 - 新建合同页面（完整表单）
// ============================================================
class CreateContractPage extends StatefulWidget {
  final Room? preselectedRoom;

  const CreateContractPage({super.key, this.preselectedRoom});

  @override
  State<CreateContractPage> createState() => _CreateContractPageState();
}

class _CreateContractPageState extends State<CreateContractPage> {
  final _formKey = GlobalKey<FormState>();

  // 当前选中的房源
  Room? _selectedRoom;

  // 表单字段
  final _tenantNameCtrl = TextEditingController();
  final _tenantPhoneCtrl = TextEditingController();
  final _contractNoCtrl = TextEditingController();
  final _contractVersionCtrl = TextEditingController(text: 'V1.0');
  final _rentAmountCtrl = TextEditingController();
  final _depositAmountCtrl = TextEditingController();
  final _specialTermsCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();
  ContractVersion? _selectedTemplate;  // 选中的合同模板
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  String _paymentCycle = '押一付一';
  bool _isSubmitting = false;

  final List<String> _paymentCycles = ['押一付一', '押二付一', '押一付三', '半年付', '年付'];

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.preselectedRoom;
    if (_selectedRoom != null) {
      _rentAmountCtrl.text = _selectedRoom!.price.toStringAsFixed(0);
      _depositAmountCtrl.text = (_selectedRoom!.price * 2).toStringAsFixed(0);
    }
    // 生成合同编号
    final now = DateTime.now();
    _contractNoCtrl.text = 'HT${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecond % 10000}';
  }

  @override
  void dispose() {
    _tenantNameCtrl.dispose();
    _tenantPhoneCtrl.dispose();
    _contractNoCtrl.dispose();
    _contractVersionCtrl.dispose();
    _rentAmountCtrl.dispose();
    _depositAmountCtrl.dispose();
    _specialTermsCtrl.dispose();
    super.dispose();
  }

  int get _contractDays => _endDate.difference(_startDate).inDays;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('新建合同', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ===== 一、关联房源 =====
            const _SectionTitle('关联房源'),
            const SizedBox(height: 8),
            _RoomPicker(
              selectedRoom: _selectedRoom,
              onTap: () => _showRoomPicker(context),
            ),

            const SizedBox(height: 24),

            // ===== 二、租客信息 =====
            const _SectionTitle('租客信息'),
            const SizedBox(height: 8),
            _FormTextField(
              label: '租客姓名 *',
              hint: '请输入租客真实姓名',
              controller: _tenantNameCtrl,
              icon: Icons.person_outline,
              validator: (v) => v == null || v.isEmpty ? '请输入租客姓名' : null,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              label: '联系电话 *',
              hint: '请输入租客手机号',
              controller: _tenantPhoneCtrl,
              icon: Icons.phone_android,
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.isEmpty ? '请输入联系电话' : null,
            ),

            const SizedBox(height: 24),

            // ===== 三、合同信息 =====
            const _SectionTitle('合同信息'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: _FormTextField(
                  label: '合同编号',
                  hint: '系统自动生成',
                  controller: _contractNoCtrl,
                  icon: Icons.tag,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormTextField(
                  label: '合同版本',
                  hint: '如 V1.0',
                  controller: _contractVersionCtrl,
                  icon: Icons.history,
                ),
              ),
            ]),
            const SizedBox(height: 10),

            // 合同模板选择
            _TemplateSelector(
              selectedTemplate: _selectedTemplate,
              versionCtrl: _contractVersionCtrl,
              onChanged: (t) => setState(() => _selectedTemplate = t),
            ),

            const SizedBox(height: 12),

            // 日期选择
            Row(children: [
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
            if (_contractDays > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '租期：$_contractDays 天（约 ${(_contractDays / 30).toStringAsFixed(1)} 个月）',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),

            const SizedBox(height: 24),

            // ===== 四、费用信息 =====
            const _SectionTitle('费用信息'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: _FormTextField(
                  label: '月租金 (元) *',
                  hint: '请输入月租金',
                  controller: _rentAmountCtrl,
                  icon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixText: '¥ ',
                  validator: (v) {
                    if (v == null || v.isEmpty) return '请输入租金';
                    if (double.tryParse(v) == null) return '请输入有效金额';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormTextField(
                  label: '押金 (元) *',
                  hint: '押金金额',
                  controller: _depositAmountCtrl,
                  icon: Icons.account_balance_wallet,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixText: '¥ ',
                  validator: (v) {
                    if (v == null || v.isEmpty) return '请输入押金';
                    if (double.tryParse(v) == null) return '请输入有效金额';
                    return null;
                  },
                ),
              ),
            ]),
            const SizedBox(height: 12),

            // 付款周期
            _Label('付款周期'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _paymentCycles.map((p) => _ChipTag(
                label: p,
                isSelected: _paymentCycle == p,
                onTap: () => setState(() => _paymentCycle = p),
              )).toList(),
            ),

            // 费用汇总
            if (_rentAmountCtrl.text.isNotEmpty && double.tryParse(_rentAmountCtrl.text) != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                ),
                child: Column(children: [
                  _SummaryRow('月租金', '¥${_rentAmountCtrl.text}'),
                  const SizedBox(height: 6),
                  _SummaryRow('押金', '¥${_depositAmountCtrl.text.isNotEmpty ? _depositAmountCtrl.text : "—"}'),
                  if (_paymentCycle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _SummaryRow('付款方式', _paymentCycle),
                  ],
                  if (_contractDays > 30) ...[
                    const SizedBox(height: 6),
                    _SummaryRow('首期应付', _calculateFirstPayment(), AppColors.danger),
                  ],
                ]),
              ),
            ],

            const SizedBox(height: 24),

            // ===== 五、特殊条款 =====
            const _SectionTitle('特殊条款'),
            const SizedBox(height: 8),
            _FormTextField(
              label: '补充约定',
              hint: '可填写特殊约定、违约条款等（选填）',
              controller: _specialTermsCtrl,
              icon: Icons.notes,
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // ===== 提交按钮 =====
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text('确认创建合同', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '创建后将自动生成电子合同，等待租客在线签署',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _calculateFirstPayment() {
    final rent = double.tryParse(_rentAmountCtrl.text) ?? 0;
    final deposit = double.tryParse(_depositAmountCtrl.text) ?? 0;
    if (_paymentCycle == '押一付一') return '¥${(rent + deposit).toStringAsFixed(0)}';
    if (_paymentCycle == '押二付一') return '¥${(rent * 2 + deposit).toStringAsFixed(0)}';
    if (_paymentCycle == '押一付三') return '¥${(rent * 3 + deposit).toStringAsFixed(0)}';
    if (_paymentCycle == '半年付') return '¥${(rent * 6 + deposit).toStringAsFixed(0)}';
    if (_paymentCycle == '年付') return '¥${(rent * 12 + deposit).toStringAsFixed(0)}';
    return '¥${(rent + deposit).toStringAsFixed(0)}';
  }

  void _showRoomPicker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _RoomPickerPage(
          preselectedRoom: _selectedRoom,
          onSelected: (room) {
            setState(() => _selectedRoom = room);
            _rentAmountCtrl.text = room.price.toStringAsFixed(0);
            _depositAmountCtrl.text = (room.price * 2).toStringAsFixed(0);
          },
        ),
      ),
    );
  }void _showDatePicker(BuildContext context, bool isStart) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SizedBox(
        height: 280,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: Row(children: [
              Text(isStart ? '选择起租日期' : '选择到期日期', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确认', style: TextStyle(color: AppColors.primary)),
              ),
            ]),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: isStart ? _startDate : _endDate,
              minimumDate: isStart ? DateTime.now().subtract(const Duration(days: 30)) : _startDate,
              maximumDate: isStart ? DateTime.now().add(const Duration(days: 365 * 2)) : DateTime.now().add(const Duration(days: 365 * 5)),
              onDateTimeChanged: (dt) {
                setState(() {
                  if (isStart) {
                    _startDate = dt;
                    if (_endDate.isBefore(_startDate)) {
                      _endDate = _startDate.add(const Duration(days: 365));
                    }
                  } else {
                    _endDate = dt;
                  }
                });
              },
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择关联房源'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));

    final rent = double.tryParse(_rentAmountCtrl.text) ?? 0;
    final deposit = double.tryParse(_depositAmountCtrl.text) ?? 0;
    final daysToExpire = _endDate.difference(DateTime.now()).inDays;

    final newContract = Contract(
      id: DateTime.now().millisecondsSinceEpoch,
      contractNo: _contractNoCtrl.text.trim().isEmpty
          ? 'HT${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().millisecond % 10000}'
          : _contractNoCtrl.text.trim(),
      roomId: _selectedRoom!.id,
      roomTitle: _selectedRoom!.title,
      tenantName: _tenantNameCtrl.text.trim(),
      tenantPhone: _tenantPhoneCtrl.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      rentAmount: rent,
      depositAmount: deposit,
      status: ContractStatus.pendingSign,
      daysToExpire: daysToExpire,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    // 成功弹窗
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 32),
          ),
          const SizedBox(height: 16),
          const Text('合同创建成功', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '合同已发送给租客「${_tenantNameCtrl.text.trim()}」\n等待对方在线签署确认',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
            child: Column(children: [
              Text(_selectedRoom!.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('版本：${_contractVersionCtrl.text.trim()}', style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 12),
                Text('租期：$_contractDays天', style: const TextStyle(fontSize: 11)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 关闭弹窗
                Navigator.pop(context); // 返回合同列表
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('新合同已添加至合同列表'), behavior: SnackBarBehavior.floating),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23))),
              child: const Text('查看合同列表', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ============================================================
// 区块标题
// ============================================================
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF666666)),
  );
}

// ============================================================
// 房源选择器
// ============================================================
class _RoomPicker extends StatelessWidget {
  final Room? selectedRoom;
  final VoidCallback onTap;
  const _RoomPicker({required this.selectedRoom, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (selectedRoom == null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0), style: BorderStyle.solid),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.add_home_work, color: Colors.grey.shade400, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('点击选择房源', style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                const SizedBox(height: 2),
                Text('从现有房源中选择本次出租的房屋', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
          ]),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.home, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(selectedRoom!.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 3),
              Text('${selectedRoom!.layout} · ${selectedRoom!.area.toStringAsFixed(0)}㎡ · ¥${selectedRoom!.price}/月',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(selectedRoom!.address, style: TextStyle(fontSize: 10, color: Colors.grey.shade400), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Text('已选择', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: AppColors.primary),
        ]),
      ),
    );
  }
}

// ============================================================
// 合同模板选择器（ StatefulWidget，直接调用 showModalBottomSheet）
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
          onSelected: (t) {
            widget.onChanged(t);
          },
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
                      color: t.isLocked
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFF6366F1).withOpacity(0.1),
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
                      t.fileSize != null && t.fileSize! > 0 ? '版本 ${t.version} · ${t.fileSizeLabel}' : '版本 ${t.version}',
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
            t.isLocked ? '已锁定（${t.lockedBy ?? ""}），不可修改内容' : '可编辑合同内容',
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
    // Create a new ContractVersion from uploaded file
    final newTemplate = ContractVersion(
      id: 'upload-${DateTime.now().millisecondsSinceEpoch}',
      version: _uploadVersionCtrl.text.isEmpty ? 'V1.0' : _uploadVersionCtrl.text,
      fileName: _uploadedFileName,
      fileUrl: '/uploads/${_uploadedFileName}',
      fileSize: 0,
      createdAt: DateTime.now(),
      isLocked: false,
    );
    widget.onSelected(newTemplate);
  }

  @override
  Widget build(BuildContext context) {
    // Get all unique templates from _mockVersions
    final templates = MockService.getContractVersions();

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

  String _fmtDate(DateTime d) {
    return '\${d.year}-\${d.month.toString().padLeft(2, "0")}-\${d.day.toString().padLeft(2, "0")}';
  }

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
              color: template.isLocked
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
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
                    template.fileName ?? '模板 ${template.version}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? AppColors.primary : Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: template.isLocked
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
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
                  template.fileSize != null && template.fileSize! > 0 ? template.fileSizeLabel : '未知大小',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 8),
                Text(
                  _fmtDate(template.createdAt),
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

// ============================================================
// 日期选择字段
// ============================================================
class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF666666))),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today, size: 18, color: Color(0xFF9E9E9E)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value, style: const TextStyle(fontSize: 14)),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
          ]),
        ),
      ),
    ],
    );
  }
}

// ============================================================
// 文本表单字段
// ============================================================
class _FormTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? prefixText;
  final int maxLines;
  final String? Function(String?)? validator;

  const _FormTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.prefixText,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF666666))),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14),
        onChanged: (_) {}, // 触发 rebuild 以更新费用汇总
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
          prefixText: prefixText,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444))),
        ),
      ),
    ],
    );
  }
}

// ============================================================
// Chip 标签
// ============================================================
class _ChipTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ChipTag({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppColors.primary : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 费用汇总行
// ============================================================
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow(this.label, this.value, [this.valueColor]);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      const Spacer(),
      Text(
        value,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor ?? Colors.black87),
      ),
    ],
    );
  }
}


// ============================================================
// 房源选择页（带搜索 + 完整列表）
// ============================================================
class _RoomPickerPage extends StatefulWidget {
  final Room? preselectedRoom;
  final Function(Room) onSelected;

  const _RoomPickerPage({this.preselectedRoom, required this.onSelected});

  @override
  State<_RoomPickerPage> createState() => _RoomPickerPageState();
}

class _RoomPickerPageState extends State<_RoomPickerPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  List<Room> get _filtered {
    if (_query.isEmpty) return MockService.rooms.toList();
    final q = _query.toLowerCase();
    return MockService.rooms.where((r) =>
        r.title.toLowerCase().contains(q) ||
        r.layout.toLowerCase().contains(q) ||
        r.address.toLowerCase().contains(q) ||
        r.price.toString().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('选择房源', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
            color: Colors.white,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: '搜索房源名称、户型、地址...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18, color: Colors.grey.shade400),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: _filtered.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.search_off, size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  _query.isEmpty ? '暂无可用房源' : '未找到匹配房源',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
                SizedBox(height: 6),
                Text(
                  _query.isEmpty ? '请先在「房源管理」中添加' : '换个关键词试试',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ]),
            )
          : Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.white,
                child: Row(children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      _filtered.length == 1
                          ? '1 个房源'
                          : ' 个房源',
                      style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (_query.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '「' + _query + '」搜索结果',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final r = _filtered[i];
                    final isSelected = widget.preselectedRoom?.id == r.id;
                    return GestureDetector(
                      onTap: () {
                        widget.onSelected(r);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text('已选择「' + r.title + '」，请继续填写合同信息')),
                            ]),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Color(0xFF10B981),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected ? Border.all(color: AppColors.primary, width: 1.5) : null,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Row(children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.home,
                              color: isSelected ? AppColors.primary : Colors.grey.shade400,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Text(r.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : Colors.black87)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: r.status == RoomStatus.available ? Color(0xFF10B981).withOpacity(0.1) : Color(0xFFEF4444).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    r.status == RoomStatus.available ? '可出租' : '已出租',
                                    style: TextStyle(fontSize: 10, color: r.status == RoomStatus.available ? Color(0xFF10B981) : Color(0xFFEF4444), fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ]),
                              SizedBox(height: 5),
                              Text(
                                r.layout + ' · ' + r.area.toStringAsFixed(0) + '㎡ · ' + r.floorText + '层',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                              SizedBox(height: 3),
                              Text(
                                r.address,
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ]),
                          ),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text(
                              '¥' + r.price.toStringAsFixed(0),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            Text('/月', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                            if (isSelected) ...[
                              SizedBox(height: 4),
                              Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                            ],
                          ]),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ]),
    );
  }
}