with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

orig_len = len(data)

# Fix 1: _QuickActions - replace the entire class
old_quick = """class _QuickActions extends StatelessWidget {
  final VoidCallback onChangePassword;

  const _QuickActions({required this.onChangePassword, required this.onChangePassword});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _ActionCard(
        icon: Icons.edit, title: '修改密码', subtitle: '修改6位开门密码',
        color: const Color(0xFF6366F1), onTap: onChangePassword)),
      
  }
}"""

new_quick = """class _QuickActions extends StatelessWidget {
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
}"""

if old_quick in data:
    data = data.replace(old_quick, new_quick)
    print("Fixed _QuickActions")
else:
    print("_QuickActions pattern not found")

# Fix 2: _PasswordTab - add closing ]); for the Row before the password list
# The broken pattern:
old_pw = "color: const Color(0xFF6366F1), onTap: onChangePassword)),\n                  // 当前有效密码列表"
new_pw = "color: const Color(0xFF6366F1), onTap: onChangePassword)),\n        ]);\n\n        // 当前有效密码列表"

if old_pw in data:
    data = data.replace(old_pw, new_pw)
    print("Fixed _PasswordTab Row")
else:
    print("_PasswordTab pattern not found")

print(f"Before: {orig_len}, After: {len(data)}")

with open(r'D:\Projects\gongyu_guanjia\lib\pages\tenant\lock_control_page.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
