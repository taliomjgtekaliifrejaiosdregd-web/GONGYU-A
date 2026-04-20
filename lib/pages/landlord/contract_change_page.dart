import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

// ============================================================
// 合同变更管理页
// ============================================================
enum ContractChangeStatus { pending, approved, rejected }

class ContractChangeOrder {
  final String id;
  final String roomTitle;
  final String contractNo;
  final String tenantName;
  final String tenantPhone;
  final ContractChangeStatus status;
  final String applyDate;
  final ContractChangeType changeType;
  final String? changeContent; // 变更内容描述
  final String? originalValue;
  final String? newValue;
  final String? remark;

  const ContractChangeOrder({
    required this.id,
    required this.roomTitle,
    required this.contractNo,
    required this.tenantName,
    required this.tenantPhone,
    required this.status,
    required this.applyDate,
    required this.changeType,
    this.changeContent,
    this.originalValue,
    this.newValue,
    this.remark,
  });

  String get statusLabel {
    switch (status) {
      case ContractChangeStatus.pending: return '待审核';
      case ContractChangeStatus.approved: return '已同意';
      case ContractChangeStatus.rejected: return '已拒绝';
    }
  }

  Color get statusColor {
    switch (status) {
      case ContractChangeStatus.pending: return AppColors.warning;
      case ContractChangeStatus.approved: return const Color(0xFF10B981);
      case ContractChangeStatus.rejected: return AppColors.danger;
    }
  }

  String get changeTypeLabel {
    switch (changeType) {
      case ContractChangeType.rent: return '租金变更';
      case ContractChangeType.extend: return '续签';
      case ContractChangeType.room: return '换房';
      case ContractChangeType.tenant: return '换人';
      case ContractChangeType.other: return '其他';
    }
  }

  IconData get changeTypeIcon {
    switch (changeType) {
      case ContractChangeType.rent: return Icons.attach_money;
      case ContractChangeType.extend: return Icons.autorenew;
      case ContractChangeType.room: return Icons.swap_horiz;
      case ContractChangeType.tenant: return Icons.swap_horiz;
      case ContractChangeType.other: return Icons.edit_note;
    }
  }
}

enum ContractChangeType { rent, extend, room, tenant, other }

class ContractChangePage extends StatefulWidget {
  const ContractChangePage({super.key});
  @override
  State<ContractChangePage> createState() => _ContractChangePageState();
}

