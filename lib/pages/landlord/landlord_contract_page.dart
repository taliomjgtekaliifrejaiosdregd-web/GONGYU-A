import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/contract.dart';
import 'package:gongyu_guanjia/models/room.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';
import 'package:gongyu_guanjia/pages/landlord/create_contract_page.dart';
import 'package:gongyu_guanjia/pages/landlord/contract_version_sheet.dart';
import 'package:file_picker/file_picker.dart';

/// 合同状态枚举（扩展版）
enum ContractState {
  active('生效中', Color(0xFF10B981)),
  expiring('即将到期', Color(0xFFF59E0B)),
  expired('已过期', Color(0xFFEF4444)),
  pending('待签署', Color(0xFF6366F1)),
  terminated('已终止', Color(0xFF9E9E9E));

  final String label;
  final Color color;
  const ContractState(this.label, this.color);
}

/// ============================================================
// 房东端 - 合同管理
// ============================================================
class LandlordContractPage extends StatefulWidget {
  const LandlordContractPage({super.key});

  @override
  State<LandlordContractPage> createState() => _LandlordContractPageState();
}

class _LandlordContractPageState extends State<LandlordContractPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  // Mock合同数据
  final List<Contract> _contracts = MockService.contracts;

  // Mock历史合同
  final List<Contract> _history = [
    Contract(
      id: 6, contractNo: 'HT2023100001', roomId: 3,
      roomTitle: '前滩公寓',
      tenantName: '赵先生', tenantPhone: '13512345678',
      startDate: DateTime(2023, 10, 1), endDate: DateTime(2024, 3, 31),
      rentAmount: 4500, depositAmount: 9000,
      status: ContractStatus.expired, daysToExpire: -15,
    ),
    Contract(
      id: 7, contractNo: 'HT2023070001', roomId: 6,
      roomTitle: '新天地服务公寓',
      tenantName: '刘小姐', tenantPhone: '13887654321',
      startDate: DateTime(2023, 7, 1), endDate: DateTime(2024, 6, 30),
      rentAmount: 8500, depositAmount: 17000,
      status: ContractStatus.active, daysToExpire: 365,
    ),
  ];

  List<Contract> get _filtered {
    if (_currentTab == 0) return _contracts;
    if (_currentTab == 1) return _contracts.where((c) => c.status == ContractStatus.expiring).toList();
    if (_currentTab == 2) return _contracts.where((c) => c.status == ContractStatus.expired).toList();
    return _currentTab == 3 ? _history : _contracts;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    final activeCount = _contracts.where((c) => c.status == ContractStatus.active).length;
    final expiringCount = _contracts.where((c) => c.status == ContractStatus.expiring).length;
    final expiredCount = _contracts.where((c) => c.status == ContractStatus.expired).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('合同管理', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _showCreateContract(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF9E9E9E),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          isScrollable: false,
          tabs: [
            Tab(text: '全部($activeCount)'),
            Tab(text: '即将到期($expiringCount)'),
            Tab(text: '已过期($expiredCount)'),
            const Tab(text: '历史'),
          ],
        ),
      ),
      body: Column(children: [
        // 统计栏
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Row(children: [
            _StatBadge('生效中', '$activeCount', const Color(0xFF10B981)),
            const SizedBox(width: 16),
            _StatBadge('即将到期', '$expiringCount', const Color(0xFFF59E0B)),
            const SizedBox(width: 16),
            _StatBadge('已过期', '$expiredCount', const Color(0xFFEF4444)),
          ]),
        ),
        const Divider(height: 1),
        // 合同列表
        Expanded(
          child: _filtered.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('暂无合同', style: TextStyle(color: Colors.grey.shade500)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ContractCard(
                    contract: _filtered[i],
                    onTap: () => _showContractDetail(context, _filtered[i]),
                    onRenew: () => _showRenew(context, _filtered[i]),
                  ),
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateContract(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('新建合同', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showContractDetail(BuildContext context, Contract contract) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, sc) => Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.description, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(contract.roomTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(contract.contractNo, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 3),
                // 版本标签
                Row(children: [
                  _VersionBadge(version: contract.contractVersion, isLocked: contract.currentVersion?.isLocked ?? false),
                  const SizedBox(width: 6),
                  if (contract.hasFile)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.attachment, size: 10, color: Color(0xFF10B981)),
                        const SizedBox(width: 3),
                        Text(contract.currentVersion!.fileSizeLabel, style: const TextStyle(fontSize: 10, color: Color(0xFF10B981))),
                      ]),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Text('未上传', style: TextStyle(fontSize: 10, color: Color(0xFFF59E0B))),
                    ),
                ]),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _getStatus(contract).color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(_getStatus(contract).label, style: TextStyle(fontSize: 11, color: _getStatus(contract).color, fontWeight: FontWeight.w600)),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(controller: sc, padding: const EdgeInsets.all(16), children: [
              // 合同基本信息
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: _DetailStat('月租金', '¥${contract.rentAmount}', Colors.white)),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Expanded(child: _DetailStat('押金', '¥${contract.depositAmount}', Colors.white)),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Expanded(child: _DetailStat('合同状态', _getStatus(contract).label, Colors.white)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              _DetailRow('房源', contract.roomTitle),
              _DetailRow('租客', contract.tenantName),
              _DetailRow('联系电话', contract.tenantPhone),
              _DetailRow('合同编号', contract.contractNo),
              _DetailRow('起租日期', _formatDate(contract.startDate)),
              _DetailRow('到期日期', _formatDate(contract.endDate)),
              _DetailRow('剩余天数', contract.daysToExpire > 0 ? '${contract.daysToExpire}天' : '已过期'),
              const SizedBox(height: 16),

              // ===== 合同文件 & 版本操作 =====
              Row(children: [
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.cloud_upload_outlined,
                    label: '上传合同',
                    color: const Color(0xFF6366F1),
                    onTap: () => _showUploadContract(context, contract),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.history,
                    label: '版本历史${contract.versions.isNotEmpty ? ' (${contract.versions.length})' : ''}',
                    color: const Color(0xFF10B981),
                    onTap: () => _showVersionHistory(context, contract),
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // ===== 合同操作按钮 =====
              if (_getStatus(contract) != ContractState.terminated) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); _showRenew(context, contract); },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.autorenew),
                    label: const Text('发起续签'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showTerminate(context, contract),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger), padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('终止合同'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.print),
                    label: const Text('打印合同'),
                  ),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  ContractState _getStatus(Contract c) {
    if (c.status == ContractStatus.active) return ContractState.active;
    if (c.status == ContractStatus.expiring) return ContractState.expiring;
    if (c.status == ContractStatus.expired) return ContractState.expired;
    if (c.status == ContractStatus.pendingSign) return ContractState.pending;
    return ContractState.terminated;
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _showCreateContract(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateContractPage(),
        fullscreenDialog: true,
      ),
    );
  }

  void _showRenew(BuildContext context, Contract contract) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('发起续签'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
            child: Column(children: [
              Text(contract.roomTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('租客：${contract.tenantName}', style: const TextStyle(fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 12),
          const Text('将生成新的续签合同，等待租客确认签署。', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('续签合同已发送给租客，请等待确认'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('确认发起'),
          ),
        ],
      ),
    );
  }

  void _showTerminate(BuildContext context, Contract contract) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('终止合同'),
        content: const Text('确定要终止此合同吗？终止后将自动生成退租结算单。', style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('合同已终止，退租结算单已生成'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFFEF4444)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('确认终止'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 上传合同
  // ============================================================
  void _showUploadContract(BuildContext context, Contract contract) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _UploadContractSheet(
        contract: contract,
        onUploaded: (newVersion) {
          // 在实际项目中，这里会调用 API 更新合同版本
          // Mock: 更新当前合同的 currentVersion
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('合同「${newVersion.version}」上传成功！${newVersion.isLocked ? "（已自动锁定）" : "（未锁定，可继续编辑）"}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // 版本历史
  // ============================================================
  void _showVersionHistory(BuildContext context, Contract contract) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: ContractVersionSheet(
          contract: contract,
          onVersionChange: () => setState(() {}),
        ),
      ),
    );
  }
}

// ============================================================
// 合同版本徽章
// ============================================================
class _VersionBadge extends StatelessWidget {
  final String version;
  final bool isLocked;
  const _VersionBadge({required this.version, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFF10B981).withOpacity(0.12) : const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isLocked ? Icons.lock : Icons.edit_note, size: 11, color: isLocked ? const Color(0xFF10B981) : const Color(0xFF6366F1)),
        const SizedBox(width: 3),
        Text(version, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isLocked ? const Color(0xFF10B981) : const Color(0xFF6366F1))),
      ]),
    );
  }
}

