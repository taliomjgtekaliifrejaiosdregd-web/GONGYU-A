import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/room.dart';
import 'package:gongyu_guanjia/models/contract.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

// ============================================================
// 房源合同详情页
// ============================================================
class RoomContractPage extends StatelessWidget {
  final Room room;
  const RoomContractPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    // 查找该房源的合同
    final contract = MockService.contracts.where((c) => c.roomId == room.id).firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('合同管理',
            style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            tooltip: '新建合同',
            onPressed: () => _showCreateContract(context),
          ),
        ],
      ),
      body: contract == null
          ? _NoContractView(room: room)
          : _ContractDetailView(room: room, contract: contract),
    );
  }

  void _showCreateContract(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.description, size: 48, color: Color(0xFF6366F1)),
          const SizedBox(height: 12),
          const Text('新建租赁合同', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('为「${room.title}」创建新的租赁合同', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('合同创建功能开发中'), behavior: SnackBarBehavior.floating),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('选择模板创建', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

class _NoContractView extends StatelessWidget {
  final Room room;
  const _NoContractView({required this.room});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('暂无合同', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('「${room.title}」还没有签署租赁合同', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showCreateHint(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('新建合同'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
            ),
          ]),
        ),
      ],
    ),
  );

  void _showCreateHint(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新建合同'),
        content: Text('是否为此房源「${room.title}」创建新的租赁合同？\n\n可选择腾讯电子签在线签署。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('合同创建功能开发中'), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('立即创建', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ContractDetailView extends StatelessWidget {
  final Room room;
  final Contract contract;
  const _ContractDetailView({required this.room, required this.contract});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        // 合同状态卡片
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: contract.status == ContractStatus.active
                  ? [const Color(0xFF10B981), const Color(0xFF059669)]
                  : contract.status == ContractStatus.expiring
                      ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                      : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.description, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(contract.contractNo, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(contract.statusLabel, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(contract.statusLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _StatItem('月租金', '¥${contract.rentAmount.toStringAsFixed(0)}')),
              Container(width: 1, height: 40, color: Colors.white30),
              Expanded(child: _StatItem('押金', '¥${contract.depositAmount.toStringAsFixed(0)}')),
              Container(width: 1, height: 40, color: Colors.white30),
              Expanded(child: _StatItem('剩余天数', '${contract.daysToExpire}天')),
            ]),
          ]),
        ),

        const SizedBox(height: 12),

        // 合同详情
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('合同信息', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _InfoRow('房源', room.title),
            _InfoRow('合同编号', contract.contractNo),
            _InfoRow('租客姓名', contract.tenantName),
            _InfoRow('租客电话', contract.tenantPhone ?? '—'),
            _InfoRow('起租日期', _formatDate(contract.startDate)),
            _InfoRow('到期日期', _formatDate(contract.endDate)),
            _InfoRow('当前版本', contract.contractVersion ?? 'V1.0'),
            _InfoRow('签订日期', _formatDate(contract.startDate)),
          ]),
        ),

        const SizedBox(height: 12),

        // 版本历史
        if (contract.versions != null && contract.versions!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('版本历史', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload, size: 14),
                  label: const Text('上传新版本'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary, visualDensity: VisualDensity.compact),
                ),
              ]),
              const SizedBox(height: 8),
              ...contract.versions!.map((v) => _VersionItem(version: v)),
            ]),
          ),
          const SizedBox(height: 12),
        ],

        // 操作按钮
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            _ActionBtn(
              icon: Icons.visibility,
              label: '查看合同全文',
              color: AppColors.primary,
              onTap: () => _showContractContent(context),
            ),
            const SizedBox(height: 10),
            _ActionBtn(
              icon: Icons.download,
              label: '下载合同 PDF',
              color: const Color(0xFF6366F1),
              onTap: () => _downloadContract(context),
            ),
            const SizedBox(height: 10),
            if (contract.status == ContractStatus.active) ...[
              _ActionBtn(
                icon: Icons.autorenew,
                label: '续签合同',
                color: const Color(0xFFF59E0B),
                onTap: () => _renewContract(context),
              ),
              const SizedBox(height: 10),
              _ActionBtn(
                icon: Icons.cancel_outlined,
                label: '终止合同',
                color: const Color(0xFFEF4444),
                onTap: () => _terminateContract(context),
              ),
            ],
          ]),
        ),

        const SizedBox(height: 40),
      ]),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _showContractContent(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, sc) => Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Text('合同全文预览', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(controller: sc, padding: const EdgeInsets.all(16), children: [
              const Text('租赁合同', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text('甲方（出租方）：智慧公寓管理平台', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              Text('乙方（承租方）：${contract.tenantName}  ${contract.tenantPhone ?? ""}', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              Text(
                '第一条 租赁标的\n'
                '甲方同意将位于「${room.title}」（${room.address}）出租给乙方使用。\n\n'
                '第二条 租赁期限\n'
                '自${_formatDate(contract.startDate)}起至${_formatDate(contract.endDate)}止，共计约${contract.daysToExpire}天。\n\n'
                '第三条 租金及支付方式\n'
                '月租金为人民币${contract.rentAmount}元，押金为${contract.depositAmount}元。'
                '租金应于每月5日前支付。\n\n'
                '第四条 双方权利与义务\n'
                '...（详细条款见正式合同文本）',
                style: const TextStyle(fontSize: 12, height: 1.8),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  void _downloadContract(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('合同下载功能开发中'), behavior: SnackBarBehavior.floating),
    );
  }

  void _renewContract(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('续签合同'),
        content: Text('是否与租客「${contract.tenantName}」续签合同？\n\n当前合同到期日：${_formatDate(contract.endDate)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('续签功能开发中'), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('立即续签', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _terminateContract(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('终止合同'),
        content: Text('确定要终止与「${contract.tenantName}」的租赁合同吗？此操作不可逆。', style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('合同已终止'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFFEF4444)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('确认终止', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
    const SizedBox(height: 2),
    Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
  ]);
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
    ]),
  );
}

class _VersionItem extends StatelessWidget {
  final ContractVersion version;
  const _VersionItem({required this.version});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(8),
      border: version.isCurrent == true
          ? Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3))
          : null,
    ),
    child: Row(children: [
      Icon(
        version.isLocked ? Icons.lock : Icons.edit_document,
        size: 18,
        color: version.isLocked ? const Color(0xFFF59E0B) : const Color(0xFF6366F1),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(version.version, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          if (version.isCurrent == true) ...[
            const SizedBox(width: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(4)), child: const Text('当前', style: TextStyle(fontSize: 9, color: Colors.white))),
          ],
        ]),
        const SizedBox(height: 2),
        Text(version.fileName ?? '未命名', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ])),
      if (!version.isLocked)
        IconButton(icon: const Icon(Icons.delete_outline, size: 18), color: Colors.grey, onPressed: () {}),
    ]),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
        const Spacer(),
        Icon(Icons.chevron_right, color: color.withValues(alpha: 0.4), size: 18),
      ]),
    ),
  );
}
