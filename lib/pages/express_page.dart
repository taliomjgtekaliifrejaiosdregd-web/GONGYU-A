import 'package:flutter/material.dart';

class ExpressPage extends StatelessWidget {
  const ExpressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
        title: const Text('快递查询', style: TextStyle(fontSize: 14)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    decoration: InputDecoration(
                      hintText: '输入快递单号',
                      hintStyle: const TextStyle(fontSize: 11),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      prefixIcon: const Icon(Icons.local_shipping, size: 18, color: Color(0xFF9E9E9E)),
                    ),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('查询中...'), behavior: SnackBarBehavior.floating)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  child: const Text('查询', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('常用快递', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  _Logo('顺丰速运', 'SF', const Color(0xFF0070C0)),
                  _Logo('圆通速递', 'YT', const Color(0xFFFF9800)),
                  _Logo('中通快递', 'ZT', const Color(0xFFE53935)),
                  _Logo('韵达快递', 'YD', const Color(0xFF1E88E5)),
                  _Logo('申通快递', 'ST', const Color(0xFF00873F)),
                  _Logo('京东物流', 'JD', const Color(0xFFE53935)),
                  _Logo('菜鸟裹裹', 'CN', const Color(0xFF00C853)),
                  _Logo('EMS', 'EMS', const Color(0xFFFF5722)),
                ]),
                const SizedBox(height: 20),
                const Text('物流示例', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF2196F3).withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('顺丰速运', style: TextStyle(fontSize: 9, color: Color(0xFF2196F3), fontWeight: FontWeight.w600))),
                      const SizedBox(width: 10),
                      const Text('SF1234567890', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                    ]),
                    const SizedBox(height: 12),
                    _Step(true, '包裹已签收', '上海市浦东新区陆家嘴站', '2026-04-11 14:23'),
                    _Step(true, '配送员正在投递', '快递员王师傅：138****5678', '2026-04-11 08:45'),
                    _Step(true, '快件已到达【上海浦东转运中心】', '下一站：上海浦东陆家嘴营业部', '2026-04-10 22:30'),
                    _Step(false, '快件已发出', '发往：上海浦东陆家嘴营业部', '2026-04-10 18:20'),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final String name;
  final String abbr;
  final Color color;
  const _Logo(this.name, this.abbr, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Center(child: Text(abbr, style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 4),
      Text(name, style: TextStyle(fontSize: 9, color: color)),
    ]),
  );
}

class _Step extends StatelessWidget {
  final bool done;
  final String title;
  final String location;
  final String time;
  const _Step(this.done, this.title, this.location, this.time);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: done ? const Color(0xFF00C853) : const Color(0xFFE0E0E0))),
        Container(width: 1, height: 30, color: const Color(0xFFE0E0E0)),
      ]),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: done ? const Color(0xFF212121) : const Color(0xFF9E9E9E))),
        Text(location, style: const TextStyle(fontSize: 8, color: Color(0xFF9E9E9E))),
        Text(time, style: const TextStyle(fontSize: 8, color: Color(0xFFBDBDBD))),
      ])),
    ]),
  );
}
