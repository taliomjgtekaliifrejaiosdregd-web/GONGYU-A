import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';

/// 账单类型
enum BillType {
  rent('房租', Icons.home, Color(0xFF6366F1)),
  water('水费', Icons.water_drop, Color(0xFF06B6D4)),
  electricity('电费', Icons.electric_bolt, Color(0xFFF59E0B)),
  gas('燃气', Icons.local_fire_department, Color(0xFFEF4444));

  final String label;
  final IconData icon;
  final Color color;
  const BillType(this.label, this.icon, this.color);
}

/// 账单状态
enum BillStatus {
  unpaid('待支付', Color(0xFFF59E0B)),
  paid('已支付', Color(0xFF10B981)),
  overdue('已逾期', Color(0xFFEF4444));

  final String label;
  final Color color;
  const BillStatus(this.label, this.color);
}

/// 单条账单
class BillItem {
  final String id;
  final BillType type;
  final BillStatus status;
  final double amount;
  final double? balance;   // 余额（电表才有）
  final String roomTitle;
  final String period;     // 账期
  final String dueDate;
  final double? usage;      // 用量
  final double? unitPrice; // 单价

  const BillItem({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    this.balance,
    required this.roomTitle,
    required this.period,
    required this.dueDate,
    this.usage,
    this.unitPrice,
  });
}

/// ============================================================
/// 租客 - 水电煤 + 房租 缴费中心
/// ============================================================
class BillPaymentPage extends StatefulWidget {
  const BillPaymentPage({super.key});

  @override
  State<BillPaymentPage> createState() => _BillPaymentPageState();
}

class _BillPaymentPageState extends State<BillPaymentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  // Mock当月账单
  BillItem _thisMonthBill = const BillItem(
    id: 'BILL-202604',
    type: BillType.rent,
    status: BillStatus.unpaid,
    amount: 5800,
    roomTitle: '陆家嘴花园整租',
    period: '2026年4月',
    dueDate: '2026-04-10',
  );

  // Mock账单列表（历史）
  final List<BillItem> _historyBills = [
    const BillItem(
      id: 'BILL-202603',
      type: BillType.rent,
      status: BillStatus.paid,
      amount: 5800,
      roomTitle: '陆家嘴花园整租',
      period: '2026年3月',
      dueDate: '2026-03-10',
    ),
    const BillItem(
      id: 'BILL-202603-W',
      type: BillType.water,
      status: BillStatus.paid,
      amount: 68.5,
      roomTitle: '陆家嘴花园整租',
      period: '2026年3月',
      dueDate: '2026-03-25',
      usage: 8.5,
      unitPrice: 8.06,
    ),
    const BillItem(
      id: 'BILL-202603-E',
      type: BillType.electricity,
      status: BillStatus.paid,
      amount: 156.8,
      balance: 0,
      roomTitle: '陆家嘴花园整租',
      period: '2026年3月',
      dueDate: '2026-03-25',
      usage: 392.0,
      unitPrice: 0.4,
    ),
    const BillItem(
      id: 'BILL-202602',
      type: BillType.rent,
      status: BillStatus.paid,
      amount: 5800,
      roomTitle: '陆家嘴花园整租',
      period: '2026年2月',
      dueDate: '2026-02-10',
    ),
    const BillItem(
      id: 'BILL-202602-E',
      type: BillType.electricity,
      status: BillStatus.overdue,
      amount: 45.6,
      roomTitle: '陆家嘴花园整租',
      period: '2026年2月',
      dueDate: '2026-02-25',
      usage: 114.0,
      unitPrice: 0.4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('账单缴费', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: const Color(0xFF9E9E9E),
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          indicatorColor: const Color(0xFF6366F1),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '房租'),
            Tab(text: '水费'),
            Tab(text: '电费'),
            Tab(text: '燃气'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BillTab(type: BillType.rent, currentBill: _thisMonthBill, history: _historyBills.where((b) => b.type == BillType.rent).toList()),
          _BillTab(type: BillType.water, currentBill: null, history: _historyBills.where((b) => b.type == BillType.water).toList()),
          _ElectricBillTab(type: BillType.electricity, history: _historyBills.where((b) => b.type == BillType.electricity).toList()),
          _GasBillTab(type: BillType.gas),
        ],
      ),
    );
  }
}

/// ============================================================
/// 普通账单Tab（房租/水费/燃气）
/// ============================================================
class _BillTab extends StatelessWidget {
  final BillType type;
  final BillItem? currentBill;
  final List<BillItem> history;

