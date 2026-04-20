// ============================================================
// 智租SaaS - 主入口与路由配置
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/app_theme.dart';
import 'services/oss_service.dart';
import 'core/constants/app_constants.dart';
import 'pages/login_page.dart';
import 'pages/landlord/landlord_home.dart';
import 'pages/landlord/landlord_property_page.dart';
import 'pages/landlord/landlord_device_page.dart';
import 'pages/landlord/electric_analysis_page.dart';
import 'pages/landlord/landlord_profile_page.dart';
import 'pages/landlord/repair_manage_page.dart';
import 'pages/landlord/termination_manage_page.dart';
import 'pages/landlord/alert_page.dart';
import 'pages/tenant/tenant_home.dart';
import 'pages/tenant/rent_orders_page.dart';
import 'pages/tenant/goods_orders_page.dart';
import 'pages/tenant/my_favorites_page.dart';
import 'pages/tenant/browse_history_page.dart';
import 'pages/tenant/help_center_page.dart';
import 'pages/tenant/feedback_page.dart';
import 'pages/admin/admin_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 加载 .env 配置
  await dotenv.load(fileName: '.env');

  // 初始化 OSS 服务（可选，后端对接后启用）
  // initOss(
  //   accessKeyId: dotenv.env['ALIYUN_ACCESS_KEY_ID'] ?? '',
  //   accessKeySecret: dotenv.env['ALIYUN_ACCESS_KEY_SECRET'] ?? '',
  //   bucket: dotenv.env['ALIYUN_OSS_BUCKET'] ?? '',
  //   region: dotenv.env['ALIYUN_OSS_REGION'] ?? 'cn-shanghai',
  // );

  runApp(const ZhiZuApp());
}

class ZhiZuApp extends StatelessWidget {
  const ZhiZuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '智租',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AppStartup(),  // 启动时检查登录态
      routes: {
        '/login': (_) => const LoginPage(),
        '/landlord': (_) => const LandlordHomeWrapper(),
        '/electric-analysis': (_) => const ElectricAnalysisPage(),
        '/tenant': (_) => const TenantHomePage(),
        '/rent-orders': (_) => const RentOrdersPage(),
        '/goods-orders': (_) => const GoodsOrdersPage(),
        '/my-favorites': (_) => const MyFavoritesPage(),
        '/browse-history': (_) => const BrowseHistoryPage(),
        '/help-center': (_) => const HelpCenterPage(),
        '/feedback': (_) => const FeedbackPage(),
        '/repair-manage': (_) => const RepairManagePage(),
        '/termination-manage': (_) => const TerminationManagePage(),
        '/alert': (_) => const AlertPage(),
      },
    );
  }
}

/// 启动页：检查登录态 → 跳转对应首页或登录页
class _AppStartup extends StatefulWidget {
  const _AppStartup();
  @override
  State<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<_AppStartup> {
  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 600)); // 短暂启动动画

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final role = prefs.getString(AppConstants.userRoleKey);

    if (!mounted) return;

    Widget target;
    if (token != null && token.isNotEmpty) {
      // 已登录 → 根据角色跳转对应首页
      if (role == 'landlord') {
        target = const LandlordHomeWrapper();
      } else if (role == 'admin') {
        target = const AdminHomePage();
      } else {
        target = const TenantHomePage();
      }
    } else {
      // 未登录 → 去登录页
      target = const LoginPage();
    }

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => target), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6366F1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: const Icon(Icons.apartment, color: Color(0xFF6366F1), size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              '智租',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              '品质租房 · 轻松生活',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// 房东端底部导航包装器（4个Tab）
class LandlordHomeWrapper extends StatefulWidget {
  const LandlordHomeWrapper({super.key});
  @override
  State<LandlordHomeWrapper> createState() => _LandlordHomeWrapperState();
}

class _LandlordHomeWrapperState extends State<LandlordHomeWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    LandlordHomePage(),
    LandlordPropertyPage(),
    LandlordDevicePage(),
    LandlordProfilePage(),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _NavBarItem(Icons.home_outlined, Icons.home, '首页', 0),
                _NavBarItem(Icons.apartment_outlined, Icons.apartment, '房源', 1),
                _NavBarItem(Icons.developer_board_outlined, Icons.developer_board, '设备', 2),
                _NavBarItem(Icons.person_outline, Icons.person, '我的', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _NavBarItem(IconData icon, IconData activeIcon, String label, int index) {
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
              color: isActive ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.primary : AppColors.textHint,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
