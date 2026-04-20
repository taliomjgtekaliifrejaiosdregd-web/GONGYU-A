# -*- coding: utf-8 -*-
qr_widget = """

// ============================================================
// QR扫码组件
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
        Positioned(
          top: 0, left: 0, right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: widget.onCancel,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
                const Expanded(child: Text('')),
                const Text('扫码添加设备', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const Expanded(child: Text('')),
                GestureDetector(
                  onTap: () => _controller?.toggleTorch(),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                    child: const Icon(Icons.flash_on, color: Colors.white),
                  ),
                ),
              ]),
            ),
          ),
        ),
        // 扫描框
        Center(
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(children: [
              // 左上角
              Positioned(top: 0, left: 0, child: _Corner(color: AppColors.primary)),
              // 右上角
              Positioned(top: 0, right: 0, child: _Corner(color: AppColors.primary)),
              // 左下角
              Positioned(bottom: 0, left: 0, child: _Corner(color: AppColors.primary)),
              // 右下角
              Positioned(bottom: 0, right: 0, child: _Corner(color: AppColors.primary)),
            ]),
          ),
        ),
        // 底部提示
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const Text('将设备二维码或条码放入框内', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text('设备MAC地址或序列号请见设备背面铭牌', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => _showManualInput(context),
                  child: const Text('手动输入设备编号', style: TextStyle(color: Colors.white70)),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  void _showManualInput(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('手动输入设备编号'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '请输入设备 MAC 地址或序列号', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                Navigator.pop(context);
                widget.onScanned(ctrl.text.trim());
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}

// 扫描框角落装饰
class _Corner extends StatelessWidget {
  final Color color;
  const _Corner({required this.color});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 24, height: 24, child: CustomPaint(painter: _CornerPainter(color: color)));
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 8), Offset.zero, paint);
    canvas.drawLine(Offset.zero, Offset(8, 0), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
"""

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Truncate at _FormField end
formfield_idx = data.rfind('class _FormField')
depth = 0
i = data.find('{', formfield_idx)
formfield_end = -1
while i < len(data):
    if data[i] == '{': depth += 1
    elif data[i] == '}':
        depth -= 1
        if depth == 0:
            formfield_end = i
            break
    i += 1

# Truncate and append
new_data = data[:formfield_end+1] + qr_widget

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'w', encoding='utf-8') as f:
    f.write(new_data)
print(f'Final size: {len(new_data)}')
print('Saved!')
