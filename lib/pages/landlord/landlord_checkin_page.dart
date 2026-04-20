import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

/// 入住状态
enum CheckinStatus {
  pending('待入住', Color(0xFFF59E0B)),
  checkedIn('已入住', Color(0xFF10B981)),
  leaving('退房中', Color(0xFFEF4444)),
  checkedOut('已退房', Color(0xFF9E9E9E));

  final String label;
  final Color color;
  const CheckinStatus(this.label, this.color);
}

/// 入住记录
class CheckinRecord {
  final String id;
  final CheckinStatus status;
  final String roomTitle;
  final String tenantName;
  final String tenantPhone;
  final String checkinDate;
  final String? checkoutDate;
  final String? contractNo;
  final double rentAmount;

  const CheckinRecord({
    required this.id,
    required this.status,
    required this.roomTitle,
    required this.tenantName,
    required this.tenantPhone,
    required this.checkinDate,
    this.checkoutDate,
    this.contractNo,
    required this.rentAmount,
  });
}

/// ============================================================
// 房东端 - 入住管理
/// ============================================================
class LandlordCheckinPage extends StatefulWidget {
  const LandlordCheckinPage({super.key});

  @override
  State<LandlordCheckinPage> createState() => _LandlordCheckinPageState();
}

class _LandlordCheckinPageState extends State<LandlordCheckinPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  final List<CheckinRecord> _records = [
    CheckinRecord(
      id: 'CK001', status: CheckinStatus.checkedIn,
      roomTitle: '陆家嘴花园整租', tenantName: '张先生', tenantPhone: '13912345678',
      checkinDate: '2024-01-01', contractNo: 'HT2024010001', rentAmount: 5800,
    ),
    CheckinRecord(
      id: 'CK002', status: CheckinStatus.checkedIn,
      roomTitle: '浦东大道合租', tenantName: '李女士', tenantPhone: '13823456789',
      checkinDate: '2024-02-01', contractNo: 'HT2024020002', rentAmount: 3200,
    ),
    CheckinRecord(
      id: 'CK003', status: CheckinStatus.leaving,
      roomTitle: '徐家汇精品公寓', tenantName: '陈小姐', tenantPhone: '13687654321',
      checkinDate: '2024-01-01', contractNo: 'HT2024010004', rentAmount: 6800,
    ),
    CheckinRecord(
      id: 'CK004', status: CheckinStatus.checkedOut,
      roomTitle: '静安寺独栋', tenantName: '王总', tenantPhone: '13712345678',
      checkinDate: '2023-09-01', checkoutDate: '2026-03-31', contractNo: 'HT2023090003', rentAmount: 12000,
    ),
    CheckinRecord(
      id: 'CK005', status: CheckinStatus.pending,
      roomTitle: '前滩公寓', tenantName: '刘先生', tenantPhone: '13512344321',
      checkinDate: '2026-04-20', rentAmount: 4500,
    ),
  ];

  List<CheckinRecord> get _filtered {
    if (_currentTab == 0) return _records;
    return _records.where((r) {
      final statusMap = {
        1: CheckinStatus.pending,
        2: CheckinStatus.checkedIn,
        3: CheckinStatus.leaving,
        4: CheckinStatus.checkedOut,
      };
      return r.status == statusMap[_currentTab];
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() => _currentTab = _tabController.index);
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
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('入住管理', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: AppColors.primary),
            onPressed: () => _showAddCheckin(context),
          ),
        ],
      ),
      body: Column(children: [
        // 统计
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Row(children: [
            _StatChip('全部', _records.length, AppColors.primary),
            const SizedBox(width: 12),
            _StatChip('待入住', _records.where((r) => r.status == CheckinStatus.pending).length, const Color(0xFFF59E0B)),
            const SizedBox(width: 12),
            _StatChip('已入住', _records.where((r) => r.status == CheckinStatus.checkedIn).length, const Color(0xFF10B981)),
            const SizedBox(width: 12),
            _StatChip('退房中', _records.where((r) => r.status == CheckinStatus.leaving).length, const Color(0xFFEF4444)),
          ]),
        ),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF9E9E9E),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          isScrollable: true,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '待入住'),
            Tab(text: '已入住'),
            Tab(text: '退房中'),
            Tab(text: '已退房'),
          ],
        ),
        Expanded(
          child: _filtered.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.bed_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('暂无入住记录', style: TextStyle(color: Colors.grey.shade500)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _CheckinCard(
                    record: _filtered[i],
                    onTap: () => _showDetail(context, _filtered[i]),
                    onAction: () => _showAction(context, _filtered[i]),
                  ),
                ),
        ),
      ]),
    );
  }

  void _showDetail(BuildContext context, CheckinRecord r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.bed, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.roomTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('¥${r.rentAmount}/月', style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: r.status.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(r.status.label, style: TextStyle(fontSize: 11, color: r.status.color, fontWeight: FontWeight.w600)),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 16),
          _DetailRow('入住编号', r.id),
          _DetailRow('房源', r.roomTitle),
          _DetailRow('租客姓名', r.tenantName),
          _DetailRow('联系电话', r.tenantPhone),
          _DetailRow('入住日期', r.checkinDate),
          if (r.contractNo != null) _DetailRow('关联合同', r.contractNo!),
          if (r.checkoutDate != null) _DetailRow('退房日期', r.checkoutDate!),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showAction(BuildContext context, CheckinRecord r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.roomTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('租客：${r.tenantName}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          if (r.status == CheckinStatus.pending)
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.login, color: Color(0xFF10B981))),
              title: const Text('确认入住'),
              subtitle: const Text('标记租客已入住'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('入住确认成功'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)));
              },
            ),
          if (r.status == CheckinStatus.checkedIn)
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.logout, color: Color(0xFFF59E0B))),
              title: const Text('发起退房'),
              subtitle: const Text('发起退房流程'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('退房流程已发起'), behavior: SnackBarBehavior.floating));
              },
            ),
          if (r.status == CheckinStatus.leaving)
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.check_circle, color: Color(0xFFEF4444))),
              title: const Text('确认退房完成'),
              subtitle: const Text('确认租客已退房并完成结算'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('退房已完成'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)));
              },
            ),
          ListTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.phone, color: Color(0xFF6366F1))),
            title: const Text('联系租客'),
            subtitle: Text(r.tenantPhone),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('拨打 ${r.tenantPhone}'), behavior: SnackBarBehavior.floating));
            },
          ),
        ]),
      ),
    );
  }

  void _showAddCheckin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('新增入住', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(decoration: const InputDecoration(labelText: '租客姓名', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: '联系电话', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: '入住日期', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('入住记录已添加'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              child: const Text('保存', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip(this.label, this.count, this.color);
  @override Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    const SizedBox(width: 4),
    Text('$count', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
  ]);
}

class _CheckinCard extends StatelessWidget {
  final CheckinRecord record;
  final VoidCallback onTap;
  final VoidCallback onAction;
  const _CheckinCard({required this.record, required this.onTap, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final r = record;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.bed, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.roomTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(r.tenantName, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: r.status.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(r.status.label, style: TextStyle(fontSize: 11, color: r.status.color, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(children: [
            _InfoItem(Icons.phone, r.tenantPhone),
            const SizedBox(width: 16),
            _InfoItem(Icons.calendar_today, r.checkinDate),
            const Spacer(),
            Text('¥${r.rentAmount}/月', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: r.status.color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Text(_getActionLabel(r.status), style: TextStyle(fontSize: 11, color: r.status.color, fontWeight: FontWeight.w500)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  String _getActionLabel(CheckinStatus s) {
    if (s == CheckinStatus.pending) return '确认入住';
    if (s == CheckinStatus.checkedIn) return '发起退房';
    if (s == CheckinStatus.leaving) return '退房完成';
    return '查看';
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoItem(this.icon, this.text);
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: Colors.grey.shade400),
    const SizedBox(width: 4),
    Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
  ]);
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
    ]),
  );
}
