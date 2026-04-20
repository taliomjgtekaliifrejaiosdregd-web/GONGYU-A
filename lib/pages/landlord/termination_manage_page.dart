// ============================================================
// 房东端 - 退租申请管理页面
// ============================================================

import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

class TerminationManagePage extends StatefulWidget {
  const TerminationManagePage({super.key});

  @override
  State<TerminationManagePage> createState() => _TerminationManagePageState();
}

class _TerminationManagePageState extends State<TerminationManagePage> {
  List<Map<String, dynamic>> _terminations = [];

  @override
  void initState() {
    super.initState();
    _loadTerminations();
  }

  void _loadTerminations() {
    setState(() {
      _terminations = MockService.getTerminations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('退租申请管理', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _terminations.isEmpty ? _buildEmptyState() : _buildTerminationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('暂无退租申请', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildTerminationList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _terminations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _TerminationCard(
        termination: _terminations[index],
        onTap: () => _showDetailBottomSheet(_terminations[index]),
      ),
    );
  }

  void _showDetailBottomSheet(Map<String, dynamic> termination) {
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
                  _StatusBadge(status: termination['status'] as String),
                  const Spacer(),
                  Text(termination['id'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
              const SizedBox(height: 16),
              Text('退租申请', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _DetailRow('租客姓名', termination['tenantName'] as String),
              _DetailRow('房源', termination['roomTitle'] as String),
              _DetailRow('申请退租日期', termination['requestedDate'] as String),
              _DetailRow('提交时间', termination['time'] as String),
              const Divider(height: 24),
              const Text('退租原因', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(termination['reason'] as String, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
              const SizedBox(height: 24),
              if (termination['status'] == '待审核') ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          MockService.updateTerminationStatus(termination['id'] as String, '已拒绝');
                          Navigator.pop(context);
                          _loadTerminations();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已拒绝退租申请')));
                        },
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                        child: const Text('拒绝'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          MockService.updateTerminationStatus(termination['id'] as String, '已同意');
                          Navigator.pop(context);
                          _loadTerminations();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已同意退租申请')));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                        child: const Text('同意'),
                      ),
                    ),
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

class _TerminationCard extends StatelessWidget {
  final Map<String, dynamic> termination;
  final VoidCallback onTap;

  const _TerminationCard({required this.termination, required this.onTap});

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
                _StatusBadge(status: termination['status'] as String),
                const Spacer(),
                Text(termination['time'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(termination['tenantName'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.home_outlined, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Expanded(child: Text(termination['roomTitle'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text('申请退租: ${termination['requestedDate']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '原因: ${termination['reason']}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 1,
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
      case '待审核':
        return AppColors.warning;
      case '已同意':
        return AppColors.success;
      case '已拒绝':
        return AppColors.danger;
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
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
