import 'package:flutter/material.dart';

// ============================================================
// 后台管理 - 用户管理 + 权限分配
// ============================================================
class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});
  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _roleFilter = '全部';
  String _statusFilter = '全部';

  final List<String> _roles = ['全部', '房东', '租客', '管理员'];
  final List<String> _statuses = ['全部', '正常', '冻结', '待审核'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('用户管理', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(children: [
            // 搜索框
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: '搜索用户名/手机号/邮箱',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ),
            // Tab栏
            TabBar(
              controller: _tabController,
              isScrollable: false,
              labelColor: const Color(0xFF6366F1),
              unselectedLabelColor: const Color(0xFF9E9E9E),
              indicatorColor: const Color(0xFF6366F1),
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: const [
                Tab(text: '用户列表'),
                Tab(text: '角色权限'),
                Tab(text: '操作日志'),
              ],
            ),
          ]),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UserListTab(searchQuery: _searchQuery),
          const _RolePermissionTab(),
          const _OperationLogTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_user',
        onPressed: () => _showAddUser(context),
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
        label: const Text('添加用户', style: TextStyle(color: Colors.white, fontSize: 13)),
      ),
    );
  }

  void _showAddUser(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _AddUserSheet(onSave: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('用户添加成功'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
        );
      }),
    );
  }
}

// ============================================================
// Tab1：用户列表
// ============================================================
class _UserListTab extends StatefulWidget {
  final String searchQuery;
  const _UserListTab({required this.searchQuery});
  @override
  State<_UserListTab> createState() => _UserListTabState();
}

class _UserListTabState extends State<_UserListTab> {
  String _roleFilter = '全部';
  String _statusFilter = '全部';

  static const _users = [
    {'avatar': '张', 'name': '李明', 'phone': '13900000001', 'role': '房东', 'status': '正常', 'roomCount': '12', 'joinDate': '2024-03-15'},
    {'avatar': '王', 'name': '王芳', 'phone': '13800000001', 'role': '租客', 'status': '正常', 'roomCount': '-', 'joinDate': '2024-05-20'},
    {'avatar': '陈', 'name': '陈强', 'phone': '13700000001', 'role': '房东', 'status': '正常', 'roomCount': '8', 'joinDate': '2024-01-10'},
    {'avatar': '刘', 'name': '刘洋', 'phone': '13600000001', 'role': '租客', 'status': '冻结', 'roomCount': '-', 'joinDate': '2024-06-01'},
    {'avatar': '赵', 'name': '赵雪', 'phone': '13500000001', 'role': '房东', 'status': '正常', 'roomCount': '5', 'joinDate': '2024-02-28'},
    {'avatar': '孙', 'name': '孙鹏', 'phone': '13400000001', 'role': '管理员', 'status': '正常', 'roomCount': '-', 'joinDate': '2023-11-05'},
    {'avatar': '周', 'name': '周婷', 'phone': '13300000001', 'role': '租客', 'status': '待审核', 'roomCount': '-', 'joinDate': '2026-04-10'},
  ];

  List<Map<String, String>> get _filtered {
    return _users.where((u) {
      if (_roleFilter != '全部' && u['role'] != _roleFilter) return false;
      if (_statusFilter != '全部' && u['status'] != _statusFilter) return false;
      if (widget.searchQuery.isNotEmpty) {
        final q = widget.searchQuery.toLowerCase();
        return u['name']!.toLowerCase().contains(q) || u['phone']!.contains(q);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(children: [
      // 筛选栏
      Container(
        padding: const EdgeInsets.all(12),
        color: Colors.white,
        child: Row(children: [
          _FilterChip(label: '角色：$_roleFilter', onTap: () => _showRoleFilter(context)),
          const SizedBox(width: 8),
          _FilterChip(label: '状态：$_statusFilter', onTap: () => _showStatusFilter(context)),
          const Spacer(),
          Text('${filtered.length}人', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        ]),
      ),
      // 用户列表
      Expanded(
        child: filtered.isEmpty
            ? const Center(child: Text('没有找到符合条件的用户', style: TextStyle(color: Color(0xFF9E9E9E))))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                itemBuilder: (_, i) => _UserCard(
                  user: filtered[i],
                  onEdit: () => _editUser(context, filtered[i]),
                  onPermission: () => _assignPermission(context, filtered[i]),
                  onAction: (action) => _handleAction(context, filtered[i], action),
                ),
              ),
      ),
    ]);
  }

  void _showRoleFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(padding: EdgeInsets.all(16), child: Text('选择角色', style: TextStyle(fontWeight: FontWeight.bold))),
        ...['全部', '房东', '租客', '管理员'].map((r) => ListTile(
          title: Text(r),
          trailing: _roleFilter == r ? const Icon(Icons.check, color: Color(0xFF6366F1)) : null,
          onTap: () { setState(() => _roleFilter = r); Navigator.pop(context); },
        )),
        const SizedBox(height: 8),
      ]),
    );
  }

  void _showStatusFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(padding: EdgeInsets.all(16), child: Text('选择状态', style: TextStyle(fontWeight: FontWeight.bold))),
        ...['全部', '正常', '冻结', '待审核'].map((s) => ListTile(
          title: Text(s),
          trailing: _statusFilter == s ? const Icon(Icons.check, color: Color(0xFF6366F1)) : null,
          onTap: () { setState(() => _statusFilter = s); Navigator.pop(context); },
        )),
        const SizedBox(height: 8),
      ]),
    );
  }

  void _editUser(BuildContext context, Map<String, String> user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _AddUserSheet(user: user, onSave: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('用户信息已更新'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
        );
      }),
    );
  }

  void _assignPermission(BuildContext context, Map<String, String> user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _PermissionSheet(userName: user['name']!, userRole: user['role']!),
    );
  }

  void _handleAction(BuildContext context, Map<String, String> user, String action) {
    String msg;
    switch (action) {
      case 'freeze':
        msg = '已冻结用户「${user['name']}」';
        break;
      case 'unfreeze':
        msg = '已解冻用户「${user['name']}」';
        break;
      case 'delete':
        msg = '已删除用户「${user['name']}」';
        break;
      default:
        msg = '操作成功';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFF10B981)),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF0F0F5), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        const Icon(Icons.arrow_drop_down, size: 18),
      ]),
    ),
  );
}