  const _BillTab({required this.type, this.currentBill, required this.history});

  @override
  Widget build(BuildContext context) {
    // 找当月的未缴/逾期账单
    final unpaidCurrent = history.where((b) => b.status != BillStatus.paid).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当月未缴提示
          if (unpaidCurrent.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [type.color, type.color.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(type.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('待缴${type.label}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 12),
                  Text('¥${unpaidCurrent.first.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${unpaidCurrent.first.period} · ${unpaidCurrent.first.roomTitle}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showPaySheet(context, unpaidCurrent.first),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: type.color,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('立即支付', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _showBillDetail(context, unpaidCurrent.first),
                      style: TextButton.styleFrom(foregroundColor: Colors.white70),
                      child: const Text('账单详情', style: TextStyle(fontSize: 12)),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 无欠费时显示温馨提醒
          if (unpaidCurrent.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade400, size: 48),
                  const SizedBox(height: 12),
                  Text('本月${type.label}已缴清 ✅', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('暂无待缴账单，感谢您的准时缴纳！', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 充值入口（仅水费/电费）
          if (type != BillType.rent) ...[
            _RechargeCard(type: type),
            const SizedBox(height: 20),
          ],

          // 历史账单
          _SectionHeader('历史账单'),
          const SizedBox(height: 10),
          if (history.where((b) => b.status == BillStatus.paid).isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text('暂无历史账单', style: TextStyle(color: Colors.grey.shade400, fontSize: 13))),
            )
          else
            ...history.where((b) => b.status == BillStatus.paid).map((b) => _HistoryBillRow(item: b, type: type)),
        ],
      ),
    );
  }

  void _showPaySheet(BuildContext context, BillItem bill) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _PaySheet(bill: bill),
    );
  }

  void _showBillDetail(BuildContext context, BillItem bill) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${bill.period}${type.label}账单', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _DetailRow('账单编号', bill.id),
          _DetailRow('房源', bill.roomTitle),
          _DetailRow('账期', bill.period),
          _DetailRow('应缴金额', '¥${bill.amount.toStringAsFixed(2)}'),
          _DetailRow('截止日期', bill.dueDate),
          _DetailRow('状态', bill.status.label),
          if (bill.usage != null) _DetailRow('用量', '${bill.usage} m³'),
          if (bill.unitPrice != null) _DetailRow('单价', '¥${bill.unitPrice!.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

/// ============================================================
/// 电费专用Tab（带实时用量 + 充值功能）
/// ============================================================
class _ElectricBillTab extends StatelessWidget {
  final BillType type;
  final List<BillItem> history;

  const _ElectricBillTab({required this.type, required this.history});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 实时电表卡片
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.electric_bolt, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                const Text('实时电表', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Row(children: [
                    Icon(Icons.wifi, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text('在线', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ]),
                ),
              ]),
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('1560.0', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('度', style: TextStyle(color: Colors.white70, fontSize: 14))),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('余额', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 2),
                  const Text('¥200.0', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ]),
              ]),
              const SizedBox(height: 14),
              // 用量趋势小图
              Row(children: [
                _UsageTag('今日用电', '5.2度', Colors.white),
                const SizedBox(width: 8),
                _UsageTag('本月已用', '120.5度', Colors.white),
                const SizedBox(width: 8),
                _UsageTag('本月费用', '¥72.3', Colors.white),
              ]),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showRechargeSheet(context, 200),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFF59E0B),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('充值电费', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // 充值套餐
          _RechargeCard(type: type),

          const SizedBox(height: 20),

          // 历史电费账单
          _SectionHeader('历史账单'),
          const SizedBox(height: 10),
          if (history.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text('暂无历史账单', style: TextStyle(color: Colors.grey.shade400, fontSize: 13))),
            )
          else
            ...history.map((b) => _HistoryBillRow(item: b, type: type)),
        ],
      ),
    );
  }

  void _showRechargeSheet(BuildContext context, double currentBalance) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _RechargeSheet(type: type, currentBalance: currentBalance),
    );
  }
}

