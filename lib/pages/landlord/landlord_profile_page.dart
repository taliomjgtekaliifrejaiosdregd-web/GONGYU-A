// landlord_profile_page.dart - 房东个人中心
import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';
import 'package:gongyu_guanjia/pages/login_page.dart';

class LandlordProfilePage extends StatelessWidget {
  const LandlordProfilePage({super.key});

  @override Widget build(BuildContext context) {
    final user = MockService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        // ========== 顶部区域 ==========
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.primary,
          leading: const SizedBox(width: 48),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () => _showSettings(context),
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF3451D1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(children: [
                // 用户信息行
                Row(children: [
                  // 头像
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        user.name,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      // 未认证标签
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 12),
                          const SizedBox(width: 3),
                          Text('未认证', style: TextStyle(color: Colors.orange.shade700, fontSize: 11, fontWeight: FontWeight.w500)),
                        ]),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.phone,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                      ),
                    ]),
                  ),
                  // 右侧认证入口
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text('去认证', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ]),
              ]),
            ),
          ),
        ),

        SliverToBoxAdapter(child: Column(children: [
          const SizedBox(height: 16),

          // ========== 积分区 ==========
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(children: [
              // 积分图标
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF5722)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              // 积分信息
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('${user.points}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                    const Text(' 积分', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    '您已获得 ${user.points} 积分，可用于兑换商品或服务',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ]),
              ),
              // 查看明细
              Column(children: [
                GestureDetector(
                  onTap: () => _showPointsDetail(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('积分明细', style: TextStyle(fontSize: 11, color: Colors.orange.shade700, fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(height: 6),
                // 立即兑换按钮
                GestureDetector(
                  onTap: () => _showPointsMall(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF5722)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 12),
                      SizedBox(width: 3),
                      Text('立即兑换', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          // ========== 功能列表 ==========
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(children: [
              _MenuItem(
                icon: Icons.build,
                iconColor: const Color(0xFF6366F1),
                label: '报修管理',
                onTap: () => Navigator.pushNamed(context, '/repair-manage'),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.exit_to_app,
                iconColor: const Color(0xFFEF4444),
                label: '退租申请',
                onTap: () => Navigator.pushNamed(context, '/termination-manage'),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.notifications_active,
                iconColor: const Color(0xFFF59E0B),
                label: '异常提醒',
                onTap: () => Navigator.pushNamed(context, '/alert'),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.person_outline,
                iconColor: const Color(0xFF6366F1),
                label: '房东设置',
                onTap: () => _showInfo(context),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.wifi_outlined,
                iconColor: const Color(0xFF06B6D4),
                label: '网络配置',
                onTap: () => _showInfo(context),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.help_outline,
                iconColor: const Color(0xFF10B981),
                label: '常见问题',
                onTap: () => _showInfo(context),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.menu_book_outlined,
                iconColor: const Color(0xFF8B5CF6),
                label: '操作指南',
                onTap: () => _showInfo(context),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.auto_stories_outlined,
                iconColor: const Color(0xFFEC4899),
                label: '智租操作指南',
                onTap: () => _showInfo(context),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.feedback_outlined,
                iconColor: const Color(0xFFF59E0B),
                label: '意见反馈',
                onTap: () => _showFeedback(context),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.info_outline,
                iconColor: const Color(0xFF6B7280),
                label: '关于我们',
                onTap: () => _showAbout(context),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.phone_outlined,
                iconColor: const Color(0xFFEF4444),
                label: '联系我们',
                onTap: () => _showContact(context),
                showBorder: false,
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // ========== 退出登录 ==========
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: ListTile(
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.logout, color: AppColors.danger, size: 20),
              ),
              title: const Text('退出登录', style: TextStyle(fontSize: 14, color: AppColors.danger)),
              trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.danger),
              onTap: () => _logout(context),
            ),
          ),

          const SizedBox(height: 32),
        ])),
      ]),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text('消息通知'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(leading: const Icon(Icons.security_outlined), title: const Text('账号安全'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(leading: const Icon(Icons.delete_outline), title: const Text('清理缓存'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(leading: const Icon(Icons.update), title: const Text('版本更新'), trailing: const Text('v1.0.0', style: TextStyle(color: Colors.grey)), onTap: () {}),
        ]),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('详情', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Center(child: Icon(Icons.construction, size: 48, color: Colors.grey)),
          const SizedBox(height: 12),
          const Center(child: Text('功能开发中，敬请期待', style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  void _showPointsDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('积分明细', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _PointItem('完成房源发布', '2026-04-10', '+50'),
          const Divider(),
          _PointItem('收到租金', '2026-04-08', '+200'),
          const Divider(),
          _PointItem('每日签到', '2026-04-07', '+10'),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showPointsMall(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('积分商城', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Center(child: Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey)),
          const SizedBox(height: 12),
          const Center(child: Text('积分商城即将上线，敬请期待！', style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  void _showFeedback(BuildContext context) {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('意见反馈', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: textController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: '请输入您的宝贵意见...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('感谢您的反馈！')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('提交反馈'),
            ),
          ),
        ]),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF3451D1)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.home_work, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('智租SaaS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          const Text('专注于为房东提供一站式资产管理服务，\n让租房管理更简单、更高效。', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  void _showContact(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('联系我们', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF07C160).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF07C160), size: 20)),
            title: const Text('微信公众号'),
            subtitle: const Text('智租SaaS'),
            trailing: const Icon(Icons.chevron_right, size: 20),
          ),
          const Divider(),
          ListTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.phone_outlined, color: Colors.blue, size: 20)),
            title: const Text('客服热线'),
            subtitle: const Text('400-888-8888'),
            trailing: const Icon(Icons.chevron_right, size: 20),
          ),
          const Divider(),
          ListTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.email_outlined, color: Colors.orange, size: 20)),
            title: const Text('商务合作'),
            subtitle: const Text('business@zhizu.com'),
            trailing: const Icon(Icons.chevron_right, size: 20),
          ),
        ]),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账号吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final bool showBorder;
  const _MenuItem({required this.icon, required this.iconColor, required this.label, required this.onTap, this.showBorder = true});

  @override Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
      if (showBorder) const Divider(height: 1, indent: 56),
    ]);
  }
}

class _Divider extends StatelessWidget {
  @override Widget build(BuildContext context) => const Divider(height: 1, indent: 56);
}

class _PointItem extends StatelessWidget {
  final String title;
  final String date;
  final String points;
  const _PointItem(this.title, this.date, this.points);

  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 2),
            Text(date, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ]),
        ),
        Text(points, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
      ]),
    );
  }
}
