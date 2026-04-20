import 'package:flutter/material.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      isMe: false,
      text: '您好！我是自优租AI助手 🤖\n\n我可以帮您：\n• 找房：根据需求推荐最优房源\n• 签约：解答租房合同疑问\n• 维修：预约保洁、维修服务\n• 投诉：处理租房中的问题\n• 购物：推荐尖叫好货精选商品\n\n有什么可以帮到您？',
      time: _now(),
    ));
  }

  String _now() => DateTime.now().toString().substring(11, 16);

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(isMe: true, text: text, time: _now()));
      _controller.clear();
    });
    _scrollToBottom();
    // AI 模拟回复
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final reply = _aiReply(text);
      setState(() => _messages.add(_ChatMessage(isMe: false, text: reply, time: _now())));
      _scrollToBottom();
    });
  }

  String _aiReply(String text) {
    final t = text.toLowerCase();
    if (t.contains('找房') || t.contains('租房') || t.contains('房源')) {
      return '好的！我来帮您找房 🏠\n\n请告诉我您的需求：\n1️⃣ 区域偏好（浦东/浦西等）\n2️⃣ 预算范围\n3️⃣ 户型要求（整租/合租）\n4️⃣ 其他要求（近地铁、精装修等）\n\n或者直接点击下方"AI找房"，我会智能匹配！';
    } else if (t.contains('维修') || t.contains('保洁') || t.contains('服务')) {
      return '物业服务我来帮您安排 🔧\n\n目前可预约的服务：\n• 🧹 日常保洁  ¥80/次\n• 🔧 家具维修  ¥50起\n• 🔌 家电清洗  ¥120/台\n• 🚚 搬家服务  面议\n\n请告诉我需要哪种服务？';
    } else if (t.contains('租金') || t.contains('合同') || t.contains('押金')) {
      return '关于费用和合同 📋\n\n• 租金付款方式：月付/季付/年付\n• 押金标准：通常为1个月租金\n• 合同期限：最短1年起\n• 中途退租：需提前30天告知\n\n具体房源的详细费用可以在房源详情页查看~';
    } else if (t.contains('购物') || t.contains('尖叫好货') || t.contains('好货')) {
      return '尖叫好货专区来了 🛒\n\n精选生活好物，房东直供：\n• 智能家居 品质电器\n• 居家日用 收纳好物\n• 厨房电器 美食必备\n\n全场品质保障，部分商品房东专享优惠，点击下方"尖叫好货"去看看吧！';
    } else {
      return '收到！让我想想 🤔\n\n根据您的问题，建议您：\n• 找房 → 点击"AI找房"或首页搜索\n• 预约看房 → 进入房源详情页\n• 物业服务 → 点击"服务"\n• 联系房东 → 房源详情页有房东电话\n\n还有其他问题随时问我！';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: const Text('AI管家'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() => _messages.clear())),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _ChatBubble(msg: _messages[index]),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '输入您的问题...',
                      hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF2196F3), borderRadius: BorderRadius.circular(24)),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final bool isMe;
  final String text;
  final String time;
  _ChatMessage({required this.isMe, required this.text, required this.time});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isMe) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF64B5F6)]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isMe ? const Color(0xFF00C853) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: msg.isMe ? const Radius.circular(16) : Radius.zero,
                      bottomRight: msg.isMe ? Radius.zero : const Radius.circular(16),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(fontSize: 14, color: msg.isMe ? Colors.white : const Color(0xFF212121), height: 1.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(msg.time, style: const TextStyle(fontSize: 10, color: Color(0xFFBDBDBD))),
              ],
            ),
          ),
          if (msg.isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