/// ============================================================
/// 燃气Tab（占位）
/// ============================================================
class _GasBillTab extends StatelessWidget {
  final BillType type;
  const _GasBillTab({required this.type});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_fire_department, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('暂未开通燃气账单', style: TextStyle(fontSize: 15, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 8),
          Text('如需开通，请联系房东', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

/// ============================================================
/// 充值入口卡片
/// ============================================================
class _RechargeCard extends StatelessWidget {
  final BillType type;
  const _RechargeCard({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: type.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(type.icon, color: type.color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${type.label}充值', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('实时到账，秒充秒用', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ]),
        ),
        GestureDetector(
          onTap: () => _showRechargeSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: type.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('立即充值', style: TextStyle(fontSize: 12, color: type.color, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  void _showRechargeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _RechargeSheet(type: type, currentBalance: 0),
    );
  }
}

/// ============================================================
/// 历史账单行
/// ============================================================
class _HistoryBillRow extends StatelessWidget {
  final BillItem item;
  final BillType type;
  const _HistoryBillRow({required this.item, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: item.status.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(item.status.icon, color: item.status.color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.period, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(item.status.label, style: TextStyle(fontSize: 10, color: item.status.color)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('¥${item.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          if (item.usage != null)
            Text('${item.usage}度', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ]),
      ]),
    );
  }
}

/// ============================================================
/// 充值页
/// ============================================================
class _RechargeSheet extends StatefulWidget {
  final BillType type;
  final double currentBalance;
  const _RechargeSheet({required this.type, required this.currentBalance});

  @override
  State<_RechargeSheet> createState() => _RechargeSheetState();
}

class _RechargeSheetState extends State<_RechargeSheet> {
  int _selectedAmount = 100;

  final _amounts = [20, 50, 100, 200, 500];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: widget.type.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(widget.type.icon, color: widget.type.color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${widget.type.label}充值', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (widget.currentBalance > 0)
              Text('当前余额 ¥${widget.currentBalance.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ])),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 20),
        const Text('选择充值金额', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _amounts.map((a) => GestureDetector(
            onTap: () => setState(() => _selectedAmount = a),
            child: Container(
              width: (MediaQuery.of(context).size.width - 20 * 2 - 10 * 3) / 3,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _selectedAmount == a ? widget.type.color.withOpacity(0.1) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedAmount == a ? widget.type.color : Colors.transparent, width: 1.5),
              ),
              child: Column(children: [
                Text('¥$a', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _selectedAmount == a ? widget.type.color : Colors.black87)),
                if (widget.type == BillType.electricity) ...[
                  const SizedBox(height: 4),
                  Text('约${(a / 0.4).toStringAsFixed(0)}度', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                ],
              ]),
            ),
          )).toList(),
        ),
        const SizedBox(height: 16),
        // 自定义金额
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Text('¥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '自定义金额',
                  hintStyle: TextStyle(fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null) setState(() => _selectedAmount = n);
                },
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _confirmRecharge(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.type.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Text('支付 ¥$_selectedAmount', style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: Text('支付成功后金额将实时到账', style: TextStyle(fontSize: 11, color: Colors.grey.shade500))),
      ]),
    );
  }

  void _confirmRecharge(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 20)),
          const SizedBox(width: 10),
          const Text('充值成功'),
        ]),
        content: Text('已成功充值 ¥$_selectedAmount 到您的${widget.type.label}账户，金额实时到账。'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('好的'))],
      ),
    );
  }
}

/// ============================================================
/// 支付页
/// ============================================================
class _PaySheet extends StatelessWidget {
  final BillItem bill;
  const _PaySheet({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        const Text('确认支付', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [bill.type.color, bill.type.color.withOpacity(0.7)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Icon(bill.type.icon, color: Colors.white, size: 32),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(bill.roomTitle, style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 4),
              Text(bill.period, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ])),
            Text('¥${bill.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('选择支付方式', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        // 微信支付
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF07C160)),
          ),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF07C160).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.payment, color: Color(0xFF07C160), size: 20)),
            const SizedBox(width: 12),
            const Expanded(child: Text('微信支付', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            Container(width: 20, height: 20, decoration: const BoxDecoration(color: Color(0xFF07C160), shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 14)),
          ]),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _doPay(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: bill.type.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Text('确认支付 ¥${bill.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: Text('支付成功后可在"缴费记录"中查看', style: TextStyle(fontSize: 11, color: Colors.grey.shade500))),
      ]),
    );
  }

  void _doPay(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.canPop(context)) Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('支付成功！'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
      );
    });
  }
}

class _UsageTag extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _UsageTag(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 9)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF424242)));
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
    ]),
  );
}

extension on BillStatus {
  IconData get icon {
    switch (this) {
      case BillStatus.paid: return Icons.check_circle;
      case BillStatus.unpaid: return Icons.schedule;
      case BillStatus.overdue: return Icons.warning;
    }
  }
}
