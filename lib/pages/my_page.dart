import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gongyu_guanjia/core/constants/app_constants.dart';
import 'package:gongyu_guanjia/pages/login_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _isLoggedIn = false;
  String _userName = '';
  String _userRole = '';
  String _userPhone = '';

  // 收款码（房东可编辑）
  String _wechatQrUrl = '';
  String _alipayQrUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final role = prefs.getString(AppConstants.userRoleKey);
    final info = prefs.getString(AppConstants.userInfoKey);
    final wechatQr = prefs.getString('wechat_qr_url') ?? '';
    final alipayQr = prefs.getString('alipay_qr_url') ?? '';

    if (mounted) {
      setState(() {
        _isLoggedIn = token != null;
        _userRole = role ?? 'tenant';
        _wechatQrUrl = wechatQr;
        _alipayQrUrl = alipayQr;
        if (info != null) {
          // 简单解析
          if (info.contains('phone')) {
            final match = RegExp(r'"phone":"([^"]+)"').firstMatch(info);
            if (match != null) _userPhone = match.group(1) ?? '';
          }
        }
        _userName = _isLoggedIn ? (_userRole == 'landlord' ? '房东用户' : '租客用户') : '';
      });
    }
  }

  Future<void> _saveQrUrls() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wechat_qr_url', _wechatQrUrl);
    await prefs.setString('alipay_qr_url', _alipayQrUrl);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('收款码已保存'), behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // 顶部个人信息
          SliverAppBar(
            expandedHeight: 160,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF00C853),
            leading: const SizedBox(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00C853), Color(0xFF00873A)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _isLoggedIn ? null : _goLogin(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                child: Icon(_isLoggedIn ? Icons.person : Icons.person_outline, color: Colors.white, size: 28),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isLoggedIn ? _userName : '登录/注册',
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  if (_isLoggedIn)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
                                      child: Text(_userRole == 'landlord' ? '房东' : '租客', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                    ),
                                  if (!_isLoggedIn)
                                    const Text('登录享受更多服务', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings, color: Colors.white),
                              onPressed: () => _showSettings(),
                            ),
                          ],
                        ),
                        if (_isLoggedIn) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _StatItem(value: '3', label: '待处理'),
                              const SizedBox(width: 24),
                              _StatItem(value: '12', label: '已完成'),
                              const SizedBox(width: 24),
                              _StatItem(value: '5', label: '收藏'),
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

          // 功能列表
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // 订单管理
                  _SectionCard(
                    title: '订单管理',
                    icon: Icons.receipt_long,
                    children: [
                      _MenuRow(Icons.pending_actions, '待处理订单', '3', onTap: () => _showOrders('pending')),
                      _MenuRow(Icons.check_circle_outline, '已完成订单', '12', onTap: () => _showOrders('completed')),
                      _MenuRow(Icons.cancel_outlined, '已取消订单', '2', onTap: () => _showOrders('cancelled')),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 收藏与浏览
                  _SectionCard(
                    title: '收藏与浏览',
                    icon: Icons.favorite_outline,
                    children: [
                      _MenuRow(Icons.favorite, '我的收藏', '5', onTap: () => _showFavorites()),
                      _MenuRow(Icons.history, '浏览记录', '28', onTap: () => _showHistory()),
                      _MenuRow(Icons.visibility_off_outlined, '隐藏的房源', '0', onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 支付与收款（房东显示收款码）
                  _SectionCard(
                    title: _userRole == 'landlord' ? '收款设置' : '支付管理',
                    icon: Icons.account_balance_wallet,
                    children: [
                      if (_userRole == 'tenant') ...[
                        _MenuRow(Icons.payment, '支付记录', '', onTap: () => _showPayments()),
                        _MenuRow(Icons.credit_card, '绑定银行卡', '', onTap: () => _showTip('绑定银行卡')),
                        _MenuRow(Icons.receipt, '发票管理', '', onTap: () => _showTip('发票管理')),
                      ],
                      if (_userRole == 'landlord') ...[
                        _MenuRow(Icons.qr_code, '微信收款码', _wechatQrUrl.isNotEmpty ? '已设置' : '未设置', onTap: () => _editQrCode('wechat')),
                        _MenuRow(Icons.qr_code_2, '支付宝收款码', _alipayQrUrl.isNotEmpty ? '已设置' : '未设置', onTap: () => _editQrCode('alipay')),
                        _MenuRow(Icons.receipt, '收款记录', '', onTap: () => _showPayments()),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 联系与帮助
                  _SectionCard(
                    title: '联系与帮助',
                    icon: Icons.support_agent,
                    children: [
                      _MenuRow(Icons.chat_bubble_outline, '在线客服', '', onTap: () => _showTip('在线客服')),
                      _MenuRow(Icons.phone, '客服电话', '400-888-8888', onTap: () => _showTip('拨打客服电话')),
                      _MenuRow(Icons.help_outline, '帮助中心', '', onTap: () => _showTip('帮助中心')),
                      _MenuRow(Icons.feedback_outlined, '意见反馈', '', onTap: () => _showTip('意见反馈')),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 其他
                  _SectionCard(
                    title: '其他',
                    icon: Icons.more_horiz,
                    children: [
                      _MenuRow(Icons.info_outline, '关于我们', '', onTap: () => _showTip('关于我们')),
                      _MenuRow(Icons.privacy_tip_outlined, '隐私政策', '', onTap: () => _showTip('隐私政策')),
                      _MenuRow(Icons.share, '分享APP', '', onTap: () => _showTip('分享APP')),
                      if (_isLoggedIn)
                        _MenuRow(Icons.logout, '退出登录', '', color: Colors.red, onTap: () => _logout()),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())).then((_) => _loadUser());
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('深色模式'),
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('消息通知'),
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('语言设置'),
              trailing: const Text('简体中文', style: TextStyle(color: Color(0xFF9E9E9E))),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrders(String type) {
    final titles = {'pending': '待处理订单', 'completed': '已完成订单', 'cancelled': '已取消订单'};
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _OrderListPage(title: titles[type] ?? '订单'),
      ),
    );
  }

  void _showFavorites() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const _FavoritePage()));
  }

  void _showHistory() {
    _showTip('浏览记录');
  }

  void _showPayments() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const _PaymentPage()));
  }

  void _editQrCode(String type) {
    final controller = TextEditingController(text: type == 'wechat' ? _wechatQrUrl : _alipayQrUrl);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(type == 'wechat' ? '微信收款码' : '支付宝收款码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '输入收款码图片URL',
                helperText: '支持微信/支付宝收款码图片链接',
              ),
            ),
            const SizedBox(height: 12),
            const Text('提示：可在微信/支付宝中生成收款码，保存图片后上传到图床获取URL', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim();
              if (type == 'wechat') {
                setState(() => _wechatQrUrl = url);
              } else {
                setState(() => _alipayQrUrl = url);
              }
              _saveQrUrls();
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showTip(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$msg（演示中）'), behavior: SnackBarBehavior.floating));
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定退出当前账号？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove(AppConstants.tokenKey);
              await prefs.remove(AppConstants.userRoleKey);
              if (mounted) {
                Navigator.pop(context);
                _loadUser();
              }
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF00C853), size: 18),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final Color color;
  final VoidCallback? onTap;
  const _MenuRow(this.icon, this.title, this.badge, {this.color = const Color(0xFF424242), this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, style: TextStyle(fontSize: 14, color: color)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFFF5722).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(badge, style: const TextStyle(fontSize: 10, color: Color(0xFFFF5722), fontWeight: FontWeight.w500)),
            ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: const Color(0xFFBDBDBD), size: 18),
        ],
      ),
      onTap: onTap,
    );
  }
}

