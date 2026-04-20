// ============================================================
// 门锁控制页 - 完整版（对接 TuyaLockService）
// 包含：多门锁切换 / 远程开锁 / 密码管理 / 开锁记录 / 告警设置
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gongyu_guanjia/services/tuya_lock_service.dart';

class LockControlPage extends StatefulWidget {
  const LockControlPage({super.key});

  @override
  State<LockControlPage> createState() => _LockControlPageState();
}

class _LockControlPageState extends State<LockControlPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ===== 数据状态 =====
  List<LockStatus> _locks = [];
  int _selectedLockIndex = 0;
  LockStatus? _currentLock;
  List<LockUnlockRecord> _records = [];
  List<LockPassword> _passwords = [];
  bool _loadingLocks = false;
  bool _loadingRecords = false;
  bool _loadingPasswords = false;
  bool _isUnlocking = false;
  int _unlockCountdown = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await _loadLocks();
    if (_currentLock != null) {
      _loadRecords();
      _loadPasswords();
    }
  }

  Future<void> _loadLocks() async {
    setState(() => _loadingLocks = true);
    try {
      final locks = await TuyaLockService.getLocks('tenant_001');
      setState(() {
        _locks = locks;
        if (locks.isNotEmpty && _selectedLockIndex < locks.length) {
          _currentLock = locks[_selectedLockIndex];
        }
      });
    } catch (e) {
      _snack('获取门锁列表失败', error: true);
    } finally {
      setState(() => _loadingLocks = false);
    }
  }

  Future<void> _loadRecords() async {
    if (_currentLock == null) return;
    setState(() => _loadingRecords = true);
    try {
      final records = await TuyaLockService.getUnlockRecords(_currentLock!.lockId);
      setState(() => _records = records);
    } catch (_) {}
    setState(() => _loadingRecords = false);
  }

  Future<void> _loadPasswords() async {
    if (_currentLock == null) return;
    setState(() => _loadingPasswords = true);
    try {
      final passwords = await TuyaLockService.getPasswords(_currentLock!.lockId);
      setState(() => _passwords = passwords);
    } catch (_) {}
    setState(() => _loadingPasswords = false);
  }

  void _switchLock(int index) {
    setState(() {
      _selectedLockIndex = index;
      _currentLock = _locks[index];
    });
    _loadRecords();
    _loadPasswords();
  }

  Future<void> _doUnlock() async {
    if (_currentLock == null || _isUnlocking) return;
    if (!_currentLock!.isOnline) {
      _snack('门锁已离线，无法远程开锁', error: true);
      return;
    }

    setState(() => _isUnlocking = true);
    for (int i = 3; i > 0; i--) {
      setState(() => _unlockCountdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    try {
      final ok = await TuyaLockService.unlock(_currentLock!.lockId, method: UnlockMethod.remote);
      if (!mounted) return;
      _showResult(ok);
      if (ok) _loadRecords();
    } catch (_) {
      if (!mounted) return;
      _showResult(false);
    } finally {
      if (mounted) setState(() { _isUnlocking = false; _unlockCountdown = 0; });
    }
  }

  void _showResult(bool success) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            success ? Icons.lock_open : Icons.lock,
            size: 64,
            color: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          Text(
            success ? '开锁成功' : '开锁失败',
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold,
              color: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            success
                ? '请在30秒内开门，如门锁未响应请检查门锁状态'
                : '请检查网络连接或稍后重试',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('确定', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? const Color(0xFFEF4444) : const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('门锁控制', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _loadAll, tooltip: '刷新'),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF59E0B),
          labelColor: const Color(0xFFF59E0B),
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '开锁'),
            Tab(text: '密码管理'),
            Tab(text: '开锁记录'),
          ],
        ),
      ),
      body: _locks.isEmpty && !_loadingLocks
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('暂未绑定门锁', style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loadLocks,
                    child: const Text('点击刷新', style: TextStyle(color: Color(0xFF6366F1))),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _UnlockTab(
                  lock: _currentLock,
                  locks: _locks,
                  selectedIndex: _selectedLockIndex,
                  loading: _loadingLocks,
                  records: _records,
                  isUnlocking: _isUnlocking,
                  countdown: _unlockCountdown,
                  onSwitchLock: _switchLock,
                  onUnlock: _doUnlock,
                  onTabRecords: () => _tabController.animateTo(2),
                  onChangePassword: _showChangePasswordDialog,
                  onLoadRecords: _loadRecords,
                ),
                _PasswordTab(
                  passwords: _passwords,
                  loading: _loadingPasswords,
                  onDelete: _deletePassword,
                  onChangePassword: _showChangePasswordDialog,
                ),
                _RecordsTab(records: _records, loading: _loadingRecords),
              ],
            ),
    );
  }

  Future<void> _deletePassword(LockPassword pwd) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除密码'),
        content: const Text('确定删除此密码吗？删除后立即失效。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirmed == true && _currentLock != null) {
      try {
        await TuyaLockService.deletePassword(_currentLock!.lockId, pwd.id);
        _snack('密码已删除');
        _loadPasswords();
      } catch (e) {
        _snack('删除失败: $e', error: true);
      }
    }
  }

  void _showChangePasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.lock, size: 40, color: Color(0xFF6366F1)),
            const SizedBox(height: 12),
            const Text('修改开锁密码', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: oldCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: '原密码', hintText: '请输入原6位密码',
                prefixIcon: Icon(Icons.lock_outline), counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: '新密码', hintText: '请输入新6位密码',
                prefixIcon: Icon(Icons.lock), counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: '确认新密码', hintText: '再次输入新密码',
                prefixIcon: Icon(Icons.lock), counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (newCtrl.text.length != 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('密码必须为6位数字'), behavior: SnackBarBehavior.floating),
                    );
                    return;
                  }
                  if (newCtrl.text != confirmCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('两次密码不一致'), behavior: SnackBarBehavior.floating),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('密码修改成功'), behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF10B981)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('确认修改', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.month}月${d.day}日 ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

