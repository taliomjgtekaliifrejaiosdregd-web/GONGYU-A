# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# 1. Add import
if "import 'package:mobile_scanner/mobile_scanner.dart';" not in data:
    data = "import 'package:mobile_scanner/mobile_scanner.dart';\n" + data
    print('1. Added mobile_scanner import')

# 2. Add scan method to _AddDevicePageState
# Find a good place to add - after _showPriceInputDialog
old_marker = """  void _showPriceInputDialog(String label, String current, Function(String) onConfirm) {"""
new_marker = """  // =====================================================
  // 扫码添加设备
  // =====================================================
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
      setState(() {
        _deviceNoController.text = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已扫描：$result'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  void _showPriceInputDialog(String label, String current, Function(String) onConfirm) {"""

if old_marker in data:
    data = data.replace(old_marker, new_marker)
    print('2. Added _openScanner method')
else:
    print('WARNING: _showPriceInputDialog marker not found')

# 3. Update the device ID field to add scan button
# Replace _FormField for device ID with custom widget that has scan button
old_device_field = """      _FormField(
        label: '设备编号 *',
        hint: '请输入设备 MAC 地址或序列号',
        controller: _deviceNoController,
        icon: Icons.qr_code,
        validator: (v) => v == null || v.isEmpty ? '请输入设备编号' : null,
      ),"""

new_device_field = """      // 设备编号 - 带扫码入口
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('设备编号 *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF666666))),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _deviceNoController,
              validator: (v) => v == null || v.isEmpty ? '请输入设备编号' : null,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: '请输入设备 MAC 地址或序列号',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.qr_code, size: 20, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 扫码按钮
          GestureDetector(
            onTap: _openScanner,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 22),
                  SizedBox(height: 2),
                  Text('扫码', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ]),
      ]),"""

if old_device_field in data:
    data = data.replace(old_device_field, new_device_field)
    print('3. Updated device ID field with scan button')
else:
    print('WARNING: device field not found')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print(f'File size: {len(data)}')
print('Saved!')
