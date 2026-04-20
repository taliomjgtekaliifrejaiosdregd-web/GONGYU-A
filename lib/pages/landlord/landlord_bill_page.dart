import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

/// 账单状态
enum BillState {
  paid('已支付', Color(0xFF10B981)),
  unpaid('待支付', Color(0xFFF59E0B)),
  overdue('已逾期', Color(0xFFEF4444));

  final String label;
  final Color color;
  const BillState(this.label, this.color);
}

/// 房源账单
class RoomBill {
  final int roomId;
  final String roomTitle;
  final String tenantName;
  final String tenantPhone;
  final BillState rentStatus;
  final BillState? waterStatus;
  final BillState? electricStatus;
  final double rentAmount;
  final double? waterAmount;
  final double? electricAmount;
  final String period;
  final String dueDate;
  final bool hasReminder;

  const RoomBill({
    required this.roomId,
    required this.roomTitle,
    required this.tenantName,
    required this.tenantPhone,
    required this.rentStatus,
    this.waterStatus,
    this.electricStatus,
    required this.rentAmount,
    this.waterAmount,
    this.electricAmount,
    required this.period,
    required this.dueDate,
    this.hasReminder = false,
  });

  double get totalAmount => rentAmount + (waterAmount ?? 0) + (electricAmount ?? 0);

  bool get hasOverdue => rentStatus == BillState.overdue ||
      (waterStatus == BillState.overdue) ||
      (electricStatus == BillState.overdue);
}

/// ============================================================
/// 房东端 - 账单管理
/// ============================================================
class LandlordBillPage extends StatefulWidget {
  const LandlordBillPage({super.key});

  @override
  State<LandlordBillPage> createState() => _LandlordBillPageState();
}

