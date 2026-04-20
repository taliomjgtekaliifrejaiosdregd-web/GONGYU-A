import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gongyu_guanjia/core/constants/app_constants.dart';
import 'package:gongyu_guanjia/pages/login_page.dart';
import 'package:gongyu_guanjia/pages/admin/admin_users_page.dart';
import 'package:gongyu_guanjia/pages/admin/admin_orders_page.dart';
import 'package:gongyu_guanjia/pages/admin/admin_properties_page.dart';
import 'package:gongyu_guanjia/pages/admin/admin_finance_page.dart';
import 'package:gongyu_guanjia/pages/admin/admin_settings_page.dart';

// ============================================================
// 后台管理系统主页 - 底部导航 + 数据看板
// ============================================================
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _AdminDashboard(),
    const AdminUsersPage(),
    const AdminOrdersPage(),
    const AdminPropertiesPage(),
    const AdminFinancePage(),
    const AdminSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                _NavItem(Icons.dashboard_outlined, Icons.dashboard, '看板', 0),
                _NavItem(Icons.people_outline, Icons.people, '用户', 1),
                _NavItem(Icons.receipt_long_outlined, Icons.receipt_long, '订单', 2),
                _NavItem(Icons.home_work_outlined, Icons.home_work, '房源', 3),
                _NavItem(Icons.bar_chart_outlined, Icons.bar_chart, '财务', 4),
                _NavItem(Icons.settings_outlined, Icons.settings, '设置', 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _NavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? const Color(0xFF6366F1) : const Color(0xFF9E9E9E),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? const Color(0xFF6366F1) : const Color(0xFF9E9E9E),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 数据看板（默认首页）
// ============================================================
class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('智租SaaS · 后台管理', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('管理员控制台', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                const Text('欢迎回来，今日数据概览', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_getToday(), style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ])),
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          const Text('核心指标', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _StatCard(icon: Icons.people, label: '总用户数', value: '2,847', delta: '+12%', deltaUp: true, color: const Color(0xFF6366F1))),
            const SizedBox(width: 8),
            Expanded(child: _StatCard(icon: Icons.home_work, label: '房源总数', value: '186', delta: '+3', deltaUp: true, color: const Color(0xFF10B981))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _StatCard(icon: Icons.receipt_long, label: '本月订单', value: '534', delta: '+8%', deltaUp: true, color: const Color(0xFFF59E0B))),
            const SizedBox(width: 8),
            Expanded(child: _StatCard(icon: Icons.account_balance_wallet, label: '本月营收', value: '87.6万', delta: '+15%', deltaUp: true, color: const Color(0xFFEF4444))),
          ]),

          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: _StatCard(icon: Icons.check_circle, label: '已完成订单', value: '421', delta: '+23', deltaUp: true, color: const Color(0xFF10B981), compact: true)),
            const SizedBox(width: 8),
            Expanded(child: _StatCard(icon: Icons.pending, label: '处理中', value: '89', delta: '-5', deltaUp: false, color: const Color(0xFFF59E0B), compact: true)),
            const SizedBox(width: 8),
            Expanded(child: _StatCard(icon: Icons.cancel, label: '已退款', value: '24', delta: '-2', deltaUp: false, color: const Color(0xFFEF4444), compact: true)),
          ]),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('营收趋势（近7天）', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('+15.2%', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _TrendBar('周一', 42000, 87000),
                  _TrendBar('周二', 38000, 87000),
                  _TrendBar('周三', 55000, 87000),
                  _TrendBar('周四', 49000, 87000),
                  _TrendBar('周五', 62000, 87000),
                  _TrendBar('周六', 72000, 87000),
                  _TrendBar('周日', 68000, 87000),
                ]),
              ),
              const SizedBox(height: 8),
              Row(children: [
                _LegendDot(const Color(0xFF6366F1), '营收'),
                const SizedBox(width: 20),
                _LegendDot(const Color(0xFFE0E7FF), '目标'),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('用户分布', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _PieItem('房东', 156, const Color(0xFF6366F1)),
                  const SizedBox(height: 8),
                  _PieItem('租客', 2680, const Color(0xFF10B981)),
                  const SizedBox(height: 8),
                  _PieItem('管理员', 11, const Color(0xFFF59E0B)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('房源状态', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _PieItem('已出租', 142, const Color(0xFF10B981)),
                  const SizedBox(height: 8),
                  _PieItem('空置中', 31, const Color(0xFFF59E0B)),
                  const SizedBox(height: 8),
                  _PieItem('维护中', 13, const Color(0xFFEF4444)),
                ]),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('最新订单动态', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('查看全部', style: TextStyle(fontSize: 12))),
              ]),
              const SizedBox(height: 8),
              ..._recentOrders.map((o) => _OrderRow(avatar: o['avatar']!, title: o['title']!, sub: o['sub']!, amount: o['amount']!, status: o['status']!)),
            ]),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('系统告警', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('3条', style: TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
                ),
              ]),
              const SizedBox(height: 10),
              _AlertRow('房源「科技园公寓B栋302」电表离线超过24小时', '2026-04-17 09:15'),
              const SizedBox(height: 8),
              _AlertRow('用户「李四」账号出现异常登录，请核查', '2026-04-17 08:42'),
              const SizedBox(height: 8),
              _AlertRow('房源「华侨城花园A栋501」水表读数异常', '2026-04-16 22:30'),
            ]),
          ),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  String _getToday() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('退出登录'),
        content: const Text('确定要退出后台管理吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove(AppConstants.tokenKey);
              await prefs.remove(AppConstants.userRoleKey);
              await prefs.remove(AppConstants.userInfoKey);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('确定退出'),
          ),
        ],
      ),
    );
  }

  static const _recentOrders = [
    {'avatar': '张', 'title': '华侨城花园A栋501 · 4月房租', 'sub': '租客：张三', 'amount': '3,200', 'status': '待支付'},
    {'avatar': '王', 'title': '科技园公寓B栋302 · 押金', 'sub': '租客：王五', 'amount': '4,500', 'status': '已完成'},
    {'avatar': '李', 'title': '龙华公馆C栋201 · 续租', 'sub': '租客：李四', 'amount': '2,800', 'status': '处理中'},
    {'avatar': '陈', 'title': '南山花园D栋601 · 入住', 'sub': '租客：陈六', 'amount': '1,500', 'status': '已完成'},
  ];
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String delta;
  final bool deltaUp;
  final Color color;
  final bool compact;

  const _StatCard({required this.icon, required this.label, required this.value, required this.delta, required this.deltaUp, required this.color, this.compact = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(compact ? 12 : 14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: compact ? 28 : 32, height: compact ? 28 : 32, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: compact ? 16 : 18)),
      ]),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: compact ? 18 : 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: compact ? 11 : 12, color: const Color(0xFF9E9E9E))),
      if (!compact) ...[
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: (deltaUp ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(delta, style: TextStyle(fontSize: 10, color: deltaUp ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
        ),
      ],
    ]),
  );
}