// ================================================================
// Tab 1: 开锁
// ================================================================
class _UnlockTab extends StatelessWidget {
  final LockStatus? lock;
  final List<LockStatus> locks;
  final int selectedIndex;
  final bool loading;
  final List<LockUnlockRecord> records;
  final bool isUnlocking;
  final int countdown;
  final Function(int) onSwitchLock;
  final VoidCallback onUnlock;
  final VoidCallback onTabRecords;
  final VoidCallback onChangePassword;
  final VoidCallback onLoadRecords;

  const _UnlockTab({
    required this.lock, required this.locks, required this.selectedIndex,
    required this.loading, required this.records, required this.isUnlocking,
    required this.countdown, required this.onSwitchLock, required this.onUnlock,
    required this.onTabRecords, required this.onChangePassword, required this.onLoadRecords,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        if (locks.length > 1) ...[_LockSelector(locks: locks, selectedIndex: selectedIndex, onChanged: onSwitchLock), const SizedBox(height: 12)],
        _StatusCard(lock: lock),
        const SizedBox(height: 16),
        _UnlockButton(lock: lock, isUnlocking: isUnlocking, countdown: countdown, onUnlock: onUnlock),
        const SizedBox(height: 16),
        _QuickMethods(lock: lock),
        const SizedBox(height: 16),
        _QuickActions(onChangePassword: onChangePassword),
        const SizedBox(height: 16),
        _RecentRecords(records: records, onViewAll: onTabRecords),
        const SizedBox(height: 16),
        _LockSettings(),
      ]),
    );
  }
}

class _LockSelector extends StatelessWidget {
  final List<LockStatus> locks;
  final int selectedIndex;
  final Function(int) onChanged;

