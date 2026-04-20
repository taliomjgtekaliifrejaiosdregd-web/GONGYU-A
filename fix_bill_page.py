# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_bill_page.dart', 'r', encoding='utf-8') as f:
    data = f.read()

# 1. Add _confirmPayment method to _LandlordBillPageState
# Find the _sendReminder method and add _confirmPayment after it
old_reminder_end = """  void _sendReminder(BuildContext context, RoomBill bill) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('发送催缴'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
            child: Column(children: [
              Text(bill.roomTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('应缴：¥${bill.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 12),
          const Text('将发送微信/短信提醒租客尽快缴纳', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('催缴通知已发送'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('确认发送'),
          ),
        ],
      ),
    );
  }"""

confirm_payment = """
  void _confirmPayment(BuildContext context, RoomBill bill) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('确认收款'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: [
              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 48),
              const SizedBox(height: 12),
              Text('¥${bill.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              const SizedBox(height: 4),
              Text(bill.roomTitle, style: const TextStyle(fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('确认租客已付款，将更新账单状态为"已支付"', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 8),
          // 收款方式选择
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('收款方式', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(children: [
                _PayMethod('微信', Icons.chat, const Color(0xFF07C160)),
                const SizedBox(width: 10),
                _PayMethod('支付宝', Icons.payment, const Color(0xFF1677FF)),
                const SizedBox(width: 10),
                _PayMethod('银行转账', Icons.account_balance, const Color(0xFF6366F1)),
                const SizedBox(width: 10),
                _PayMethod('现金', Icons.money, const Color(0xFFF59E0B)),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.info_outline, size: 14, color: Color(0xFF9E9E9E)),
            const SizedBox(width: 4),
            Expanded(child: Text('收款时间：${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)))),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              // Don't Navigator.pop here - the bottom sheet is already closed or we want to stay on the page
              // Update bill status
              setState(() {
                final idx = _allBills.indexWhere((b) => b.roomId == bill.roomId && b.period == bill.period);
                if (idx >= 0) {
                  _allBills[idx] = RoomBill(
                    roomId: bill.roomId,
                    roomTitle: bill.roomTitle,
                    tenantName: bill.tenantName,
                    tenantPhone: bill.tenantPhone,
                    rentStatus: BillState.paid,
                    waterStatus: bill.waterStatus,
                    electricStatus: bill.electricStatus,
                    rentAmount: bill.rentAmount,
                    waterAmount: bill.waterAmount,
                    electricAmount: bill.electricAmount,
                    period: bill.period,
                    dueDate: bill.dueDate,
                    hasReminder: true,
                  );
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已确认收款 ¥${bill.totalAmount.toStringAsFixed(2)}，账单已标记为已支付'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF10B981),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('确认收款'),
          ),
        ],
      ),
    );
  }
"""

if old_reminder_end in data:
    data = data.replace(old_reminder_end, old_reminder_end + confirm_payment)
    print('1. Added _confirmPayment method')
else:
    print('WARNING: _sendReminder end pattern not found')

# 2. Add _PayMethod widget class at the end of the file (before the last closing brace)
pay_method_class = """
class _PayMethod extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _PayMethod(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}
"""

# Add before the last closing brace of the file
data = data.rstrip() + pay_method_class + '\n'

# 3. Update _showBillDetail to add "确认收款" button
old_detail_paid = """              if (bill.rentStatus == BillState.paid)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    const Text('本月账单已全部结清', style: TextStyle(fontSize: 13, color: Color(0xFF10B981))),
                  ]),
                ),"""

new_detail_paid = """              if (bill.rentStatus == BillState.paid)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    const Text('本月账单已全部结清', style: TextStyle(fontSize: 13, color: Color(0xFF10B981))),
                  ]),
                ),"""

if old_detail_paid in data:
    data = data.replace(old_detail_paid, new_detail_paid)
    print('2. Updated detail paid section')
else:
    print('WARNING: detail paid section not found')

# 4. Update _showBillDetail to add "确认收款" button in action buttons section
old_detail_actions = """              if (bill.rentStatus != BillState.paid) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); _sendReminder(context, bill); },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('发送催缴通知'),
                  ),
                ),
                const SizedBox(height: 8),
              ],"""

new_detail_actions = """              if (bill.rentStatus != BillState.paid) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); _sendReminder(context, bill); },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('发送催缴通知'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmPayment(context, bill),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('确认收款（租客已付）'),
                  ),
                ),
                const SizedBox(height: 8),
              ],"""

if old_detail_actions in data:
    data = data.replace(old_detail_actions, new_detail_actions)
    print('3. Added 确认收款 button to detail sheet')
else:
    print('WARNING: detail actions not found')

# 5. Also update the bill card to add "确认收款" button
old_card_actions = """            if (bill.rentStatus != BillState.paid)
              OutlinedButton(
                onPressed: onRemind,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('催缴', style: TextStyle(fontSize: 12)),
              ),
            const SizedBox(width: 8),"""

new_card_actions = """            if (bill.rentStatus != BillState.paid) ...[
              OutlinedButton(
                onPressed: onRemind,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('催缴', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: onConfirmPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('收款', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 6),
            ],"""

if old_card_actions in data:
    data = data.replace(old_card_actions, new_card_actions)
    print('4. Added 收款 button to bill card')
else:
    print('WARNING: bill card actions not found')

# 6. Add onConfirmPay to _BillCard
old_card_init = "class _BillCard extends StatelessWidget {\n  final RoomBill bill;\n  final VoidCallback onRemind;\n  final VoidCallback onDetail;\n  const _BillCard({required this.bill, required this.onRemind, required this.onDetail});"
new_card_init = "class _BillCard extends StatelessWidget {\n  final RoomBill bill;\n  final VoidCallback onRemind;\n  final VoidCallback onDetail;\n  final VoidCallback? onConfirmPay;\n  const _BillCard({required this.bill, required this.onRemind, required this.onDetail, this.onConfirmPay});"
if old_card_init in data:
    data = data.replace(old_card_init, new_card_init)
    print('5. Added onConfirmPay to _BillCard')
else:
    print('WARNING: _BillCard init not found')

# 7. Update ListView itemBuilder to pass onConfirmPay
old_item_builder = "itemBuilder: (_, i) => _BillCard(\n                    bill: _currentBills[i],\n                    onRemind: () => _sendReminder(context, _currentBills[i]),\n                    onDetail: () => _showBillDetail(context, _currentBills[i]),\n                  ),"
new_item_builder = "itemBuilder: (_, i) => _BillCard(\n                    bill: _currentBills[i],\n                    onRemind: () => _sendReminder(context, _currentBills[i]),\n                    onDetail: () => _showBillDetail(context, _currentBills[i]),\n                    onConfirmPay: () => _confirmPayment(context, _currentBills[i]),\n                  ),"
if old_item_builder in data:
    data = data.replace(old_item_builder, new_item_builder)
    print('6. Updated ListView itemBuilder')
else:
    print('WARNING: ListView itemBuilder not found')

with open(r'D:\Projects\gongyu_guanjia\lib\pages\landlord\landlord_bill_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print(f'Final size: {len(data)}')
print('Saved!')
