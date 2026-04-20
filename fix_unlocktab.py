with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

print(f"File size: {len(data)}")

# Find the _UnlockTab class and replace it entirely
idx = data.find('class _UnlockTab')
end_class = data.find('class _LockSelector', idx)

if idx >= 0 and end_class >= 0:
    new_unlock_tab = """class _UnlockTab extends StatelessWidget {
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

"""

    data = data[:idx] + new_unlock_tab + data[end_class:]
    print(f"Replaced _UnlockTab class! New size: {len(data)}")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