  const _LockSelector({required this.locks, required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.home, size: 18, color: Color(0xFF6366F1)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedIndex,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              items: locks.asMap().entries.map((e) {
                final l = e.value;
                return DropdownMenuItem(value: e.key, child: Row(children: [
                  Expanded(child: Text(l.lockName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis)),
                  Container(width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: l.isOnline ? const Color(0xFF10B981) : Colors.grey,
                      shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('${l.batteryLevel}%', style: TextStyle(fontSize: 12,
                    color: l.batteryLevel < 20 ? const Color(0xFFEF4444) : Colors.grey.shade600)),
                ]));
              }).toList(),
              onChanged: (v) { if (v != null) onChanged(v); },
            ),
          ),
        ),
      ]),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final LockStatus? lock;

  const _StatusCard({required this.lock});

  Color get batteryColor {
    if (lock == null) return Colors.grey;
    if (lock!.batteryLevel < 20) return const Color(0xFFEF4444);
    if (lock!.batteryLevel < 50) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(children: [
        Row(children: [
          Container(width: 56, height: 56,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.lock, color: Color(0xFFF59E0B), size: 30)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lock?.lockName ?? '加载中...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              lock != null ? (lock!.isOnline ? '在线 · 已上锁' : '离线') : '获取门锁状态...',
              style: TextStyle(fontSize: 13,
                color: lock?.isOnline == true ? const Color(0xFF10B981) : Colors.grey.shade400)),
          ])),
          if (lock != null && lock!.alertCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFEF4444).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.warning_amber, color: Color(0xFFEF4444), size: 12),
                const SizedBox(width: 3),
                Text('${lock!.alertCount}条告警', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
              ]),
            ),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          _Chip(icon: Icons.battery_std, label: '电量', value: '${lock?.batteryLevel ?? '--'}%', color: batteryColor),
          const SizedBox(width: 12),
          _Chip(icon: Icons.wifi, label: '网络',
            value: lock?.isOnline == true ? '正常' : '断开',
            color: lock?.isOnline == true ? const Color(0xFF10B981) : Colors.grey),
          const SizedBox(width: 12),
          _Chip(icon: Icons.lock, label: '状态',
            value: lock?.isLocked == false ? '已开锁' : '已上锁',
            color: lock?.isLocked == false ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
        ]),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ]),
    ));
  }
}

class _UnlockButton extends StatelessWidget {
  final LockStatus? lock;
  final bool isUnlocking;
  final int countdown;
  final VoidCallback onUnlock;

  const _UnlockButton({required this.lock, required this.isUnlocking, required this.countdown, required this.onUnlock});

  bool get canUnlock => lock != null && lock!.isOnline && !isUnlocking;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        onTap: canUnlock ? onUnlock : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 160, height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isUnlocking
                ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight)
                : canUnlock
                    ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : const LinearGradient(colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: canUnlock
                ? [BoxShadow(color: Color(0xFF6366F1).withValues(alpha: 0.4),
                    blurRadius: 24, spreadRadius: 2, offset: const Offset(0, 8))]
                : null,
          ),
          child: Center(
            child: isUnlocking
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('$countdown', style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Text('开锁中', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  ])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(canUnlock ? Icons.lock_open : Icons.lock_outline, size: 40, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(canUnlock ? '点击开锁' : '门锁离线',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
          ),
        ),
      ),
      if (lock != null && !lock!.isOnline)
        Padding(padding: const EdgeInsets.only(top: 4),
          child: Text('门锁离线，请检查网络或电池', style: TextStyle(fontSize: 12, color: Colors.grey.shade500))),
      if (lock != null && lock!.batteryLevel < 20)
        Padding(padding: const EdgeInsets.only(top: 4),
          child: Text('电量低于20%，请及时更换电池', style: TextStyle(fontSize: 12, color: Colors.red.shade400))),
    ]);
  }
}

class _QuickMethods extends StatelessWidget {
  final LockStatus? lock;

  const _QuickMethods({required this.lock});

