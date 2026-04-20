# Fix goods_orders_page.dart
with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\goods_orders_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Fix import path
data = data.replace("import 'package:gongyu_guanjia/models\\tenant_order.dart';", "import 'package:gongyu_guanjia/models/tenant_order.dart';")

# Fix the if-spread issue - replace the problematic if statements
data = data.replace(
    "if (order.status == GoodsOrderStatus.pendingShip) [\n                OutlinedButton(onPressed: () {}, child: const Text('提醒发货')),\n              ],",
    "if (order.status == GoodsOrderStatus.pendingShip)\n                _ActionBtn('提醒发货', () {}),"
)
data = data.replace(
    "if (order.status == GoodsOrderStatus.shipped) [\n                ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white), child: const Text('确认收货')),\n              ],",
    "if (order.status == GoodsOrderStatus.shipped)\n                _ActionBtn('确认收货', () {}, color: const Color(0xFF10B981)),"
)
data = data.replace(
    "if (order.status == GoodsOrderStatus.completed) [\n                OutlinedButton(onPressed: () {}, child: const Text('申请售后')),\n              ],",
    "if (order.status == GoodsOrderStatus.completed)\n                _ActionBtn('申请售后', () {}),"
)

# Add _ActionBtn helper at end of file
action_btn = '''

class _ActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  const _ActionBtn(this.label, this.onPressed, {this.color});
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: color ?? Colors.grey.shade600,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      minimumSize: Size.zero,
    ),
    child: Text(label, style: TextStyle(fontSize: 11)),
  );
}
'''

# Append if not already there
if '_ActionBtn' not in data:
    data += action_btn

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\goods_orders_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print('goods_orders_page.dart fixed')