class _LandlordBillPageState extends State<LandlordBillPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  String _selectedPeriod = '2026-04';
  bool _showOverdueOnly = false;

  // Mock账单数据
  final List<RoomBill> _allBills = [
    RoomBill(
      roomId: 1, roomTitle: '陆家嘴花园整租', tenantName: '张先生', tenantPhone: '13912345678',
      rentStatus: BillState.unpaid, waterStatus: BillState.paid, electricStatus: BillState.unpaid,
      rentAmount: 5800, waterAmount: 68.5, electricAmount: 72.3,
      period: '2026-04', dueDate: '2026-04-10', hasReminder: true,
    ),
    RoomBill(
      roomId: 2, roomTitle: '浦东大道合租', tenantName: '李女士', tenantPhone: '13823456789',
      rentStatus: BillState.overdue, waterStatus: BillState.paid, electricStatus: BillState.overdue,
      rentAmount: 3200, waterAmount: 45.0, electricAmount: 57.0,
      period: '2026-04', dueDate: '2026-04-05',
    ),
    RoomBill(
      roomId: 3, roomTitle: '前滩公寓', tenantName: '（空置）', tenantPhone: '',
      rentStatus: BillState.unpaid,
      rentAmount: 0, waterAmount: 0, electricAmount: 0,
      period: '2026-04', dueDate: '2026-04-10',
    ),
    RoomBill(
      roomId: 4, roomTitle: '静安寺独栋', tenantName: '王总', tenantPhone: '13712345678',
      rentStatus: BillState.paid, waterStatus: BillState.paid, electricStatus: BillState.paid,
      rentAmount: 12000, waterAmount: 70.0, electricAmount: 270.0,
      period: '2026-04', dueDate: '2026-04-01',
    ),
    RoomBill(
      roomId: 5, roomTitle: '徐家汇精品公寓', tenantName: '陈小姐', tenantPhone: '13687654321',
      rentStatus: BillState.overdue, waterStatus: BillState.overdue, electricStatus: BillState.paid,
      rentAmount: 6800, waterAmount: 55.0, electricAmount: 120.0,
      period: '2026-04', dueDate: '2026-04-08',
    ),
  ];

  // 历史账单（模拟）
  final List<RoomBill> _historyBills = [
    RoomBill(
      roomId: 1, roomTitle: '陆家嘴花园整租', tenantName: '张先生', tenantPhone: '13912345678',
      rentStatus: BillState.paid, waterStatus: BillState.paid, electricStatus: BillState.paid,
      rentAmount: 5800, waterAmount: 65.0, electricAmount: 68.0,
      period: '2026-03', dueDate: '2026-03-10',
    ),
    RoomBill(
      roomId: 4, roomTitle: '静安寺独栋', tenantName: '王总', tenantPhone: '13712345678',
      rentStatus: BillState.paid, waterStatus: BillState.paid, electricStatus: BillState.paid,
      rentAmount: 12000, waterAmount: 65.0, electricAmount: 250.0,
      period: '2026-03', dueDate: '2026-03-01',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() => _currentTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<RoomBill> get _currentBills {
    var bills = _currentTab == 0
        ? _allBills.where((b) => b.period == _selectedPeriod).toList()
        : _currentTab == 1
            ? _allBills.where((b) => b.hasOverdue).toList()
            : _historyBills;
    if (_showOverdueOnly && _currentTab == 0) {
      bills = bills.where((b) => b.hasOverdue).toList();
    }
    return bills;
  }

  double get _monthTotalRent => _allBills
      .where((b) => b.period == _selectedPeriod)
      .fold(0.0, (sum, b) => sum + b.rentAmount);

  double get _monthCollected => _allBills
      .where((b) => b.period == _selectedPeriod && b.rentStatus == BillState.paid)
      .fold(0.0, (sum, b) => sum + b.rentAmount);

  double get _monthPending => _allBills
      .where((b) => b.period == _selectedPeriod && b.rentStatus != BillState.paid)
      .fold(0.0, (sum, b) => sum + b.rentAmount);

  double get _monthOverdue => _allBills
      .where((b) => b.period == _selectedPeriod && b.rentStatus == BillState.overdue)
      .fold(0.0, (sum, b) => sum + b.rentAmount);

  int get _overdueCount => _allBills
      .where((b) => b.hasOverdue).length;

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
        title: const Text('账单管理', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF6366F1)),
            onPressed: () => _showGenerateBills(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: const Color(0xFF9E9E9E),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          indicatorColor: const Color(0xFF6366F1),
          indicatorWeight: 3,
          tabs: [
            Tab(text: '本月账单'),
            Tab(text: '逾期(${_overdueCount})'),
            Tab(text: '历史'),
          ],
        ),
      ),
      body: Column(children: [
        // 统计栏
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(children: [
            Row(children: [
              const Text('账期选择：', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              _PeriodChip('2026-04', _selectedPeriod == '2026-04', () => setState(() => _selectedPeriod = '2026-04')),
              const SizedBox(width: 8),
              _PeriodChip('2026-03', _selectedPeriod == '2026-03', () => setState(() => _selectedPeriod = '2026-03')),
            ]),
            const SizedBox(height: 14),
            // 统计数据
            Row(children: [
              Expanded(child: _StatCard('应收租金', '¥${_monthTotalRent.toStringAsFixed(0)}', const Color(0xFF6366F1), Icons.account_balance_wallet)),
              const SizedBox(width: 8),
              Expanded(child: _StatCard('已收租金', '¥${_monthCollected.toStringAsFixed(0)}', const Color(0xFF10B981), Icons.check_circle)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _StatCard('待收租金', '¥${_monthPending.toStringAsFixed(0)}', const Color(0xFFF59E0B), Icons.schedule)),
              const SizedBox(width: 8),
              Expanded(child: _StatCard('逾期金额', '¥${_monthOverdue.toStringAsFixed(0)}', const Color(0xFFEF4444), Icons.warning)),
            ]),
          ]),
        ),

        // 筛选
        if (_currentTab == 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(children: [
              FilterChip(
                label: Text('只看逾期', style: TextStyle(fontSize: 11, color: _showOverdueOnly ? Colors.white : const Color(0xFF6366F1))),
                selected: _showOverdueOnly,
                selectedColor: const Color(0xFF6366F1),
                backgroundColor: const Color(0xFFF5F5F5),
                onSelected: (v) => setState(() => _showOverdueOnly = v),
                visualDensity: VisualDensity.compact,
              ),
            ]),
          ),

        const Divider(height: 1),

        // 账单列表
        Expanded(
          child: _currentBills.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(_currentTab == 1 ? '暂无逾期账单' : '暂无账单', style: TextStyle(color: Colors.grey.shade500)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _currentBills.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _BillCard(
                    bill: _currentBills[i],
                    onRemind: () => _sendReminder(context, _currentBills[i]),
                    onDetail: () => _showBillDetail(context, _currentBills[i]),
                    onConfirmPay: () => _confirmPayment(context, _currentBills[i]),
                  ),
                ),
        ),
      ]),
    );
  }

  void _showGenerateBills(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('生成账单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(children: [
              Row(children: [
                const Text('账期：', style: TextStyle(fontSize: 13)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      items: ['2026-04', '2026-03'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => Navigator.pop(context),
                    ),
                  ),
                ),
              ]),
              const Divider(),
              Row(children: [
                const Text('将生成：', style: TextStyle(fontSize: 13)),
                const Spacer(),
                Text('${_allBills.length}份账单', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Text('租金合计：', style: TextStyle(fontSize: 13)),
                const Spacer(),
                Text('¥${_monthTotalRent.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('取消'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已成功生成 ${1} 份账单并发送通知'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('确认生成并通知租客'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  void _sendReminder(BuildContext context, RoomBill bill) {
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
  }
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


  void _showBillDetail(BuildContext context, RoomBill bill) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, sc) => Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt, color: Color(0xFF6366F1)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(bill.roomTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(bill.period, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              ])),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(controller: sc, padding: const EdgeInsets.all(16), children: [
              // 汇总
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: bill.hasOverdue
                      ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                      : [const Color(0xFF6366F1), const Color(0xFF4F46E5)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: [
                  Text('¥${bill.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('应缴总额', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(children: [
                    _SubStat('租金', '¥${bill.rentAmount.toStringAsFixed(0)}', bill.rentStatus),
                    const SizedBox(width: 12),
                    if (bill.waterAmount != null)
                      _SubStat('水费', '¥${bill.waterAmount!.toStringAsFixed(0)}', bill.waterStatus!),
                    if (bill.electricAmount != null)
                      _SubStat('电费', '¥${bill.electricAmount!.toStringAsFixed(0)}', bill.electricStatus!),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              _DetailRow('房源', bill.roomTitle),
              _DetailRow('租客', bill.tenantName),
              if (bill.tenantPhone.isNotEmpty) _DetailRow('租客电话', bill.tenantPhone),
              _DetailRow('账期', bill.period),
              _DetailRow('截止日期', bill.dueDate),
              _DetailRow('催缴状态', bill.hasReminder ? '已催缴' : '未催缴'),
              const SizedBox(height: 16),
              // 操作按钮
              if (bill.rentStatus != BillState.paid) ...[
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
              ],
              if (bill.rentStatus == BillState.paid)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    const Text('本月账单已全部结清', style: TextStyle(fontSize: 13, color: Color(0xFF10B981))),
                  ]),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final RoomBill bill;
  final VoidCallback onRemind;
  final VoidCallback onDetail;
  final VoidCallback? onConfirmPay;
  const _BillCard({required this.bill, required this.onRemind, required this.onDetail, this.onConfirmPay});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDetail,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          // 顶部：房源 + 状态
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.home, color: Color(0xFF6366F1), size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(bill.roomTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(bill.tenantName, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bill.rentStatus.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(bill.rentStatus.label, style: TextStyle(fontSize: 11, color: bill.rentStatus.color, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // 明细
          Row(children: [
            _BillItem('租金', bill.rentAmount, bill.rentStatus),
            if (bill.waterAmount != null) _BillItem('水费', bill.waterAmount!, bill.waterStatus!),
            if (bill.electricAmount != null) _BillItem('电费', bill.electricAmount!, bill.electricStatus!),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('¥${bill.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
              const SizedBox(height: 2),
              Text('截止 ${bill.dueDate}', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            ]),
          ]),
          const SizedBox(height: 12),
          // 操作
          Row(children: [
            if (bill.hasReminder)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.notifications_active, size: 12, color: Colors.orange.shade700),
                  const SizedBox(width: 4),
                  Text('已催缴', style: TextStyle(fontSize: 10, color: Colors.orange.shade700)),
                ]),
              ),
            const Spacer(),
            if (bill.rentStatus != BillState.paid) ...[
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
            ],
            TextButton(
              onPressed: onDetail,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text('详情 →', style: TextStyle(fontSize: 12)),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _BillItem extends StatelessWidget {
  final String label;
  final double amount;
  final BillState status;
  const _BillItem(this.label, this.amount, this.status);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      const SizedBox(height: 2),
      Row(children: [
        Text('¥${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
        ),
      ]),
    ]),
  );
}

class _SubStat extends StatelessWidget {
  final String label;
  final String value;
  final BillState status;
  const _SubStat(this.label, this.value, this.status);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Text(status.label, style: const TextStyle(color: Colors.white, fontSize: 9)),
        ),
      ]),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatCard(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      ])),
    ]),
  );
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodChip(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF6366F1) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: selected ? Colors.white : Colors.black87)),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
    ]),
  );
}
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

