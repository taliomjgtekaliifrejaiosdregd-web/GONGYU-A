with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\goods_orders_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Fix the if-else in Row.children issue
old_block = """                  if (o.status == GoodsOrderStatus.pendingPayment)
                    Row(children: [
                      OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade600, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), minimumSize: Size.zero), child: const Text('取消', style: TextStyle(fontSize: 11))),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), minimumSize: Size.zero), child: const Text('付款', style: TextStyle(fontSize: 11))),
                    ])
                  else if (o.status == GoodsOrderStatus.shipped)
                    ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), minimumSize: Size.zero), child: const Text('确认收货', style: TextStyle(fontSize: 11)))
                  else
                    Text('查看详情', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),"""

new_block = """                  _buildOrderAction(o.status),"""

if old_block in content:
    content = content.replace(old_block, new_block)
    print('Replaced if-else block')
else:
    print('Pattern not found! Searching...')
    idx = content.find('pendingPayment')
    if idx >= 0:
        print(repr(content[idx-100:idx+300]))

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\goods_orders_page.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('done')
