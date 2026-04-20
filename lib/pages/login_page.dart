import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gongyu_guanjia/core/constants/app_constants.dart';
import 'package:gongyu_guanjia/pages/tenant/tenant_home.dart';
import 'package:gongyu_guanjia/pages/landlord/landlord_home.dart';
import 'package:gongyu_guanjia/pages/admin/admin_home.dart';

/// 统一登录页
/// 登录后根据手机号属性自动识别角色并跳转
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  int _countdown = 0;

  // ========== 演示模式：模拟后台用户角色配置 ==========
  // 真实场景：登录时请求后端 API，后端根据手机号查询用户角色并返回
  // 这里用 Map 模拟后端的"号码属性配置"
  static const _demoUserRoles = <String, String>{
    '13900000001': 'landlord', // 房东演示账号
    '13800000001': 'tenant',   // 租客演示账号
    '13700000001': 'landlord', // 房东演示账号
    '13600000001': 'tenant',   // 租客演示账号
    '13500000001': 'landlord', // 房东演示账号
    '18800000001': 'admin',    // 管理员演示账号 ← NEW
  };

  String? _detectRole(String phone) {
    // 演示模式：从本地配置读取角色
    // 真实场景：await api.login(phone, code) → { role: 'landlord'/'tenant' }
    return _demoUserRoles[phone] ?? 'tenant'; // 默认走租客端（可按需调整）
  }

  // ========== 发送验证码 ==========
  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 11) {
      _showSnackBar('请输入正确的11位手机号');
      return;
    }
    setState(() => _countdown = 60);
    _showSnackBar('验证码已发送（演示模式：任意6位数字）');
    for (int i = 60; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _countdown = i - 1);
    }
  }

  // ========== 登录主逻辑 ==========
  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    if (phone.length != 11) { _showSnackBar('请输入正确的手机号'); return; }
    if (code.isEmpty) { _showSnackBar('请输入验证码'); return; }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟查询用户角色（真实场景：调用后端 API）
    final role = _detectRole(phone) ?? 'tenant';

    // 保存登录态
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, 'demo_token_$phone');
    await prefs.setString(AppConstants.userRoleKey, role);
    await prefs.setString(AppConstants.userInfoKey, '{"phone":"$phone","role":"$role"}');

    if (!mounted) return;
    setState(() => _isLoading = false);

    // 根据角色自动跳转到对应首页
    if (role == 'landlord') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LandlordHomeWrapper()),
        (route) => false,
      );
    } else if (role == 'admin') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomePage()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TenantHomePage()),
        (route) => false,
      );
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF757575)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Logo
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: const Icon(Icons.apartment, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text('公寓管家', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
              ),
              Center(
                child: Text('品质租房 · 轻松生活', style: TextStyle(fontSize: 13, color: const Color(0xFF9E9E9E))),
              ),
              const SizedBox(height: 40),

              // 手机号
              Text('手机号', style: TextStyle(fontSize: 14, color: const Color(0xFF757575), fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: '请输入手机号',
                  hintStyle: TextStyle(color: const Color(0xFFBDBDBD)),
                  prefixIcon: Icon(Icons.phone_android, color: const Color(0xFF6366F1)),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF6366F1), width: 1.5)),
                ),
              ),
              const SizedBox(height: 16),

              // 验证码
              Text('验证码', style: TextStyle(fontSize: 14, color: const Color(0xFF757575), fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: '请输入验证码',
                        hintStyle: TextStyle(color: const Color(0xFFBDBBBD)),
                        prefixIcon: Icon(Icons.sms, color: const Color(0xFF6366F1)),
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF8F8F8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF6366F1), width: 1.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _countdown > 0 ? null : _sendCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _countdown > 0 ? const Color(0xFFF0F0F0) : const Color(0xFF6366F1),
                        foregroundColor: _countdown > 0 ? const Color(0xFF9E9E9E) : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_countdown > 0 ? '${_countdown}s' : '获取验证码', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 登录按钮
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    disabledBackgroundColor: const Color(0xFFB9F6CA),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('登录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),

              // 角色说明
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 15, color: Colors.grey.shade500),
                      const SizedBox(width: 8),
                      Text(
                        '登录后系统将根据您的账号类型自动跳转',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 演示账号提示
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.science, size: 14, color: Colors.indigo.shade400),
                    const SizedBox(width: 6),
                    Text('演示账号', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.indigo.shade400)),
                  ]),
                  const SizedBox(height: 8),
                  Text('房东测试号：13900000001、13700000001、13500000001', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text('租客测试号：13800000001、13600000001', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text('管理员测试号：18800000001', style: TextStyle(fontSize: 11, color: Colors.indigo.shade400)),
                  const SizedBox(height: 4),
                  Text('验证码：任意6位数字（如 123456）', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ]),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 11, color: const Color(0xFFBDBDBD)),
                    children: const [
                      TextSpan(text: '登录即表示同意'),
                      TextSpan(text: '《用户协议》', style: TextStyle(color: Color(0xFF6366F1))),
                      TextSpan(text: '和'),
                      TextSpan(text: '《隐私政策》', style: TextStyle(color: Color(0xFF6366F1))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
