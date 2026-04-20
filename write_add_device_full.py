# -*- coding: utf-8 -*-
# Write complete add_device_page.dart with QR scanning

dart_code = r'''import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/models/device.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// ============================================================
// 房东端 - 添加设备页（支持电表/水表/门锁三步填写）
// ============================================================
class AddDevicePage extends StatefulWidget {
  final DeviceType? initialType;
  const AddDevicePage({super.key, this.initialType});
  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  DeviceType? _selectedType;
  String? _selectedRoomId;
  String? _selectedRoomTitle;
  final _deviceNoController = TextEditingController();
  final _deviceNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _electricPrice = '0.50';
  String _waterPrice = '3.50';
  int _batteryLevel = 100;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _deviceNoController.dispose();
    _deviceNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Color get _typeColor {
    switch (_selectedType) {
      case DeviceType.electricMeter: return const Color(0xFFF59E0B);
      case DeviceType.waterMeter: return const Color(0xFF06B6D4);
      case DeviceType.smartLock: return const Color(0xFF6366F1);
      default: return AppColors.primary;
    }
  }

  IconData get _typeIcon {
    switch (_selectedType) {
      case DeviceType.electricMeter: return Icons.electric_bolt;
      case DeviceType.waterMeter: return Icons.water_drop;
      case DeviceType.smartLock: return Icons.lock;
      default: return Icons.devices_other;
    }
  }

  String get _typeLabel {
    switch (_selectedType) {
      case DeviceType.electricMeter: return '电表';
      case DeviceType.waterMeter: return '水表';
      case DeviceType.smartLock: return '门锁';
      default: return '';
    }
  }

  List<Map<String, String>> get _roomOptions {
    return MockService.rooms.map((r) => {'id': r.id.toString(), 'title': r.title}).toList();
  }

  // 扫码添加设备
  Future<void> _openScanner() async {
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _QRScannerSheet(
        onScanned: (code) => Navigator.pop(context, code),
        onCancel: () => Navigator.pop(context),
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _deviceNoController.text = result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已扫描：$result'), behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFF10B981)),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoomId == null) {
      _showError('请先选择关联房源');
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    final newDevice = Device(
      id: DateTime.now().millisecondsSinceEpoch,
      deviceNo: _deviceNoController.text.trim(),
      type: _selectedType!,
      roomId: int.tryParse(_selectedRoomId!) ?? 0,
      roomTitle: _selectedRoomTitle ?? '',
      brand: '涂鸦智能',
      status: DeviceStatus.online,
      balance: _selectedType == DeviceType.smartLock ? _batteryLevel.toDouble() : 100.0,
      monthUsage: 0, monthCost: 0, currentReading: 0, todayUsage: 0,
      lastReadAt: DateTime.now(),
      pricePerUnit: _selectedType == DeviceType.electricMeter
          ? (double.tryParse(_electricPrice) ?? 0.5)
          : _selectedType == DeviceType.waterMeter ? (double.tryParse(_waterPrice) ?? 3.5) : 0,
    );
    setState(() => _isSubmitting = false);
    if (!mounted) return;
    _showSuccess(newDevice);
  }

  void _showSuccess(Device device) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 36)),
          const SizedBox(height: 16),
          const Text('添加成功', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('已成功添加 ${device.roomTitle} $_typeLabel', style: TextStyle(fontSize: 13, color: Colors.grey.shade600), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: _typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(device.deviceNo, style: TextStyle(fontSize: 12, color: _typeColor, fontFamily: 'monospace'))),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), side: BorderSide(color: _typeColor)),
              child: Text('返回列表', style: TextStyle(color: _typeColor)))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () { Navigator.pop(context); setState(() { _deviceNoController.clear(); _deviceNameController.clear(); _locationController.clear(); }); },
              style: ElevatedButton.styleFrom(backgroundColor: _typeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('继续添加', style: TextStyle(color: Colors.white)))),
          ]),
        ]),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.danger));
  }

  void _showPriceInputDialog(String label, String current, Function(String) onConfirm) {
    final ctrl = TextEditingController(text: current);
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('设置$label'),
      content: TextField(controller: ctrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), suffixText: _selectedType == DeviceType.electricMeter ? '元/度' : '元/吨')),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        ElevatedButton(onPressed: () { if (ctrl.text.isNotEmpty) onConfirm(ctrl.text); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: _typeColor), child: const Text('确认', style: TextStyle(color: Colors.white)))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Text('添加\$_typeLabel', style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [if (_selectedType != null) TextButton(onPressed: () => setState(() => _selectedType = null), child: const Text('重选', style: TextStyle(color: AppColors.primary, fontSize: 13)))],
      ),
      body: _selectedType == null ? _buildTypeSelector() : _buildForm(),
    );
  }

  Widget _buildTypeSelector() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('请选择设备类型', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text('添加前请确保设备已正确安装并通电/联网', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      const SizedBox(height: 20),
      _TypeCard(icon: Icons.electric_bolt, title: '智能电表', subtitle: 'DDSU666 / 正泰8627 等', desc: '监测用电量、支持远程充值拉闸', color: const Color(0xFFF59E0B), onTap: () => setState(() => _selectedType = DeviceType.electricMeter)),
      const SizedBox(height: 12),
      _TypeCard(icon: Icons.water_drop, title: '智能水表', subtitle: '光电直读 / 超声波 等', desc: '监测用水量、支持欠费关阀', color: const Color(0xFF06B6D4), onTap: () => setState(() => _selectedType = DeviceType.waterMeter)),
      const SizedBox(height: 12),
      _TypeCard(icon: Icons.lock, title: '智能门锁', subtitle: '德施曼 / 凯迪仕 / 鹿客 等', desc: '远程开锁、密码管理、开锁记录', color: const Color(0xFF6366F1), onTap: () => setState(() => _selectedType = DeviceType.smartLock)),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2))),
        child: Row(children: [const Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 20), const SizedBox(width: 10), Expanded(child: Text('首次添加建议逐台添加，方便调试。如设备较多，可批量导入。', style: TextStyle(fontSize: 12, color: Colors.orange.shade800)))])),
    ]));
  }

  Widget _buildForm() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _typeColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: _typeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(_typeIcon, color: _typeColor, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('添加\$_typeLabel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _typeColor)),
            const SizedBox(height: 2),
            Text('设备 MAC / 设备编号请见设备背面铭牌', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ])),
        ])),
      const SizedBox(height: 24),
      const Text('关联房源', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      _RoomSelector(rooms: _roomOptions, selectedId: _selectedRoomId, onChanged: (id, title) => setState(() { _selectedRoomId = id; _selectedRoomTitle = title; })),
      const SizedBox(height: 24),
      const Text('设备信息', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      _buildBaseFields(),
      const SizedBox(height: 24),
      _buildTypeSpecificFields(),
      const SizedBox(height: 32),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(backgroundColor: _typeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
        child: _isSubmitting ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.add_circle_outline, color: Colors.white, size: 20), const SizedBox(width: 8),
          Text('确认添加 \${_typeLabel}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        ]))),
      const SizedBox(height: 12),
      Center(child: Text('添加后可在设备管理中查看和调试', style: TextStyle(fontSize: 11, color: Colors.grey.shade400))),
      const SizedBox(height: 20),
    ])));
  }

  Widget _buildBaseFields() {
    return Column(children: [
      // 设备编号 - 带扫码入口
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('设备编号 *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF666666))),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: TextFormField(
            controller: _deviceNoController,
            validator: (v) => v == null || v.isEmpty ? '请输入设备编号' : null,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: '请输入设备 MAC 地址或序列号',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.qr_code, size: 20, color: Colors.grey.shade400),
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444))),
            ),
          )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _openScanner,
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 22),
                SizedBox(height: 2),
                Text('扫码', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
      ]),
      const SizedBox(height: 12),
      _FormField(label: '设备名称', hint: '如：主卧电表、北门锁', controller: _deviceNameController, icon: Icons.label_outline),
      const SizedBox(height: 12),
      _FormField(label: '安装位置', hint: '如：配电箱 A2-1、玄关门锁', controller: _locationController, icon: Icons.location_on_outlined),
    ]);
  }

  Widget _buildTypeSpecificFields() {
    switch (_selectedType) {
      case DeviceType.electricMeter: return _buildElectricMeterFields();
      case DeviceType.waterMeter: return _buildWaterMeterFields();
      case DeviceType.smartLock: return _buildSmartLockFields();
      default: return const SizedBox();
    }
  }

  Widget _buildElectricMeterFields() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('电价设置', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: ['0.50', '0.55', '0.60', '0.68', '自定义'].map((p) {
        final selected = _electricPrice == p;
        if (p == '自定义') return GestureDetector(
          onTap: () => _showPriceInputDialog('电价', _electricPrice, (v) => setState(() => _electricPrice = v)),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: selected ? _typeColor.withOpacity(0.15) : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? _typeColor : const Color(0xFFE0E0E0))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('自定义', style: TextStyle(fontSize: 13, color: selected ? _typeColor : Colors.grey.shade600)),
              const SizedBox(width: 4),
              Icon(Icons.edit, size: 14, color: selected ? _typeColor : Colors.grey.shade400),
            ])));
        return GestureDetector(
          onTap: () => setState(() => _electricPrice = p),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: selected ? _typeColor.withOpacity(0.15) : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? _typeColor : const Color(0xFFE0E0E0))),
            child: Text('\u00a5\$p/度', style: TextStyle(fontSize: 13, color: selected ? _typeColor : Colors.grey.shade600, fontWeight: selected ? FontWeight.w600 : FontWeight.normal))));
      }).toList()),
      const SizedBox(height: 10),
      Text('当前设置：\u00a5\$_electricPrice/度', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
    ]);
  }

  Widget _buildWaterMeterFields() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('水价设置', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: ['3.00', '3.50', '4.00', '4.50', '自定义'].map((p) {
        final selected = _waterPrice == p;
        if (p == '自定义') return GestureDetector(
          onTap: () => _showPriceInputDialog('水价', _waterPrice, (v) => setState(() => _waterPrice = v)),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: selected ? _typeColor.withOpacity(0.15) : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? _typeColor : const Color(0xFFE0E0E0))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Text('自定义', style: TextStyle(fontSize: 13, color: selected ? _typeColor : Colors.grey.shade600)), const SizedBox(width: 4), Icon(Icons.edit, size: 14, color: selected ? _typeColor : Colors.grey.shade400)])));
        return GestureDetector(
          onTap: () => setState(() => _waterPrice = p),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: selected ? _typeColor.withOpacity(0.15) : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? _typeColor : const Color(0xFFE0E0E0))),
            child: Text('\u00a5\$p/吨', style: TextStyle(fontSize: 13, color: selected ? _typeColor : Colors.grey.shade600, fontWeight: selected ? FontWeight.w600 : FontWeight.normal))));
      }).toList()),
      const SizedBox(height: 10),
      Text('当前设置：\u00a5\$_waterPrice/吨', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
    ]);
  }

  Widget _buildSmartLockFields() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('电池电量', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE0E0E0))),
        child: Column(children: [
          Row(children: [
            Icon(_batteryLevel > 50 ? Icons.battery_std : _batteryLevel > 20 ? Icons.battery_4_bar : Icons.battery_alert, color: _batteryLevel > 50 ? const Color(0xFF10B981) : _batteryLevel > 20 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444), size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text('当前电量：\$_batteryLevel%', style: const TextStyle(fontSize: 14))),
            Text(_batteryLevel > 50 ? '电量充足' : _batteryLevel > 20 ? '建议更换' : '立即更换', style: TextStyle(fontSize: 12, color: _batteryLevel > 50 ? const Color(0xFF10B981) : _batteryLevel > 20 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444))),
          ]),
          const SizedBox(height: 10),
          SliderTheme(data: SliderThemeData(activeTrackColor: _batteryLevel > 50 ? const Color(0xFF10B981) : _batteryLevel > 20 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444), thumbColor: _batteryLevel > 50 ? const Color(0xFF10B981) : _batteryLevel > 20 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
            child: Slider(value: _batteryLevel.toDouble(), min: 0, max: 100, divisions: 20, onChanged: (v) => setState(() => _batteryLevel = v.round()))),
        ])),
      const SizedBox(height: 10),
      Text('电池电量由系统自动更新，初始值可手动调整', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
    ]);
  }
}

// ============================================================
// 设备类型选择卡片
// ============================================================
class _TypeCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final String desc; final Color color; final VoidCallback onTap;
  const _TypeCard({required this.icon, required this.title, required this.subtitle, required this.desc, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(subtitle, style: TextStyle(fontSize: 10, color: color)))]),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ])),
        Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.add, color: color, size: 18)),
      ])));
  }
}

// ============================================================
// 房源选择器
// ============================================================
class _RoomSelector extends StatelessWidget {
  final List<Map<String, String>> rooms; final String? selectedId; final Function(String id, String title) onChanged;
  const _RoomSelector({required this.rooms, required this.selectedId, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE0E0E0))),
        child: Column(children: [Icon(Icons.home_work_outlined, color: Colors.grey.shade400, size: 40), const SizedBox(height: 8), Text('暂无可用房源', style: TextStyle(color: Colors.grey.shade500)), const SizedBox(height: 4), Text('请先在「房源管理」中添加房源', style: TextStyle(fontSize: 12, color: Colors.grey.shade400))]));
    }
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE0E0E0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.home_work_outlined, size: 18, color: AppColors.primary), const SizedBox(width: 6), Text('选择安装位置（\${rooms.length}个房源）', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: rooms.map((room) {
          final isSelected = selectedId == room['id'];
          return GestureDetector(onTap: () => onChanged(room['id']!, room['title']!),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: isSelected ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [if (isSelected) ...[const Icon(Icons.check, size: 14, color: AppColors.primary), const SizedBox(width: 4)], Text(room['title']!, style: TextStyle(fontSize: 12, color: isSelected ? AppColors.primary : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))])));
        }).toList()),
        if (selectedId != null) ...[const SizedBox(height: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)), const SizedBox(width: 6), Text('已选择：\${rooms.firstWhere((r) => r['id'] == selectedId)['title']}', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981)))]))],
      ]));
  }
}

// ============================================================
// 表单输入组件
// ============================================================
class _FormField extends StatelessWidget {
  final String label; final String hint; final TextEditingController controller; final IconData icon; final String? Function(String?)? validator; final TextInputType? keyboardType; final int maxLines;
  const _FormField({required this.label, required this.hint, required this.controller, required this.icon, this.validator, this.keyboardType, this.maxLines = 1});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF666666))),
      const SizedBox(height: 6),
      TextFormField(controller: controller, validator: validator, keyboardType: keyboardType, maxLines: maxLines, style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400), prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
          filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444))))),
    ]);
  }
}

// ============================================================
// QR码扫码组件
// ============================================================
class _QRScannerSheet extends StatefulWidget {
  final void Function(String code) onScanned;
  final VoidCallback onCancel;
  const _QRScannerSheet({required this.onScanned, required this.onCancel});
  @override
  State<_QRScannerSheet> createState() => _QRScannerSheetState();
}

class _QRScannerSheetState extends State<_QRScannerSheet> {
  MobileScannerController? _controller;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            if (_hasScanned) return;
            for (final barcode in capture.barcodes) {
              final code = barcode.rawValue;
              if (code != null && code.isNotEmpty) {
                _hasScanned = true;
                widget.onScanned(code);
                break;
              }
            }
          },
        ),
        // 顶部操作栏
        Positioned(top: 0, left: 0, right: 0, child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Row(children: [
          GestureDetector(onTap: widget.onCancel, child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white))),
          const Spacer(),
          const Text('扫码添加设备', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          GestureDetector(onTap: () => _controller?.toggleTorch(), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle), child: const Icon(Icons.flash_on, color: Colors.white))),
        ])))),
        // 中央扫描框
        Center(child: Container(width: 260, height: 260, decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.6), width: 2), borderRadius: BorderRadius.circular(16)))),
        // 底部提示
        Positioned(bottom: 0, left: 0, right: 0, child: SafeArea(child: Container(padding: const EdgeInsets.all(24), child: Column(children: [
          const Text('将设备二维码/条码放入框内', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: Font