class _UserCard extends StatelessWidget {
  final Map<String, String> user;
  final VoidCallback onEdit;
  final VoidCallback onPermission;
  final Function(String) onAction;

  const _UserCard({required this.user, required this.onEdit, required this.onPermission, required this.onAction});

  Color get _roleColor {
    switch (user['role']) {
      case '房东': return const Color(0xFF6366F1);
      case '租客': return const Color(0xFF10B981);
      case '管理员': return const Color(0xFFF59E0B);
      default: return const Color(0xFF9E9E9E);
    }
  }

  Color get _statusColor {
    switch (user['status']) {
      case '正常': return const Color(0xFF10B981);
      case '冻结': return const Color(0xFFEF4444);
      case '待审核': return const Color(0xFFF59E0B);
      default: return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Row(children: [
        CircleAvatar(radius: 22, backgroundColor: _roleColor.withOpacity(0.1), child: Text(user['avatar']!, style: TextStyle(fontSize: 14, color: _roleColor))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(user['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: _roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(user['role']!, style: TextStyle(fontSize: 10, color: _roleColor)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(user['phone']!, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(user['status']!, style: TextStyle(fontSize: 11, color: _statusColor)),
          ),
          if (user['role'] == '房东') ...[
            const SizedBox(height: 4),
            Text('${user['roomCount']}套', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          ],
        ]),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        if (user['status'] == '待审核')
          Expanded(child: _ActionBtn('通过审核', const Color(0xFF10B981), () => onAction('approve'))),
        if (user['status'] == '待审核') const SizedBox(width: 8),
        Expanded(child: _ActionBtn('编辑', const Color(0xFF6366F1), onEdit)),
        const SizedBox(width: 8),
        Expanded(child: _ActionBtn('权限', const Color(0xFFF59E0B), onPermission)),
        const SizedBox(width: 8),
        if (user['status'] == '正常')
          Expanded(child: _ActionBtn('冻结', const Color(0xFFEF4444), () => onAction('freeze'))),
        if (user['status'] == '冻结')
          Expanded(child: _ActionBtn('解冻', const Color(0xFF10B981), () => onAction('unfreeze'))),
      ]),
    ]),
  );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(this.label, this.color, this.onTap);
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Center(child: Text(label, style: TextStyle(fontSize: 12, color: color))),
    ),
  );
}

// ============================================================
// Tab2：角色权限配置
// ============================================================
class _RolePermissionTab extends StatelessWidget {
  const _RolePermissionTab();

  static const _roles = [
    {'name': '超级管理员', 'color': Color(0xFFEF4444), 'desc': '拥有系统所有权限，可管理所有角色', 'count': 2},
    {'name': '运营管理员', 'color': Color(0xFFF59E0B), 'desc': '负责日常运营管理，订单/用户/数据', 'count': 4},
    {'name': '财务管理员', 'color': Color(0xFF6366F1), 'desc': '财务相关操作，收支统计/账单管理', 'count': 2},
    {'name': '房东', 'color': Color(0xFF10B981), 'desc': '管理自己的房源、租客、账单', 'count': 156},
    {'name': '租客', 'color': Color(0xFF06B6D4), 'desc': '查看房源、缴纳账单、报修、门锁控制', 'count': 2680},
  ];

