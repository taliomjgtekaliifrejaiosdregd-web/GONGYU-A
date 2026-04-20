import 'package:flutter/material.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _ctrl = TextEditingController();
  final List<_Msg> _msgs = [
    _Msg('您好！我是您的 AI 找房助手 🤖\n\n请告诉我您的需求，比如：\n• 「陆家嘴附近 5000 元以内的整租」\n• 「近地铁、精装修的房源」\n• 「徐汇区两室一厅」', false),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _msgs.add(_Msg(text, true));
      _msgs.add(_Msg(_mockReply(text), false));
    });
    _ctrl.clear();
  }

  String _mockReply(String text) {
    final replies = [
      '根据您的需求，为您找到以下优质房源 🏠\n\n1. 陆家嘴金融中心 · 精装修\n   ¥4,800/月 · 一室一厅 · 45㎡\n   近2号线地铁，拎包入住\n\n2. 浦东大道站 · 温馨一居\n   ¥4,200/月 · 一室一厅 · 38㎡\n   押一付一，支持月付\n\n3. 世纪大道旁 · 智能公寓\n   ¥5,200/月 · 一室一厅 · 52㎡\n   全套智能家居，管家服务\n\n点击房源卡片查看详情或预约看房 👆',
      '为您推荐以下地铁沿线房源 🚇\n\n• 前滩附近 4000-6000 元\n• 精装修、家电齐全\n• 近地铁、押一付一\n\n请选择您偏好的区域或直接告诉我预算和户型要求～',
      '好的，已为您记录找房偏好 📝\n\n当前热门区域推荐：\n• 浦东新区 1200+ 套\n• 徐汇区 900+ 套\n• 静安区 700+ 套\n\n还有更多需求吗？比如楼层、朝向、养宠物等特殊要求～',
    ];
    return replies[DateTime.now().second % replies.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.psychology, size: 18),
            SizedBox(width: 6),
            Text('AI智能找房', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.history, size: 18), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _msgs.length,
              itemBuilder: (context, i) => _ChatBubble(msg: _msgs[i]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: InputDecoration(
                        hintText: '描述您的找房需求...',
                        hintStyle: const TextStyle(fontSize: 10, color: Color(0xFFBDBDBD)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 10),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 38, height: 38,
                      decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isMe;
  _Msg(this.text, this.isMe);
}

class _ChatBubble extends StatelessWidget {
  final _Msg msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: msg.isMe ? const Color(0xFF00C853) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(msg.isMe ? 14 : 2),
            bottomRight: Radius.circular(msg.isMe ? 2 : 14),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
        ),
        child: Text(
          msg.text,
          style: TextStyle(fontSize: 10, color: msg.isMe ? Colors.white : const Color(0xFF212121), height: 1.4),
        ),
      ),
    );
  }
}
