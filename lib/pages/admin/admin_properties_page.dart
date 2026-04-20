import 'package:flutter/material.dart';

// ============================================================
// 后台管理 - 房源总览
// ============================================================
class AdminPropertiesPage extends StatelessWidget {
  const AdminPropertiesPage({super.key});

  static const _stats = {'total': 186, 'rented': 142, 'vacant': 31, 'maintenance': 13};
  static const _properties = [
    {'id': 'P001', 'title': '华侨城花园A栋501', 'landlord': '李明', 'tenant': '张三', 'rent': 3200, 'status': '已出租', 'type': '整租', 'area': '85㎡', 'floor': '5/28'},
    {'id': 'P002', 'title': '科技园公寓B栋302', 'landlord': '陈强', 'tenant': '王五', 'rent': 2800, 'status': '已出租', 'type': '整租', 'area': '72㎡', 'floor': '3/18'},
    {'id': 'P003', 'title': '龙华公馆C栋201', 'landlord': '赵雪', 'tenant': '李四', 'rent': 3500, 'status': '已出租', 'type': '整租', 'area': '95㎡', 'floor': '2/22'},
    {'id': 'P004', 'title': '南山花园D栋601', 'landlord': '李明', 'tenant': '陈六', 'rent': 4200, 'status': '已出租', 'type': '整租', 'area': '110㎡', 'floor': '6/30'},
    {'id': 'P005', 'title': '福田中心E栋401', 'landlord': '陈强', 'tenant': '-', 'rent': 0, 'status': '空置中', 'type': '整租', 'area': '80㎡', 'floor': '4/25'},
    {'id': 'P006', 'title': '罗湖小区F栋102', 'landlord': '赵雪', 'tenant': '-', 'rent': 0, 'status': '空置中', 'type': '整租', 'area': '68㎡', 'floor': '1/15'},
    {'id': 'P007', 'title': '宝安中心G栋702', 'landlord': '李明', 'tenant': '-', 'rent': 0, 'status': '维护中', 'type': '整租', 'area': '90㎡', 'floor': '7/20'},
    {'id': 'P008', 'title': '坂田公寓H栋503', 'landlord': '陈强', 'tenant': '郑八', 'rent': 2600, 'status': '已出租', 'type': '合租', 'area': '25㎡', 'floor': '5/12'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('房源总览', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.add_location_alt_outlined), onPressed: () => _addProperty(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 统计卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.home_work, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('房源总数', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('${_stats['total']} 套', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Text('出租率 76.3%', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _MiniStat('已出租', '${_stats['rented']}', Colors.white70),
                _MiniStat('空置中', '${_stats['vacant']}', Colors.amber.shade200),
                _MiniStat('维护中', '${_stats['maintenance']}', Colors.red.shade200),
                _MiniStat('月租金', '¥48.2万', Colors.green.shade200),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          // 空置房源预警
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFDE68A))),
            child: Row(children: [
              const Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('空置提醒', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                Text('当前有 ${_stats['vacant']} 套房源空置中，建议及时调整价格或推广', style: TextStyle(fontSize: 11, color: Color(0xFFB45309))),
              ])),
            ]),
          ),

          const SizedBox(height: 16),

          // 房源列表
          const Text('房源列表', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._properties.map((p) => _PropertyCard(property: p, onTap: () => _showDetail(context, p))),
        ]),
      ),
    );
  }

  void _addProperty(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('添加房源', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(decoration: const InputDecoration(labelText: '房源名称', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: '详细地址', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(decoration: const InputDecoration(labelText: '面积（㎡）', border: OutlineInputBorder()))),
            const SizedBox(width: 12),
            Expanded(child: TextField(decoration: const InputDecoration(labelText: '租金/月', border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: '整租',
            decoration: const InputDecoration(labelText: '租赁类型', border: OutlineInputBorder()),
            items: ['整租', '合租', '短租'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('房源添加成功'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              child: const Text('确认添加', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> p) {
    Color statusColor;
    switch (p['status']) {
      case '已出租': statusColor = const Color(0xFF10B981); break;
      case '空置中': statusColor = const Color(0xFFF59E0B); break;
      case '维护中': statusColor = const Color(0xFFEF4444); break;
      default: statusColor = const Color(0xFF9E9E9E);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(p['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(p['status']!, style: TextStyle(fontSize: 12, color: statusColor)),
            ),
          ]),
          const SizedBox(height: 16),
          _DetailRow('房源编号', p['id']!),
          _DetailRow('房源类型', p['type']!),
          _DetailRow('建筑面积', p['area']!),
          _DetailRow('楼层信息', p['floor']!),
          _DetailRow('房东姓名', p['landlord']!),
          _DetailRow('租客', p['tenant']! == '-' ? '暂无租客' : p['tenant']!),
          if (p['status'] == '已出租') _DetailRow('月租金', '¥${p['rent']}'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('关闭'))),
            const SizedBox(width: 12),
            if (p['status'] != '维护中')
              Expanded(child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已下架房源'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFFF59E0B)),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                child: const Text('下架'),
              )),
            if (p['status'] == '维护中')
              Expanded(child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已结束维护，房源重新上架'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                child: const Text('结束维护'),
              )),
          ]),
        ]),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
    Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
  ]));
}

class _PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;
  const _PropertyCard({required this.property, required this.onTap});

  Color get _statusColor {
    switch (property['status']) {
      case '已出租': return const Color(0xFF10B981);
      case '空置中': return const Color(0xFFF59E0B);
      case '维护中': return const Color(0xFFEF4444);
      default: return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.home, color: _statusColor, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(property['title']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(children: [
            Text('${property['type']} · ${property['area']}', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            const SizedBox(width: 8),
            Text(property['floor']!, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (property['status'] == '已出租')
            Text('¥${property['rent']}/月', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(property['status']!, style: TextStyle(fontSize: 11, color: _statusColor)),
          ),
        ]),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 18),
      ]),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
    ]),
  );
}
