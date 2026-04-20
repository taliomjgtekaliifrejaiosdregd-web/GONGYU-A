with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# Find _PasswordTab boundaries
pwtab_start = data.find('class _PasswordTab')
pwtab_end = data.find('class _Stat', pwtab_start)

new_pwtab = '''class _PasswordTab extends StatelessWidget {
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
'''

if pwtab_start >= 0 and pwtab_end >= 0:
    data = data[:pwtab_start] + new_pwtab + data[pwtab_end:]
    print(f"Replaced _PasswordTab! New file size: {len(data)}")
else:
    print(f"Could not find boundaries: start={pwtab_start}, end={pwtab_end}")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