  @override
  Widget build(BuildContext context) {
    final methods = [
      ('密码', Icons.password, const Color(0xFF6366F1)),
      ('指纹', Icons.fingerprint, const Color(0xFF10B981)),
      ('门卡', Icons.credit_card, const Color(0xFFF59E0B)),
      ('NFC', Icons.phone_android, const Color(0xFF06B6D4)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('快捷开锁方式', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: methods.map((m) {
            return GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请使用实体门锁操作'), behavior: SnackBarBehavior.floating)),
              child: Column(children: [
                Container(width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: m.$3.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                  child: Icon(m.$2 as IconData, color: m.$3, size: 24)),
                const SizedBox(height: 6),
                Text(m.$1 as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
              ]),
            );
          }).toList()),
      ]),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onChangePassword;

  const _QuickActions({required this.onChangePassword});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _ActionCard(
        icon: Icons.edit, title: '修改密码', subtitle: '修改6位开门密码',
        color: const Color(0xFF6366F1), onTap: onChangePassword)),
    ]);
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ]),
      ),
    );
  }
}

class _RecentRecords extends StatelessWidget {
  final List<LockUnlockRecord> records;
  final VoidCallback onViewAll;

  const _RecentRecords({required this.records, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final recent = records.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('最近开锁记录', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          TextButton(onPressed: onViewAll,
            child: const Text('查看全部', style: TextStyle(fontSize: 12, color: Color(0xFF6366F1)))),
        ]),
        if (recent.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(16),
            child: Text('暂无开锁记录', style: TextStyle(color: Colors.grey.shade400))))
        else
          ...recent.map((r) => _RecordItem(record: r)),
      ]),
    );
  }
}

class _RecordItem extends StatelessWidget {
  final LockUnlockRecord record;
  const _RecordItem({required this.record});

  IconData get _icon {
    switch (record.method) {
      case UnlockMethod.password: return Icons.password;
      case UnlockMethod.fingerprint: return Icons.fingerprint;
      case UnlockMethod.icCard: return Icons.credit_card;
      case UnlockMethod.face: return Icons.face;
      case UnlockMethod.remote: return Icons.wifi;
    }
  }

  Color get _color {
    switch (record.method) {
      case UnlockMethod.remote: return const Color(0xFF06B6D4);
      case UnlockMethod.password: return const Color(0xFF6366F1);
      default: return const Color(0xFF10B981);
    }
  }

  String get _dateLabel {
    final now = DateTime.now();
    final diff = now.difference(record.time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${record.time.month}月${record.time.day}日';
  }

  @override
  Widget build(BuildContext context) {
    final successColor = record.success
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final bgColor = record.success
        ? const Color(0xFF10B981).withValues(alpha: 0.1)
        : const Color(0xFFEF4444).withValues(alpha: 0.1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
          child: Icon(_icon, color: _color, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(record.method.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(_dateLabel, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
          child: Text(
            record.success ? '成功' : '失败',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: successColor),
          ),
        ),
      ]),
    );
  }
}

class _LockSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('门锁设置', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _SettingsItem(icon: Icons.notifications_active, title: '开锁提醒', subtitle: '每次开锁发送通知',
          trailing: Switch(value: true, activeColor: const Color(0xFF6366F1),
            onChanged: (_) {})),
        _SettingsItem(icon: Icons.warning_amber, title: '低电量提醒', subtitle: '电量低于20%提醒',
          trailing: Switch(value: true, activeColor: const Color(0xFF6366F1),
            onChanged: (_) {})),
        _SettingsItem(icon: Icons.history, title: '异常开锁告警', subtitle: '密码连续错误等异常提醒',
          trailing: Switch(value: true, activeColor: const Color(0xFF6366F1),
            onChanged: (_) {})),
      ]),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsItem({required this.icon, required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(
            color: Color(0xFF6366F1).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF6366F1), size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ])),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

// ================================================================
// Tab 2: 密码管理
// ================================================================
class _PasswordTab extends StatelessWidget {
  final List<LockPassword> passwords;
  final bool loading;
  final Function(LockPassword) onDelete;
  final VoidCallback onChangePassword;