class _ContractChangePageState extends State<ContractChangePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  final List<ContractChangeOrder> _orders = [
    ContractChangeOrder(
      id: 'CC20260416001',
      roomTitle: '龙湖时代天街 1栋B单元 1201',
      contractNo: 'HT2024010001',
      tenantName: '张伟',
      tenantPhone: '138****5678',
      status: ContractChangeStatus.pending,
      applyDate: '2026-04-16',
      changeType: ContractChangeType.rent,
      changeContent: '请求减免下季度租金10%',
      originalValue: '¥5800/月',
      newValue: '¥5220/月',
    ),
    ContractChangeOrder(
      id: 'CC20260414002',
      roomTitle: '凯德天府 3栋A单元 801',
      contractNo: 'HT2024010003',
      tenantName: '李娜',
      tenantPhone: '136****9012',
      status: ContractChangeStatus.pending,
      applyDate: '2026-04-14',
      changeType: ContractChangeType.extend,
      changeContent: '合同即将到期，申请续签一年',
      originalValue: '2026-04-30 到期',
      newValue: '续签至 2027-04-30',
    ),
    ContractChangeOrder(
      id: 'CC20260412003',
      roomTitle: '世豪广场 5栋2单元 1502',
      contractNo: 'HT2024010005',
      tenantName: '王强',
      tenantPhone: '135****3456',
      status: ContractChangeStatus.pending,
      applyDate: '2026-04-12',
      changeType: ContractChangeType.room,
      changeContent: '因工作地点变动，申请换到同小区2栋801',
    ),
  ];

  int _getCountForTab(int idx) {
    switch (idx) {
      case 0: return _orders.where((o) => o.status == ContractChangeStatus.pending).length;
      case 1: return _orders.where((o) => o.status == ContractChangeStatus.approved).length;
      case 2: return _orders.where((o) => o.status == ContractChangeStatus.rejected).length;
      default: return _orders.length;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentTabIndex = _tabController.index);
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
        title: const Text('合同变更管理',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: '待审核(${_getCountForTab(0)})'),
            Tab(text: '已同意(${_getCountForTab(1)})'),
            Tab(text: '已拒绝(${_getCountForTab(2)})'),
            const Tab(text: '全部'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(4, (i) => _buildOrderList(i)),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Row(children: [
            _StatItem('待审核', _getCountForTab(0), AppColors.warning),
            const SizedBox(width: 16),
            _StatItem('已同意', _getCountForTab(1), const Color(0xFF10B981)),
            const SizedBox(width: 16),
            _StatItem('已拒绝', _getCountForTab(2), AppColors.danger),
            const Spacer(),
            _StatItem('全部', _orders.length, AppColors.primary),
          ]),
        ),
      ),
    );
  }

  Widget _buildOrderList(int tabIndex) {
    List<ContractChangeOrder> orders;
    switch (tabIndex) {
      case 0: orders = _orders.where((o) => o.status == ContractChangeStatus.pending).toList(); break;
      case 1: orders = _orders.where((o) => o.status == ContractChangeStatus.approved).toList(); break;
      case 2: orders = _orders.where((o) => o.status == ContractChangeStatus.rejected).toList(); break;
      default: orders = _orders;
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('暂无合同变更申请', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _ContractChangeCard(
        order: orders[i],
        onApprove: () => _handleApprove(orders[i]),
        onReject: () => _handleReject(orders[i]),
      ),
    );
  }

  void _handleApprove(ContractChangeOrder order) {
    setState(() {
      final idx = _orders.indexWhere((o) => o.id == order.id);
      if (idx >= 0) {
        _orders[idx] = ContractChangeOrder(
          id: order.id, roomTitle: order.roomTitle, contractNo: order.contractNo,
          tenantName: order.tenantName, tenantPhone: order.tenantPhone,
          status: ContractChangeStatus.approved, applyDate: order.applyDate,
          changeType: order.changeType, changeContent: order.changeContent,
          originalValue: order.originalValue, newValue: order.newValue,
        );
      }
    });
    _showSuccess('已同意合同变更申请');
  }

  void _handleReject(ContractChangeOrder order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('拒绝变更'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('确定要拒绝租客「${order.tenantName}」的合同变更申请吗？'),
          const SizedBox(height: 12),
          TextField(
            maxLines: 2,
            decoration: const InputDecoration(labelText: '拒绝原因', border: OutlineInputBorder()),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final idx = _orders.indexWhere((o) => o.id == order.id);
                if (idx >= 0) {
                  _orders[idx] = ContractChangeOrder(
                    id: order.id, roomTitle: order.roomTitle, contractNo: order.contractNo,
                    tenantName: order.tenantName, tenantPhone: order.tenantPhone,
                    status: ContractChangeStatus.rejected, applyDate: order.applyDate,
                    changeType: order.changeType, changeContent: order.changeContent,
                    originalValue: order.originalValue, newValue: order.newValue,
                  );
                }
              });
              _showSuccess('已拒绝合同变更申请');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('确认拒绝', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFF10B981)),
    );
  }
}

// ============================================================
// 卡片
// ============================================================
class _ContractChangeCard extends StatelessWidget {
  final ContractChangeOrder order;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ContractChangeCard({
    required this.order,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        // 头部
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _typeColor(order.changeType).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(order.changeTypeIcon, color: _typeColor(order.changeType), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order.changeTypeLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(order.roomTitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: order.statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(order.statusLabel, style: TextStyle(fontSize: 11, color: order.statusColor, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),

        // 租客信息
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          child: Row(children: [
            Icon(Icons.person_outline, size: 14, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(order.tenantName, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(width: 12),
            Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(order.applyDate, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(width: 12),
            Icon(Icons.tag, size: 12, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(order.contractNo, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ]),
        ),

        // 变更内容
        if (order.changeContent != null && order.changeContent!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('变更内容：${order.changeContent}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                if (order.originalValue != null && order.newValue != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(order.originalValue!, style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(order.newValue!, style: const TextStyle(fontSize: 11, color: Color(0xFF10B981))),
                    ),
                  ]),
                ],
              ]),
            ),
          ),

        // 操作按钮
        if (order.status == ContractChangeStatus.pending)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 8)),
                  child: const Text('同意变更', style: TextStyle(fontSize: 13, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                ),
                child: const Text('拒绝', style: TextStyle(fontSize: 13, color: Color(0xFFEF4444))),
              ),
            ]),
          )
        else
          const SizedBox(height: 12),
      ]),
    );
  }

  Color _typeColor(ContractChangeType type) {
    switch (type) {
      case ContractChangeType.rent: return const Color(0xFFF59E0B);
      case ContractChangeType.extend: return const Color(0xFF6366F1);
      case ContractChangeType.room: return const Color(0xFF10B981);
      case ContractChangeType.tenant: return const Color(0xFFEF4444);
      case ContractChangeType.other: return Colors.grey;
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatItem(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 8, height: 8,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
    ),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
    const SizedBox(width: 2),
    Text('$count', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
  ]);
}
