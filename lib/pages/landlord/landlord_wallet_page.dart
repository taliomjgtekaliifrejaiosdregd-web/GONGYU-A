import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

/// 收支记录类型
enum TransactionType {
  income('收入', Icons.arrow_downward, Color(0xFF10B981)),
  expense('支出', Icons.arrow_upward, Color(0xFFEF4444));

  final String label;
  final IconData icon;
  final Color color;
  const TransactionType(this.label, this.icon, this.color);
}

/// 收支记录
class Transaction {
  final String id;
  final TransactionType type;
  final String title;
  final String? roomTitle;
  final double amount;
  final String date;
  final String category;

  const Transaction({
    required this.id,
    required this.type,
    required this.title,
    this.roomTitle,
    required this.amount,
    required this.date,
    required this.category,
  });
}

/// ============================================================
// 房东端 - 我的钱包
// ============================================================
class LandlordWalletPage extends StatefulWidget {
  const LandlordWalletPage({super.key});

  @override
  State<LandlordWalletPage> createState() => _LandlordWalletPageState();
}

class _LandlordWalletPageState extends State<LandlordWalletPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  // Mock账户数据
  double _balance = 24680.0; // 账户余额
  double _frozen = 1200.0;   // 冻结金额
  double _totalIncome = 128600.0;
  double _totalExpense = 103920.0;
  int _pendingCount = 3; // 待结算笔数

  // Mock交易记录
  final List<Transaction> _transactions = [
    Transaction(id: 'T001', type: TransactionType.income, title: '租金收入', roomTitle: '陆家嘴花园整租', amount: 5800, date: '2026-04-15', category: '租金'),
    Transaction(id: 'T002', type: TransactionType.income, title: '租金收入', roomTitle: '静安寺独栋', amount: 12000, date: '2026-04-15', category: '租金'),
    Transaction(id: 'T003', type: TransactionType.expense, title: '维修支出', roomTitle: '浦东大道合租', amount: 350, date: '2026-04-14', category: '维修'),
    Transaction(id: 'T004', type: TransactionType.income, title: '水费收入', roomTitle: '陆家嘴花园整租', amount: 68.5, date: '2026-04-14', category: '水电'),
    Transaction(id: 'T005', type: TransactionType.income, title: '电费收入', roomTitle: '静安寺独栋', amount: 270, date: '2026-04-14', category: '水电'),
    Transaction(id: 'T006', type: TransactionType.expense, title: '物业费支出', roomTitle: '静安寺独栋', amount: 2000, date: '2026-04-12', category: '物业'),
    Transaction(id: 'T007', type: TransactionType.income, title: '租金收入', roomTitle: '徐家汇精品公寓', amount: 6800, date: '2026-04-10', category: '租金'),
    Transaction(id: 'T008', type: TransactionType.income, title: '押金收入', roomTitle: '陆家嘴花园整租', amount: 5800, date: '2026-04-08', category: '押金'),
    Transaction(id: 'T009', type: TransactionType.expense, title: '门锁维修', roomTitle: '陆家嘴花园整租', amount: 150, date: '2026-04-07', category: '维修'),
    Transaction(id: 'T010', type: TransactionType.income, title: '租金收入', roomTitle: '浦东大道合租', amount: 3200, date: '2026-04-05', category: '租金'),
  ];

  List<Transaction> get _filtered {
    if (_currentTab == 0) return _transactions;
    if (_currentTab == 1) return _transactions.where((t) => t.type == TransactionType.income).toList();
    if (_currentTab == 2) return _transactions.where((t) => t.type == TransactionType.expense).toList();
    return _transactions;
  }

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

  double get _monthIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);

  double get _monthExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);

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
        title: const Text('我的钱包', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.primary),
            onPressed: () => _showAllTransactions(context),
          ),
        ],
      ),
      body: Column(children: [
        // 账户卡片
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(children: [
            // 账户余额
            Row(children: [
              const Text('账户余额（元）', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              GestureDetector(
                onTap: () => _showBalanceDetail(context),
                child: Row(children: [
                  const Icon(Icons.visibility_off, color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                  Text('隐藏余额', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                ]),
              ),
            ]),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('¥', style: TextStyle(color: Colors.white70, fontSize: 18)),
              const SizedBox(width: 4),
              Text(_balance.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 16),
            // 冻结 + 待结算
            Row(children: [
              _WalletStat('冻结金额', '¥${_frozen.toStringAsFixed(0)}', Colors.white54),
              const SizedBox(width: 24),
              _WalletStat('待结算', '$_pendingCount笔', Colors.orange.shade200),
            ]),
            const SizedBox(height: 16),
            // 操作按钮
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showWithdraw(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A1A2E),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('提现', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRecharge(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('充值'),
                ),
              ),
            ]),
          ]),
        ),

        // 本月收支
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Expanded(child: _MonthStat('本月收入', _monthIncome, const Color(0xFF10B981), Icons.arrow_downward)),
            Container(width: 1, height: 50, color: const Color(0xFFE0E0E0)),
            Expanded(child: _MonthStat('本月支出', _monthExpense, const Color(0xFFEF4444), Icons.arrow_upward)),
          ]),
        ),

        const SizedBox(height: 8),

        // 交易记录Tab
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: const Color(0xFF9E9E9E),
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: '全部'),
              Tab(text: '收入'),
              Tab(text: '支出'),
            ],
          ),
        ),

        // 交易列表
        Expanded(
          child: _filtered.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('暂无记录', style: TextStyle(color: Colors.grey.shade500)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _TransactionCard(transaction: _filtered[i]),
                ),
        ),
      ]),
    );
  }

  void _showBalanceDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('余额说明', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _ExplainItem(Icons.account_balance_wallet, '账户余额', '可随时提现到银行卡'),
          _ExplainItem(Icons.lock, '冻结金额', '押金等暂时冻结的资金'),
          _ExplainItem(Icons.schedule, '待结算', '租客付款后需等待到账'),
          _ExplainItem(Icons.credit_card, '提现规则', 'T+1工作日到账，节假日顺延'),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  void _showWithdraw(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('提现', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Text('可提现金额', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
              const Spacer(),
              Text('¥${_balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            ]),
          ),
          const SizedBox(height: 16),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '¥ ',
              hintText: '输入提现金额',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(children: [
            _QuickAmount('全部', true, () {}),
            _QuickAmount('5000', false, () {}),
            _QuickAmount('10000', false, () {}),
            _QuickAmount('20000', false, () {}),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text('提现将于1个工作日内到账，节假日顺延', style: TextStyle(fontSize: 11, color: Colors.orange.shade700))),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('提现申请已提交'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              child: const Text('确认提现', style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showRecharge(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('账户充值', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('充值说明', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
            child: const Text('充值用于：物业费、水电费、维修费等支出。资金原路退回。', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          ),
          const SizedBox(height: 16),
          const Text('充值金额', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('（演示模式）充值功能暂未开通，请联系客服。', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showAllTransactions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, sc) => Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Text('全部交易记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(child: ListView.separated(
            controller: sc,
            padding: const EdgeInsets.all(12),
            itemCount: _transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _TransactionCard(transaction: _transactions[i]),
          )),
        ]),
      ),
    );
  }
}

class _WalletStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _WalletStat(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(color: color, fontSize: 11)),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
  ]);
}

class _MonthStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  const _MonthStat(this.label, this.amount, this.color, this.icon);
  @override Widget build(BuildContext context) => Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 24, height: 24,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 14),
      ),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    ]),
    const SizedBox(height: 8),
    Text('¥${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
  ]);
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: t.type.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(t.type.icon, color: t.type.color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(t.roomTitle ?? t.category, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '${t.type == TransactionType.income ? '+' : '-'}¥${t.amount.toStringAsFixed(t.amount.truncateToDouble() == t.amount ? 0 : 2)}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.type.color),
          ),
          const SizedBox(height: 2),
          Text(t.date, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
        ]),
      ]),
    );
  }
}

class _QuickAmount extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _QuickAmount(this.label, this.active, this.onTap);
  @override Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.white : Colors.black87))),
      ),
    ),
  );
}

class _ExplainItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _ExplainItem(this.icon, this.title, this.desc);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ])),
    ]),
  );
}