class _TrendBar extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  const _TrendBar(this.label, this.value, this.max);

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: (value / max).clamp(0.1, 1.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
        ),
      ),
    ),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF9E9E9E))),
    Text('\k', style: const TextStyle(fontSize: 8, color: Color(0xFF6366F1))),
  ]));
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot(this.color, this.label);
  @override Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
  ]);
}

class _PieItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _PieItem(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF424242))),
    const Spacer(),
    Text('\人', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
  ]);
}

class _OrderRow extends StatelessWidget {
  final String avatar;
  final String title;
  final String sub;
  final String amount;
  final String status;

  const _OrderRow({required this.avatar, required this.title, required this.sub, required this.amount, required this.status});

  Color get _statusColor {
    switch (status) {
      case '已完成': return const Color(0xFF10B981);
      case '待支付': return const Color(0xFFF59E0B);
      case '处理中': return const Color(0xFF6366F1);
      default: return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
    child: Row(children: [
      CircleAvatar(radius: 16, backgroundColor: const Color(0xFF6366F1).withOpacity(0.1), child: Text(avatar, style: const TextStyle(fontSize: 11, color: Color(0xFF6366F1)))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('mount', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(status, style: TextStyle(fontSize: 10, color: _statusColor)),
        ),
      ]),
    ]),
  );
}

class _AlertRow extends StatelessWidget {
  final String text;
  final String time;
  const _AlertRow(this.text, this.time);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFFCA5A5).withOpacity(0.3)),
    ),
    child: Row(children: [
      const Text('!', style: TextStyle(fontSize: 14)),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 11))),
      Text(time, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
    ]),
  );
}