  const _PasswordTab({
    required this.passwords, required this.loading,
    required this.onDelete, required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    final active = passwords.where((p) => p.isActive).toList();
    final expired = passwords.where((p) => !p.isActive).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Expanded(child: Column(children: [
                Text('${active.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                const Text('有效密码', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ])),
              Container(width: 1, height: 40, color: Colors.white30),
              Expanded(child: Column(children: [
                Text('${expired.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                const Text('历史密码', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ])),
              Container(width: 1, height: 40, color: Colors.white30),
              Expanded(child: Column(children: [
                Text('${passwords.fold(0, (s, p) => s + p.usedCount)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                const Text('累计使用', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),
          // Action buttons
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: onChangePassword,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.edit, color: Color(0xFF6366F1), size: 18),
                  const SizedBox(width: 8),
                  const Text('修改密码', style: TextStyle(fontSize: 13, color: Color(0xFF6366F1), fontWeight: FontWeight.w600)),
                ]),
              ),
            )),
          ]),
          const SizedBox(height: 20),
          // Active passwords header
          const Text('当前有效密码', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (loading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (active.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text('暂无有效密码', style: TextStyle(color: Colors.grey.shade400))),
            )
          else
            ...active.map((p) => _PasswordCard(password: p, onDelete: () => onDelete(p))),
          // Expired passwords
          if (expired.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('历史失效密码', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            ...expired.map((p) => Opacity(opacity: 0.5, child: _PasswordCard(password: p, onDelete: null))),
          ],
        ],
      ),
    );
  }
}
class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
    ]));
  }
}

class _PasswordCard extends StatelessWidget {
  final LockPassword password;
  final VoidCallback? onDelete;

  const _PasswordCard({required this.password, this.onDelete});

  Color get typeColor =>
      password.type == PasswordType.permanent ? const Color(0xFF6366F1) : const Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: password.isActive ? Border.all(color: typeColor.withValues(alpha: 0.3)) : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6)),
            child: Text(password.type.label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: typeColor)),
          ),
          const SizedBox(width: 8),
          if (!password.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
              child: const Text('已失效', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
          const Spacer(),
          Text(password.password, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
            letterSpacing: 4, fontFamily: 'monospace')),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          if (password.type == PasswordType.temporary && password.validTo != null)
            Expanded(child: Text(
              '有效期至: ',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)))
          else if (password.maxUseCount != null)
            Expanded(child: Text(
              '剩余  次',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)))
          else
            Expanded(child: Text('已使用  次',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600))),
          if (onDelete != null && password.isActive)
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444))),
        ]),
      ]),
    );
  }

  String _fmtDt(DateTime d) =>
      '月日 :';
}

class _EmptyBox extends StatelessWidget {
  final String msg;
  const _EmptyBox({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(msg, style: TextStyle(color: Colors.grey.shade400))),
    );
  }
}

// ================================================================
// Tab 3: 开锁记录
// ================================================================
class _RecordsTab extends StatelessWidget {
  final List<LockUnlockRecord> records;
  final bool loading;

  const _RecordsTab({required this.records, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (records.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.history, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('暂无开锁记录', style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
        ]),
      );
    }

    // 按日期分组
    final grouped = <String, List<LockUnlockRecord>>{};
    for (var r in records) {
      final key = _dateLabel(r.time);
      grouped.putIfAbsent(key, () => []).add(r);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final date = grouped.keys.elementAt(i);
        final items = grouped[date]!;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(children: items.map((r) => _RecordItem(record: r)).toList()),
          ),
          const SizedBox(height: 8),
        ]);
      },
    );
  }

  String _dateLabel(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDay = DateTime(time.year, time.month, time.day);
    final diff = today.difference(recordDay).inDays;
    if (diff == 0) return '今天';
    if (diff == 1) return '昨天';
    if (diff < 7) return '';
    return '月日';
  }
}