// ============================================================
// 操作按钮（详情页内联）
// ============================================================
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  final Contract contract;
  final VoidCallback onTap;
  final VoidCallback onRenew;
  const _ContractCard({required this.contract, required this.onTap, required this.onRenew});

  ContractState _getStatus() {
    if (contract.status == ContractStatus.active) return ContractState.active;
    if (contract.status == ContractStatus.expiring) return ContractState.expiring;
    if (contract.status == ContractStatus.expired) return ContractState.expired;
    if (contract.status == ContractStatus.pendingSign) return ContractState.pending;
    return ContractState.terminated;
  }

  @override
  Widget build(BuildContext context) {
    final status = _getStatus();
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
              child: const Icon(Icons.description, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(contract.roomTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(contract.contractNo, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: status.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(status.label, style: TextStyle(fontSize: 11, color: status.color, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(children: [
            _InfoChip(Icons.person, contract.tenantName),
            const SizedBox(width: 8),
            _InfoChip(Icons.calendar_today, '到期${contract.daysToExpire > 0 ? '${contract.daysToExpire}天' : '已过期'}'),
            const Spacer(),
            if (status == ContractState.active || status == ContractState.expiring)
              GestureDetector(
                onTap: onRenew,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Text('续签', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                ),
              ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(14)),
                child: const Text('详情 →', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  const _StatBadge(this.label, this.count, this.color);
  @override Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    const SizedBox(width: 4),
    Text(count, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
  ]);
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip(this.icon, this.text);
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: Colors.grey.shade400),
    const SizedBox(width: 4),
    Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
  ]);
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DetailStat(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Column(children: [
    Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
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

// ============================================================
// 上传合同 Sheet
// ============================================================
class _UploadContractSheet extends StatefulWidget {
  final Contract contract;
  final Function(ContractVersion) onUploaded;

  const _UploadContractSheet({required this.contract, required this.onUploaded});

  @override
  State<_UploadContractSheet> createState() => _UploadContractSheetState();
}

class _UploadContractSheetState extends State<_UploadContractSheet> {
  bool _isUploading = false;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _autoLock = true;
  String _lockReason = '双方签署确认';
  String _versionHint = '';

  @override
  void initState() {
    super.initState();
    _versionHint = _getNextVersion();
  }

  String _getNextVersion() {
    // 计算下一个版本号：V1.0 → V1.1, V1.9 → V2.0
    final current = widget.contract.contractVersion; // "V1.2"
    final match = RegExp(r'V(\d+)\.(\d+)').firstMatch(current);
    if (match == null) return 'V1.0';
    int major = int.parse(match.group(1)!);
    int minor = int.parse(match.group(2)!);
    minor++;
    if (minor > 9) { minor = 0; major++; }
    return 'V$major.$minor';
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFileName = file.name;
          _selectedFileSize = file.size;
        });
      }
    } catch (e) {
      // file_picker 可能不可用，降级为手动输入
      _showManualFileInput();
    }
  }

  void _showManualFileInput() {
    final nameCtrl = TextEditingController(text: 'HT${widget.contract.contractNo}_${_versionHint}_合同.pdf');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('输入文件信息'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('请输入合同文件名（实际文件由后台上传）', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 12),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '文件名', hintText: '.pdf')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedFileName = nameCtrl.text.isEmpty ? '合同文件.pdf' : nameCtrl.text;
                _selectedFileSize = 256000; // mock 250KB
              });
              Navigator.pop(context);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpload() async {
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要上传的合同文件'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFFF59E0B)),
      );
      return;
    }

    setState(() => _isUploading = true);
    await Future.delayed(const Duration(seconds: 2)); // 模拟上传

    final newVersion = ContractVersion(
      id: 'v${DateTime.now().millisecondsSinceEpoch}',
      version: _versionHint,
      fileName: _selectedFileName,
      fileUrl: '/contracts/${widget.contract.contractNo}_$_versionHint.pdf',
      fileSize: _selectedFileSize,
      createdAt: DateTime.now(),
      isLocked: _autoLock,
      isCurrent: true,
      lockedBy: _autoLock ? '房东' : null,
      lockedReason: _autoLock ? _lockReason : null,
    );

    setState(() => _isUploading = false);
    Navigator.pop(context);
    widget.onUploaded(newVersion);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 标题
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.cloud_upload, color: Color(0xFF6366F1)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('上传合同', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(widget.contract.contractNo, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ]),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 20),

        // 当前版本提示
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 18, color: Color(0xFF9E9E9E)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '当前版本：${widget.contract.contractVersion}  →  将上传：$_versionHint',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // 文件选择区
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _selectedFileName != null
                  ? const Color(0xFF10B981).withOpacity(0.06)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedFileName != null
                    ? const Color(0xFF10B981).withOpacity(0.4)
                    : const Color(0xFFE0E0E0),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(children: [
              Icon(
                _selectedFileName != null ? Icons.check_circle : Icons.upload_file,
                size: 40,
                color: _selectedFileName != null ? const Color(0xFF10B981) : const Color(0xFFBDBDBD),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFileName ?? '点击选择 PDF / Word 文件',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: _selectedFileName != null ? FontWeight.w600 : FontWeight.normal,
                  color: _selectedFileName != null ? const Color(0xFF10B981) : Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              if (_selectedFileSize != null) ...[
                const SizedBox(height: 4),
                Text(_formatFileSize(_selectedFileSize!), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 16),

        // 锁定选项
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE0E0E0))),
          child: Column(children: [
            Row(children: [
              Icon(_autoLock ? Icons.lock : Icons.lock_open, size: 18, color: _autoLock ? const Color(0xFF10B981) : const Color(0xFF9E9E9E)),
              const SizedBox(width: 8),
              const Expanded(child: Text('上传后自动锁定此版本', style: TextStyle(fontSize: 13))),
              Switch(
                value: _autoLock,
                activeColor: const Color(0xFF10B981),
                onChanged: (v) => setState(() => _autoLock = v),
              ),
            ]),
            if (_autoLock) ...[
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: '锁定原因（如：双方签署确认）',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                ),
                style: const TextStyle(fontSize: 13),
                onChanged: (v) => _lockReason = v,
              ),
              const SizedBox(height: 6),
              Text('锁定后此版本将无法被修改或删除，确保合同文件不可篡改', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ]),
        ),
        const SizedBox(height: 20),

        // 上传按钮
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isUploading ? null : _handleUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            ),
            icon: _isUploading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.cloud_upload, color: Colors.white),
            label: Text(_isUploading ? '上传中...' : '确认上传 $_versionHint', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '支持 PDF、Word 格式，后台上传后文件自动关联',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ),
      ]),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}