// ==================== 订单列表页 ====================
class _OrderListPage extends StatelessWidget {
  final String title;
  const _OrderListPage({required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 60, height: 60, decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.apartment, size: 28, color: const Color(0xFFBDBDBD))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('阳光公寓 ${index + 1}号楼', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text('浦东新区 · 一室一厅', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                          const SizedBox(height: 4),
                          Text('¥${2800 + index * 200}/月', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF00C853).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: const Text('已完成', style: TextStyle(fontSize: 11, color: Color(0xFF00C853))),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('订单号：20260413000${index + 1}', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                    const Spacer(),
                    OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF00C853), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)), child: const Text('查看详情', style: TextStyle(fontSize: 11))),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== 收藏页 ====================
class _FavoritePage extends StatelessWidget {
  const _FavoritePage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
            child: Row(
              children: [
                Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.apartment, size: 32, color: const Color(0xFFBDBDBD))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('阳光公寓 ${index + 1}号楼', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 4),
                      const Text('浦东新区 · 一室一厅', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                      const SizedBox(height: 4),
                      Text('¥${2800 + index * 200}/月', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.favorite, color: Colors.red), onPressed: () {}),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== 支付/收款记录页 ====================
class _PaymentPage extends StatelessWidget {
  const _PaymentPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收款记录'),
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF00C853).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.arrow_downward, color: const Color(0xFF00C853), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('租金收入 - 张${index + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      Text('2026-04-${(10 + index).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ),
                Text('+¥${2800 + index * 100}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF00C853))),
              ],
            ),
          );
        },
      ),
    );
  }
}
