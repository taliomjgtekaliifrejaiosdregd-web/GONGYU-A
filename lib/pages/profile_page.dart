import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gongyu_guanjia/core/constants/app_constants.dart';
import 'package:gongyu_guanjia/pages/login_page.dart';
import 'package:gongyu_guanjia/pages/tenant/repair_report_page.dart';
import 'package:gongyu_guanjia/pages/tenant/repair_list_page.dart';
import 'package:gongyu_guanjia/pages/tenant/bill_payment_page.dart';
import 'package:gongyu_guanjia/pages/tenant/lock_control_page.dart';
import 'package:gongyu_guanjia/pages/tenant/rent_orders_page.dart';
import 'package:gongyu_guanjia/pages/tenant/goods_orders_page.dart';
import 'package:gongyu_guanjia/pages/tenant/my_favorites_page.dart';
import 'package:gongyu_guanjia/pages/tenant/browse_history_page.dart';
import 'package:gongyu_guanjia/pages/tenant/help_center_page.dart';
import 'package:gongyu_guanjia/pages/tenant/feedback_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _phone;
  String _role = '租客';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final info = prefs.getString(AppConstants.userInfoKey);
    if (info != null) {
      // info is JSON like {"phone":"...","role":"..."}
      final phone = RegExp(r'"phone":"([^"]+)"').firstMatch(info)?.group(1);
      final role = RegExp(r'"role":"([^"]+)"').firstMatch(info)?.group(1);
      if (mounted) setState(() {
        _phone = phone;
        _role = role == 'landlord' ? '房东' : '租客';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _phone != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: CustomScrollView(
        slivers: [
          // 用户卡片
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF6366F1),
            leading: const SizedBox(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white.withOpacity(0.25),
                              child: Icon(Icons.person, size: 32, color: Colors.white),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: isLoggedIn
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('用户 ${_phone?.substring(0, 3)}****${_phone?.substring(7)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                          child: Text(_role, style: const TextStyle(color: Colors.white, fontSize: 9)),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('未登录', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        const Text('登录后享受更多服务', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                      ],
                                    ),
                            ),
                            if (isLoggedIn)
                              OutlinedButton(
                                onPressed: _logout,
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
                                child: const Text('退出', style: TextStyle(fontSize: 9)),
                              ),
                          ],
                        ),
                        if (isLoggedIn) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _StatBadge(Icons.favorite, '收藏', '12'),
                              const SizedBox(width: 16),
                              _StatBadge(Icons.history, '浏览', '38'),
                              const SizedBox(width: 16),
                              _StatBadge(Icons.star, '积分', '560'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 未登录提示
          if (!isLoggedIn)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF6366F1), size: 20),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('登录后查看完整订单和服务记录', style: TextStyle(fontSize: 10, color: Color(0xFF6366F1)))),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6)),
                      child: const Text('登录', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ),
            ),

          // 功能区
          SliverToBoxAdapter(child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text('订单服务', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              _MenuTile(Icons.receipt_long, '租房订单', '签约订单管理', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RentOrdersPage()))),
              _MenuTile(Icons.shopping_bag, '好物订单', '商品订单查询与售后', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoodsOrdersPage()))),
              _MenuTile(Icons.favorite_outline, '我的收藏', '收藏的房源和商品', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyFavoritesPage()))),
              _MenuTile(Icons.history, '浏览历史', '最近查看的房源', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BrowseHistoryPage()))),
            ]),
          )),

          SliverToBoxAdapter(child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text('预约记录', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              _MenuTile(Icons.build, '维修报修', '提交报修单、查看处理进度', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RepairReportPage()))),
              _MenuTile(Icons.list_alt, '我的报修', '查看报修记录和进度', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RepairListPage()))),
              _MenuTile(Icons.calendar_month, '看房预约', '预约记录与取消', () => _showLoginRequired(context)),
              _MenuTile(Icons.payment, '缴费记录', '租金/水电煤缴纳历史', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillPaymentPage()))),
              _MenuTile(Icons.message_outlined, '消息通知', '房东回复、系统通知', () => _showLoginRequired(context)),
            ]),
          )),

          SliverToBoxAdapter(child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text('更多服务', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              _MenuTile(Icons.help_outline, '帮助中心', '常见问题解答', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage()))),
              _MenuTile(Icons.feedback_outlined, '意见反馈', '您的建议是我们进步的动力', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackPage()))),
              _MenuTile(Icons.door_front_door, '门锁控制', '智能门锁远程开锁与密码管理', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LockControlPage()))),
              _MenuTile(Icons.info_outline, '关于我们', '公寓管家 v1.0.0', () {}),
              _MenuTile(Icons.settings_outlined, '设置', '账号安全与偏好设置', () {}),
            ]),
          )),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showLoginRequired(BuildContext context) {
    if (_phone != null) return; // already logged in
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.lock_outline, size: 48, color: Color(0xFF6366F1)),
          const SizedBox(height: 16),
          const Text('登录后使用此功能', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('稍后再说'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())); },
              child: const Text('立即登录'),
            )),
          ]),
        ]),
      ),
    );
  }

  void _goGoodsOrders(BuildContext context) {
    // 直接跳转到购物页订单tab
    Navigator.pushNamed(context, '/goods-orders');
  }

  void _goExpressPage(BuildContext context) {
    Navigator.pushNamed(context, '/express');
  }

  void _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定退出当前账号？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('确定', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userRoleKey);
      await prefs.remove(AppConstants.userInfoKey);
      setState(() => _phone = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已退出登录'), behavior: SnackBarBehavior.floating));
    }
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatBadge(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 12, color: Colors.white70),
    const SizedBox(width: 4),
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    const SizedBox(width: 2),
    Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9)),
  ]);
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuTile(this.icon, this.title, this.subtitle, this.onTap);

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    leading: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 18, color: const Color(0xFF6366F1)),
    ),
    title: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 9, color: Color(0xFF9E9E9E))),
    trailing: const Icon(Icons.chevron_right, size: 16, color: Color(0xFFBDBDBD)),
    onTap: onTap,
  );
}
