import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/contract.dart';

// ============================================================
// 版本历史 Sheet（独立文件，避免复杂嵌套问题）
// ============================================================
class ContractVersionSheet extends StatefulWidget {
  final Contract contract;
  final VoidCallback onVersionChange;

  const ContractVersionSheet({super.key, required this.contract, required this.onVersionChange});

  @override
  State<ContractVersionSheet> createState() => _ContractVersionSheetState();
}

class _ContractVersionSheetState extends State<ContractVersionSheet> {
  late List<ContractVersion> _versions;

  @override
  void initState() {
    super.initState();
    _versions = List.from(widget.contract.versions);
    if (widget.contract.currentVersion != null &&
        !_versions.any((v) => v.id == widget.contract.currentVersion!.id)) {
      _versions.insert(0, widget.contract.currentVersion!);
    }
  }

  void _lockVersion(ContractVersion v) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('确认锁定版本'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
            child: Text('版本：${v.version}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          const Text('锁定后该版本将无法被修改或删除，是否确认？', style: TextStyle(fontSize: 12)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final idx = _versions.indexWhere((vv) => vv.id == v.id);
                if (idx >= 0) {
                  _versions[idx] = v.copyWith(isLocked: true, lockedBy: '房东', lockedReason: '手动锁定确认');
                }
              });
              Navigator.pop(context);
              widget.onVersionChange();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('版本 ${v.version} 已锁定'), behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFF10B981)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('确认锁定'),
          ),
        ],
      ),
    );
  }

  void _unlockVersion(ContractVersion v) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('解锁版本'),
        content: const Text('解锁后可重新上传该版本的合同文件。是否确认解锁？', style: TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final idx = _versions.indexWhere((vv) => vv.id == v.id);
                if (idx >= 0) {
                  _versions[idx] = v.copyWith(isLocked: false, lockedBy: null, lockedReason: null);
                }
              });
              Navigator.pop(context);
              widget.onVersionChange();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('版本 ${v.version} 已解锁'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('确认解锁'),
          ),
        ],
      ),
    );
  }

  void _setCurrent(ContractVersion v) {
    setState(() {
      _versions = _versions.map((vv) => vv.copyWith(isCurrent: vv.id == v.id)).toList();
    });
    widget.onVersionChange();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已切换为版本 ${v.version}'), behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFF6366F1)),
    );
  }

  void _showBackendUpload(ContractVersion v) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.admin_panel_settings, color: Color(0xFF6366F1), size: 20),
          const SizedBox(width: 8),
          const Text('后台上传'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('版本：${v.version}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💡 后台上传说明', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('• 管理员可在后台直接上传 PDF/Word 文件\n• 文件自动关联到当前版本\n• 上传后可立即预览或下载', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ]),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: '文件地址（URL）',
              hintText: 'https://cdn.example.com/contracts/...',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('文件上传成功（模拟）'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            child: const Text('确认上传'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 标题栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
          ),
          child: Row(children: [
            const Icon(Icons.history, color: Color(0xFF6366F1)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('版本历史', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(widget.contract.contractNo, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text('${_versions.length} 个版本', style: const TextStyle(fontSize: 11, color: Color(0xFF6366F1), fontWeight: FontWeight.w600)),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
        ),
        // 版本列表
        Expanded(
          child: _versions.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.history, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('暂无版本记录', style: TextStyle(color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Text('上传合同后将自动生成版本', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _versions.length,
                  itemBuilder: (ctx, i) {
                    final v = _versions[i];
                    return _VersionCardWidget(
                      version: v,
                      onLock: () => _lockVersion(v),
                      onUnlock: () => _unlockVersion(v),
                      onSetCurrent: () => _setCurrent(v),
                      onBackendUpload: () => _showBackendUpload(v),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ============================================================
// 单个版本卡片
// ============================================================
class _VersionCardWidget extends StatelessWidget {
  final ContractVersion version;
  final VoidCallback onLock;
  final VoidCallback onUnlock;
  final VoidCallback onSetCurrent;
  final VoidCallback onBackendUpload;

  const _VersionCardWidget({
    required this.version,
    required this.onLock,
    required this.onUnlock,
    required this.onSetCurrent,
    required this.onBackendUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: version.isCurrent
              ? const Color(0xFF6366F1).withOpacity(0.4)
              : version.isLocked
                  ? const Color(0xFF10B981).withOpacity(0.3)
                  : const Color(0xFFE0E0E0),
          width: version.isCurrent ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        // 顶部
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: version.isCurrent
                ? const Color(0xFF6366F1).withOpacity(0.06)
                : version.isLocked
                    ? const Color(0xFF10B981).withOpacity(0.05)
                    : const Color(0xFFF5F5F5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: version.isCurrent
                    ? const Color(0xFF6366F1)
                    : version.isLocked
                        ? const Color(0xFF10B981)
                        : const Color(0xFF9E9E9E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  version.version.replaceAll('V', ''),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('版本 ${version.version}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  if (version.isCurrent) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(8)),
                      child: const Text('当前', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                  if (version.isLocked) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(8)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.lock, size: 9, color: Colors.white),
                        SizedBox(width: 2),
                        Text('锁定', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(
                  '上传于 ${_fmtDate(version.createdAt)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                if (version.lockedBy != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '锁定人：${version.lockedBy}${version.lockedReason != null ? ' · ${version.lockedReason}' : ''}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                  ),
                ],
              ]),
            ),
            if (version.fileName != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE0E0E0))),
                child: Column(children: [
                  Icon(version.fileName!.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.description, size: 20, color: const Color(0xFFEF4444)),
                  if (version.fileSize != null) Text(version.fileSizeLabel, style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
                ]),
              ),
          ]),
        ),
        // 文件名
        if (version.fileName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
            child: Row(children: [
              Icon(Icons.insert_drive_file, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Expanded(
                child: Text(version.fileName!, style: TextStyle(fontSize: 12, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
        // 操作按钮
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: version.isLocked ? onUnlock : onLock,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: version.isLocked ? const Color(0xFFF5F5F5) : const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(version.isLocked ? Icons.lock_open : Icons.lock, size: 14, color: version.isLocked ? Colors.grey.shade400 : const Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    Text(version.isLocked ? '解锁' : '锁定', style: TextStyle(fontSize: 12, color: version.isLocked ? Colors.grey.shade400 : const Color(0xFF10B981), fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: version.isCurrent || version.isLocked ? null : onSetCurrent,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: version.isCurrent || version.isLocked ? const Color(0xFFF5F5F5) : const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check_circle, size: 14, color: version.isCurrent || version.isLocked ? Colors.grey.shade400 : const Color(0xFF6366F1)),
                    const SizedBox(width: 4),
                    Text(version.isCurrent ? '当前版本' : '设为当前', style: TextStyle(fontSize: 12, color: version.isCurrent || version.isLocked ? Colors.grey.shade400 : const Color(0xFF6366F1), fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: onBackendUpload,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.admin_panel_settings, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text('后台', style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