  static const _permissions = [
    {'module': '📊 数据看板', 'perms': ['查看数据', '导出报表', '数据删除']},
    {'module': '👥 用户管理', 'perms': ['查看用户', '编辑用户', '冻结用户', '删除用户', '分配角色']},
    {'module': '📋 订单管理', 'perms': ['查看订单', '处理订单', '退款操作', '订单导出']},
    {'module': '🏠 房源管理', 'perms': ['查看房源', '添加房源', '编辑房源', '删除房源', '上下架']},
    {'module': '💰 财务管理', 'perms': ['查看账单', '收款确认', '退款审核', '财务报表']},
    {'module': '🔧 设备管理', 'perms': ['查看设备', '设备绑定', '设备解绑', '远程控制']},
    {'module': '⚙️ 系统设置', 'perms': ['角色配置', '权限分配', '操作日志', '系统参数']},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 角色卡片
        const Text('👥 系统角色', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._roles.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: (r['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.shield, color: r['color'] as Color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(r['desc'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: (r['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text('${r['count']}人', style: TextStyle(fontSize: 12, color: r['color'] as Color)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 20),
          ]),
        )),

        const SizedBox(height: 20),

        // 权限矩阵
        Row(children: [
          const Text('🔐 权限配置矩阵', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('新建角色', style: TextStyle(fontSize: 12))),
        ]),
        const SizedBox(height: 10),

        // 角色行头
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(children: [
            const SizedBox(width: 120, child: Text('权限项', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            ...['超管', '运营', '财务'].map((r) => Expanded(child: Center(child: Text(r, style: TextStyle(fontSize: 11, color: const Color(0xFF6366F1), fontWeight: FontWeight.w600))))),
          ]),
        ),

        // 权限行
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)), border: Border.all(color: const Color(0xFFE0E0E0))),
          child: Column(children: [
            ..._permissions.asMap().entries.map((e) => Column(children: [
              if (e.key > 0) const Divider(height: 1),
              _PermRow(module: e.value['module'] as String, perms: e.value['perms'] as List<String>),
            ])),
          ]),
        ),

        const SizedBox(height: 20),
      ]),
    );
  }
}

class _PermRow extends StatefulWidget {
  final String module;
  final List<String> perms;
  const _PermRow({required this.module, required this.perms});

  @override
  State<_PermRow> createState() => _PermRowState();
}

class _PermRowState extends State<_PermRow> {
  bool _expanded = false;
  late List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _checked = List.generate(widget.perms.length, (i) => i < 2);
  }

  @override
  Widget build(BuildContext context) {
    final isSub = widget.module.length == 0;
    return Column(children: [
      InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            SizedBox(width: 120, child: Text(widget.module, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSub ? const Color(0xFF666) : const Color(0xFF333)))),
            ...List.generate(3, (i) => Expanded(child: Center(
              child: GestureDetector(
                onTap: () => setState(() => _checked[i] = !_checked[i]),
                child: Icon(_checked[i] ? Icons.check_circle : Icons.circle_outlined, size: 18, color: _checked[i] ? const Color(0xFF6366F1) : const Color(0xFFBDBDBD)),
              ),
            ))),
          ]),
        ),
      ),
      if (_expanded) ...widget.perms.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 12, 4),
        child: Row(children: [
          SizedBox(width: 96, child: Text(e.value, style: const TextStyle(fontSize: 11, color: Color(0xFF666)))),
          ...List.generate(3, (i) => Expanded(child: Center(
            child: GestureDetector(
              onTap: () => setState(() => _checked[i] = !_checked[i]),
              child: Icon(_checked[i] ? Icons.check_box : Icons.check_box_outline_blank, size: 16, color: _checked[i] ? const Color(0xFF6366F1) : const Color(0xFFBDBDBD)),
            ),
          ))),
        ]),
      )),
    ]);
  }
}

// ============================================================
// Tab3：操作日志
// ============================================================
class _OperationLogTab extends StatelessWidget {
  const _OperationLogTab();

