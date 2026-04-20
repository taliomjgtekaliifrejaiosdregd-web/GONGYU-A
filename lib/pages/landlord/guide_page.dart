// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================
// 房东端 - 新手指引页面
// ============================================================
class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSaving = false;

  // 微信公众号文章链接（请替换为实际的公众号文章URL）
  static const String _wechatArticleUrl =
      'https://mp.weixin.qq.com/s/example';

  void _openWechatArticle() async {
    final uri = Uri.parse(_wechatArticleUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('无法打开链接，请检查链接是否正确'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveAsImage() async {
    setState(() => _isSaving = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        _showError('截图失败，请重试');
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showError('截图失败，请重试');
        return;
      }

      final bytes = byteData.buffer.asUint8List();

      // Web: download via anchor element
      _downloadForWeb(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('图片已保存（${(bytes.length / 1024).toStringAsFixed(1)} KB）'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError('截图失败：$e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _downloadForWeb(Uint8List bytes) {
    final base64Data = html.window.btoa(String.fromCharCodes(bytes));
    final anchor = html.AnchorElement(
      href: 'data:image/png;base64,$base64Data',
    )
      ..setAttribute('download', 'guide.png')
      ..setAttribute('target', '_blank');
    html.document.body!.children.add(anchor);
    anchor.click();
    anchor.remove();
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('新手指引',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 20),
            tooltip: '打开公众号文章',
            onPressed: _openWechatArticle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== 可截图区域 =====
            RepaintBoundary(
              key: _repaintKey,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // 头部
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child:
                                const Icon(Icons.home_work, color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 12),
                          const Text('智慧公寓管家',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('欢迎使用！以下是快速入门指南',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('新手指南 v1.0',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),

                    // 步骤列表
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _GuideStep(
                            number: '01',
                            title: '房源管理',
                            desc: '添加和管理您的出租房源，录入房间信息、租金价格、配套设施等。',
                            icon: Icons.home_work,
                            color: const Color(0xFF6366F1),
                          ),
                          _GuideStep(
                            number: '02',
                            title: '合同签署',
                            desc: '使用腾讯电子签在线签署租赁合同，支持合同版本管理和上传。',
                            icon: Icons.description,
                            color: const Color(0xFF06B6D4),
                          ),
                          _GuideStep(
                            number: '03',
                            title: '账单与收款',
                            desc: '自动生成租金账单，租客在线缴费，收款码一键分享。',
                            icon: Icons.payments,
                            color: const Color(0xFF10B981),
                          ),
                          _GuideStep(
                            number: '04',
                            title: '设备管理',
                            desc: '绑定智能电表、水表、门锁，实时查看设备状态和用量数据。',
                            icon: Icons.sensors,
                            color: const Color(0xFFF59E0B),
                          ),
                          _GuideStep(
                            number: '05',
                            title: '报修处理',
                            desc: '接收租客提交的维修申请，在线派单、跟踪处理进度。',
                            icon: Icons.build,
                            color: const Color(0xFFEF4444),
                          ),
                          _GuideStep(
                            number: '06',
                            title: '数据分析',
                            desc: '查看收支统计、入住率、租客分析等经营数据看板。',
                            icon: Icons.bar_chart,
                            color: const Color(0xFF9C27B0),
                          ),
                        ],
                      ),
                    ),

                    // 底部提示
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        border: Border(
                            top: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: Colors.grey.shade500, size: 16),
                              const SizedBox(width: 6),
                              Text('提示',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '如有疑问，请联系客服获取帮助。\n持续更新中，敬请期待更多功能！',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== 操作按钮区域（不截图）=====
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveAsImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_alt, size: 20),
                      label: Text(
                        _isSaving ? '正在生成图片...' : '保存为图片',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _openWechatArticle,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                        side: const BorderSide(color: Color(0xFF6366F1)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      icon: const Icon(Icons.article, size: 20),
                      label: const Text('打开公众号文章',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String number;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  const _GuideStep({
    required this.number,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(number,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 15),
                    const SizedBox(width: 5),
                    Text(title,
                        style:
                            TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color.withValues(alpha: 0.4), size: 18),
        ],
      ),
    );
  }
}
