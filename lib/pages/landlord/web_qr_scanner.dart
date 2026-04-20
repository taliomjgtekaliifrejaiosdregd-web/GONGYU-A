import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import '../../utils/html5_qrcode.dart';
import '../../utils/app_theme.dart';

/// Web-specific QR Scanner using html5-qrcode JS library
/// Falls back to manual input if camera not available
class WebQrScanner extends StatefulWidget {
  final void Function(String code) onScanned;
  final VoidCallback onCancel;
  const WebQrScanner({super.key, required this.onScanned, required this.onCancel});
  @override
  State<WebQrScanner> createState() => _WebQrScannerState();
}

class _WebQrScannerState extends State<WebQrScanner> {
  Html5Qrcode? _scanner;
  bool _hasScanned = false;
  bool _isLoading = true;
  String? _errorMessage;
  static int _viewIdCounter = 0;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  Future<void> _initScanner() async {
    try {
      // Create a div element for the scanner
      final viewId = 'qr-scanner-${_viewIdCounter++}';
      final div = html.DivElement()
        ..id = viewId
        ..style.width = '100%'
        ..style.height = '100%';

      // Register the element
      ui_web.platformViewRegistry.registerViewFactory(
        viewId,
        (int _) => div,
      );

      // Wait for the view to be rendered
      await Future.delayed(const Duration(milliseconds: 300));

      // Create scanner
      _scanner = Html5Qrcode(viewId);

      // Start scanning
      final config = {'fps': 10, 'qrbox': {'width': 250, 'height': 250}}.jsify()!;

      await _scanner!.start(
        '', // empty string = use back camera
        config,
        ((String decodedText, JSAny _) {
          if (!_hasScanned) {
            _hasScanned = true;
            widget.onScanned(decodedText);
          }
        }).toJS,
        ((String _, JSAny __) {
          // Ignore scan errors (no QR found in frame)
        }).toJS,
      ).toDart;

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '相机启动失败: $e';
      });
    }
  }

  @override
  void dispose() {
    _scanner?.stop().toDart.catchError((_) => null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(children: [
        // Scanner view
        if (_errorMessage == null)
          const Positioned.fill(
            child: HtmlElementView(viewType: 'qr-scanner-0'),
          ),

        // Loading overlay
        if (_isLoading)
          const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('正在启动相机...', style: TextStyle(color: Colors.white, fontSize: 14)),
            ]),
          ),

        // Error overlay
        if (_errorMessage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.videocam_off, color: Colors.white54, size: 48),
                const SizedBox(height: 16),
                Text(_errorMessage!, style: const TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showManualInput(context),
                  icon: const Icon(Icons.keyboard),
                  label: const Text('手动输入设备编号'),
                ),
              ]),
            ),
          ),

        // Top bar
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
                    decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
                const Expanded(child: Text('')),
                const Text('扫码添加设备', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const Expanded(child: Text('')),
                const SizedBox(width: 40), // balance
              ]),
            ),
          ),
        ),

        // Bottom hint
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