  static const _logs = [
    {'user': '孙鹏', 'action': '添加用户「周婷」', 'target': '用户管理', 'time': '2026-04-17 12:30:15', 'ip': '192.168.1.101'},
    {'user': '孙鹏', 'action': '修改角色「房东」权限配置', 'target': '权限管理', 'time': '2026-04-17 11:45:02', 'ip': '192.168.1.101'},
    {'user': '管理员A', 'action': '审核通过租客「周婷」注册', 'target': '用户管理', 'time': '2026-04-17 10:20:33', 'ip': '192.168.1.102'},
    {'user': '孙鹏', 'action': '删除房源「科技园公寓B栋302」', 'target': '房源管理', 'time': '2026-04-16 16:05:47', 'ip': '192.168.1.101'},
    {'user': '财务B', 'action': '导出4月份财务报表', 'target': '财务管理', 'time': '2026-04-16 14:33:21', 'ip': '192.168.1.103'},
    {'user': '孙鹏', 'action': '冻结租客「刘洋」账号', 'target': '用户管理', 'time': '2026-04-16 09:15:08', 'ip': '192.168.1.101'},
    {'user': '运营C', 'action': '处理订单 #2026041603 退款', 'target': '订单管理', 'time': '2026-04-15 18:42:55', 'ip': '192.168.1.104'},
    {'user': '孙鹏', 'action': '创建角色「财务管理员」', 'target': '权限管理', 'time': '2026-04-15 11:22:10', 'ip': '192.168.1.101'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _logs.length,
      itemBuilder: (_, i) {
        final log = _logs[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.history, color: Color(0xFF6366F1), size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(log['action']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Row(children: [
                Text('操作人: ${log['user']}', style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                  child: Text(log['target']!, style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1))),
                ),
              ]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(log['time']!, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              const SizedBox(height: 2),
              Text(log['ip']!, style: const TextStyle(fontSize: 9, color: Color(0xFFBDBDBD))),
            ]),
          ]),
        );
      },
    );
  }
}

// ============================================================
// 添加/编辑用户表单
// ============================================================
class _AddUserSheet extends StatefulWidget {
  final Map<String, String>? user;
  final VoidCallback onSave;

  const _AddUserSheet({this.user, required this.onSave});

  @override
  State<_AddUserSheet> createState() => _AddUserSheetState();
}

class _AddUserSheetState extends State<_AddUserSheet> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _role = '租客';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.user?['phone'] ?? '');
    _emailController = TextEditingController();
    _role = widget.user?['role'] ?? '租客';
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.user != null ? '编辑用户' : '添加用户', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      TextField(controller: _nameController, decoration: const InputDecoration(labelText: '姓名', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _phoneController, keyboardType: TextInputType.phone, maxLength: 11, decoration: const InputDecoration(labelText: '手机号', border: OutlineInputBorder(), counterText: '')),
      const SizedBox(height: 12),
      TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: '邮箱（选填）', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _role,
        decoration: const InputDecoration(labelText: '角色', border: OutlineInputBorder()),
        items: ['房东', '租客', '管理员'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
        onChanged: (v) => setState(() => _role = v!),
      ),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('取消'))),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: widget.onSave,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            child: Text(widget.user != null ? '保存修改' : '确认添加'),
          ),
        ),
      ]),
    ]),
  );
}

// ============================================================
// 权限分配弹窗
// ============================================================
class _PermissionSheet extends StatefulWidget {
  final String userName;
  final String userRole;
  const _PermissionSheet({required this.userName, required this.userRole});

  @override
  State<_PermissionSheet> createState() => _PermissionSheetState();
}

class _PermissionSheetState extends State<_PermissionSheet> {
  final _perms = {
    '数据看板': [true, false, false],
    '用户管理': [false, false, false],
    '订单管理': [true, true, false],
    '房源管理': [false, false, false],
    '财务管理': [false, false, true],
    '设备管理': [false, true, false],
    '系统设置': [false, false, false],
  };

  String _role = '运营管理员';

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('分配权限给「${widget.userName}」', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Spacer(),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ]),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text('当前角色：${widget.userRole}', style: const TextStyle(fontSize: 12, color: Color(0xFFF59E0B))),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _role,
        decoration: const InputDecoration(labelText: '快速分配：选择权限模板', border: OutlineInputBorder()),
        items: ['超级管理员', '运营管理员', '财务管理员', '自定义'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
        onChanged: (v) => setState(() => _role = v!),
      ),
      const SizedBox(height: 16),
      const Text('权限明细', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      ..._perms.entries.map((e) => Row(children: [
        SizedBox(width: 80, child: Text(e.key, style: const TextStyle(fontSize: 12))),
        const Text('查看', style: TextStyle(fontSize: 11)),
        Checkbox(value: e.value[0], onChanged: (v) => setState(() => _perms[e.key]![0] = v!)),
        const Text('编辑', style: TextStyle(fontSize: 11)),
        Checkbox(value: e.value[1], onChanged: (v) => setState(() => _perms[e.key]![1] = v!)),
        const Text('删除', style: TextStyle(fontSize: 11)),
        Checkbox(value: e.value[2], onChanged: (v) => setState(() => _perms[e.key]![2] = v!)),
      ])),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('「${widget.userName}」权限已更新'), behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFF10B981)),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
          child: const Text('确认分配权限', style: TextStyle(color: Colors.white)),
        ),
      ),
    ]),
  );
}
