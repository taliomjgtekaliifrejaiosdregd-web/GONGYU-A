// ============================================================
// 房东端 - 报修管理页面
// ============================================================

import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

class RepairManagePage extends StatefulWidget {
  const RepairManagePage({super.key});

  @override
  State<RepairManagePage> createState() => _RepairManagePageState();
}

class _RepairManagePageState extends State<RepairManagePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _repairs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRepairs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRepairs() {
    setState(() {
      _repairs = MockService.getRepairs();
    });
  }

  List<Map<String, dynamic>> _getRepairsByStatus(String status) {
    return _repairs.where((r) => r['status'] == status).toList();
  }

  int _getCount(String status) {
    return _repairs.where((r) => r['status'] == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('报修管理', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            _TabWithBadge(label: '待处理', count: _getCount('待处理')),
            _TabWithBadge(label: '处理中', count: _getCount('处理中')),
            _TabWithBadge(label: '已完成', count: _getCount('已完成')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRepairList('待处理'),
          _buildRepairList('处理中'),
          _buildRepairList('已完成'),
        ],
      ),
    );
  }

  Widget _buildRepairList(String status) {
    final repairs = _getRepairsByStatus(status);
    if (repairs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('暂无$status的报修', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: repairs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _RepairCard(
        repair: repairs[index],
        onTap: () => _showDetailBottomSheet(repairs[index]),
      ),
    );
  }

  void _showDetailBottomSheet(Map<String, dynamic> repair) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _StatusBadge(status: repair['status'] as String),
                  const Spacer(),
                  Text(repair['id'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
              const SizedBox(height: 16),
              Text(repair['title'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _DetailRow('租客', repair['tenantName'] as String),
              _DetailRow('房源', repair['roomTitle'] as String),
              _DetailRow('报修类型', repair['type'] as String),
              _DetailRow('提交时间', repair['time'] as String),
              const Divider(height: 24),
              const Text('问题描述', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(repair['description'] as String, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
              const SizedBox(height: 24),
              if (repair['status'] != '已完成') ...[
                const Divider(height: 24),
                Row(
                  children: [
                    if (repair['status'] == '待处理')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            MockService.updateRepairStatus(repair['id'] as String, '处理中');
                            Navigator.pop(context);
                            _loadRepairs();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已接单，开始处理')));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text('接单处理'),
                        ),
                      ),
                    if (repair['status'] == '处理中') ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            MockService.updateRepairStatus(repair['id'] as String, '待处理');
                            Navigator.pop(context);
                            _loadRepairs();
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.warning),
                          child: const Text('退回'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            MockService.updateRepairStatus(repair['id'] as String, '已完成');
                            Navigator.pop(context);
                            _loadRepairs();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('报修已标记为完成')));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          child: const Text('完成'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TabWithBadge extends StatelessWidget {
  final String label;
  final int count;

  const _TabWithBadge({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text('$count', style: const TextStyle(fontSize: 9, color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }
}

class _RepairCard extends StatelessWidget {
  final Map<String, dynamic> repair;
  final VoidCallback onTap;

  const _RepairCard({required this.repair, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusBadge(status: repair['status'] as String),
                const Spacer(),
                Text(repair['time'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 12),
            Text(repair['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(repair['tenantName'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(width: 16),
                Icon(Icons.home_outlined, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Expanded(child: Text(repair['roomTitle'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              repair['description'] as String,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color _getStatusColor(String status) {
    switch (status) {
      case '待处理':
        return AppColors.warning;
      case '处理中':
        return AppColors.primary;
      case '已完成':
        return AppColors.success;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
