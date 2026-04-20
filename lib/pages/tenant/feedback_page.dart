import 'package:flutter/material.dart';

/// ============================================================
// 租客 - 意见反馈
/// ============================================================
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _descCtrl = TextEditingController();
  String _selectedType = '功能建议';
  String? _selectedContact;
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  final List<String> _types = ['功能建议', 'Bug反馈', '体验问题', '投诉房东', '其他'];

  final List<Map<String, dynamic>> _history = [
    {
      'type': '功能建议',
      'content': '希望增加室友匹配功能，可以找到志同道合的室友',
      'time': '2026-04-15 14:32',
      'status': '已回复',
      'reply': '感谢您的建议！我们已记录，后续版本会考虑加入室友匹配功能。',
    },
    {
      'type': 'Bug反馈',
      'content': '在线缴费页面偶尔会卡住，刷新后恢复正常',
      'time': '2026-04-08 09:15',
      'status': '处理中',
      'reply': null,
    },
  ];

  void _submit() {
    if (_descCtrl.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请详细描述问题（至少10个字）'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _descCtrl.clear();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 64),
            const SizedBox(height: 16),
            const Text('反馈提交成功！', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('我们会在1-3个工作日内处理，感谢您的反馈！', style: TextStyle(fontSize: 12, color: Colors.grey.shade600), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('好的'),
            )),
          ]),
        ),
      );
    });
  }

  void _showHistoryDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(item['type'], style: const TextStyle(fontSize: 11, color: Color(0xFF6366F1), fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: item['status'] == '已回复' ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFF59E0B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(item['status'], style: TextStyle(fontSize: 11, color: item['status'] == '已回复' ? const Color(0xFF10B981) : const Color(0xFFF59E0B), fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text(item['time'], style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('我的反馈', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 6),
                Text(item['content'], style: const TextStyle(fontSize: 13)),
              ]),
            ),
            if (item['reply'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(10)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.support_agent, size: 14, color: Color(0xFF0284C7)),
                    const SizedBox(width: 6),
                    Text('官方回复 ${item['time'].toString().substring(0, 10)}', style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7))),
                  ]),
                  const SizedBox(height: 8),
                  Text(item['reply'], style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
                ]),
              ),
            ],
            const SizedBox(height: 24),
            if (item['status'] == '处理中')
              SizedBox(width: double.infinity, child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('我知道了'),
              )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('意见反馈', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // 反馈类型
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('反馈类型', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: _types.map((t) {
                final selected = t == _selectedType;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF6366F1) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(t, style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.grey.shade700, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                  ),
                );
              }).toList()),
            ]),
          ),
          const SizedBox(height: 12),

          // 反馈内容
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('反馈内容', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                Text('（${_descCtrl.text.length}/500）', style: TextStyle(fontSize: 11, color: _descCtrl.text.length > 500 ? Colors.red : Colors.grey.shade400)),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                maxLines: 6,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '请详细描述您遇到的问题或建议（至少10个字）...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.lightbulb_outline, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Expanded(child: Text('提供详细信息有助于我们更快处理您的问题', style: TextStyle(fontSize: 11, color: Colors.grey.shade400))),
              ]),
            ]),
          ),
          const SizedBox(height: 12),

          // 联系方式
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(children: [
              Row(children: [
                const Text('联系方式', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const Spacer(),
                Row(children: [
                  Checkbox(
                    value: _isAnonymous,
                    onChanged: (v) => setState(() => _isAnonymous = v ?? false),
                    activeColor: const Color(0xFF6366F1),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text('匿名反馈', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ]),
              ]),
              if (!_isAnonymous) ...[
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: '手机号或邮箱（选填，方便我们联系您）',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.phone, size: 18),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 12),

          // 上传截图
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('上传截图', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('（选填，上传问题截图有助于更快定位问题）', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE0E0E0), style: BorderStyle.solid),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_a_photo, color: Colors.grey.shade400, size: 24),
                    const SizedBox(height: 4),
                    Text('添加图片', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // 提交按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('提交反馈', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 24),

          // 历史反馈
          if (_history.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(children: [
                const Text('历史反馈', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(8)),
                  child: Text('${_history.length}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            ..._history.map((item) => GestureDetector(
              onTap: () => _showHistoryDetail(item),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(item['type'], style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1), fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: item['status'] == '已回复' ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFF59E0B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(item['status'], style: TextStyle(fontSize: 10, color: item['status'] == '已回复' ? const Color(0xFF10B981) : const Color(0xFFF59E0B), fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    Text(item['time'], style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                  ]),
                  const SizedBox(height: 10),
                  Text(item['content'], style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (item['reply'] != null) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      const Text('已回复', style: TextStyle(fontSize: 10, color: Color(0xFF10B981))),
                    ]),
                  ],
                ]),
              ),
            )),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
