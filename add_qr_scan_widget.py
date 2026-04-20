# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find the last closing brace
last_brace = data.rfind('}')
print(f'Last brace at: {last_brace}')

qr_scanner_widget = '''

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
        // 摄像头画面
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            if (_hasScanned) return;
            final barcodes = capture.barcodes;
            for (final barcode in barcodes) {
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
        SafeArea(
          child: Column(children: [
            Padding(
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
                // 手电筒
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
          ]),
        ),
        // 中央扫描框
        Center(
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(children: [
              // 四角
              Positioned(top: -1, left: -1, child: _CornerMark(alignment: Alignment.topLeft)),
              Positioned(top: -1, right: -1, child: _CornerMark(alignment: Alignment.topRight)),
              Positioned(bottom: -1, left: -1, child: _CornerMark(alignment: Alignment.bottomLeft)),
              Positioned(bottom: -1, right: -1, child: _CornerMark(alignment: Alignment.bottomRight)),
              // 扫描线动画
              Positioned.fill(
                child: _ScanLine(),
              ),
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
                const Text(
                  '将设备二维码/条码放入框内',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  '设备 MAC 地址或序列号请见设备背面铭牌',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
                const SizedBox(height: 20),
                // 手动输入按钮
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
          decoration: const InputDecoration(
            hintText: '请输入设备 MAC 地址或序列号',
            border: OutlineInputBorder(),
          ),
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

// 扫描框四角装饰
class _CornerMark extends StatelessWidget {
  final Alignment alignment;
  const _CornerMark({required this.alignment});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24, height: 24,
      child: CustomPaint(painter: _CornerPainter(color: AppColors.primary, alignment: alignment)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final Alignment alignment;
  _CornerPainter({required this.color, required this.alignment});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final r = 8.0;

    final path = Path();
    if (alignment == Alignment.topLeft) {
      path.moveTo(0, r); path.quadraticBezierTo(0, 0, r, 0);
      path.lineTo(w, 0);
      path.moveTo(0, h); path.lineTo(0, r); path.quadraticBezierTo(0, 0, r, 0);
    } else if (alignment == Alignment.topRight) {
      path.moveTo(w - r, 0); path.quadraticBezierTo(w, 0, w, r);
      path.lineTo(w, h);
      path.moveTo(0, 0); path.lineTo(w - r, 0); path.quadraticBezierTo(w, 0, w, r);
    } else if (alignment == Alignment.bottomLeft) {
      path.moveTo(0, h - r); path.quadraticBezierTo(0, h, r, h);
      path.lineTo(w, h);
      path.moveTo(0, 0); path.lineTo(0, h - r); path.quadraticBezierTo(0, h, r, h);
    } else {
      path.moveTo(w - r, h); path.quadraticBezierTo(w, h, w, h - r);
      path.lineTo(w, 0);
      path.moveTo(0, h); path.lineTo(w - r, h); path.quadraticBezierTo(w, h, w, h - r);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 扫描线动画
class _ScanLine extends StatefulWidget {
  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _animVal;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _animVal = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animVal,
      builder: (_, __) => Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Align(
          alignment: Alignment(0, -1 + 2 * _animVal.value),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.primary.withOpacity(0.8), Colors.transparent],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
'''

# Insert before the last closing brace
data = data[:last_brace] + qr_scanner_widget + '\n}'

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\add_device_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print(f'Final size: {len(data)}')
print('Saved!')
