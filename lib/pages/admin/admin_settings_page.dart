import 'package:flutter/material.dart';

// ============================================================
// 后台管理 - 系统设置
// ============================================================
class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('系统设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 管理员信息卡
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('超级管理员', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('ID: admin_001 · 2023-11-05入职', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Text('超级权限', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ])),
            ]),
          ),

          const SizedBox(height: 16),

          // 权限管理
          const Text('🔐 权限管理', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _SettingsCard(
            items: [
              _SettingsItem(icon: Icons.shield, iconColor: const Color(0xFFEF4444), label: '角色权限配置', sub: '超级管理员/运营/财务', onTap: () {}),
              _SettingsItem(icon: Icons.person_add, iconColor: const Color(0xFF6366F1), label: '管理员账号管理', sub: '添加/编辑/冻结管理员', onTap: () {}),
              _SettingsItem(icon: Icons.key, iconColor: const Color(0xFFF59E0B), label: '密码策略设置', sub: '密码强度/有效期/历史记录', onTap: () {}),
              _SettingsItem(icon: Icons.login, iconColor: const Color(0xFF10B981), label: '登录日志', sub: '管理员登录记录查看', onTap: () {}),
            ],
          ),

          const SizedBox(height: 16),

          // 系统配置
          const Text('⚙️ 系统配置', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _SettingsCard(
            items: [
              _SettingsItem(icon: Icons.business, iconColor: const Color(0xFF6366F1), label: '平台信息设置', sub: '平台名称/Logo/联系方式', onTap: () {}),
              _SettingsItem(icon: Icons.notifications, iconColor: const Color(0xFFF59E0B), label: '通知推送配置', sub: '短信/邮件/站内信', onTap: () {}),
              _SettingsItem(icon: Icons.payments, iconColor: const Color(0xFF10B981), label: '支付通道配置', sub: '支付宝/微信/银行卡', onTap: () {}),
              _SettingsItem(icon: Icons.cloud_upload, iconColor: const Color(0xFF06B6D4), label: 'OSS存储配置', sub: '阿里云OSS Bucket设置', onTap: () {}),
              _SettingsItem(icon: Icons.api, iconColor: const Color(0xFF8B5CF6), label: 'API接口配置', sub: '后端服务地址/超时设置', onTap: () {}),
            ],
          ),

          const SizedBox(height: 16),

          // 安全设置
          const Text('🛡️ 安全设置', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _SettingsCard(
            items: [
              _SettingsItem(icon: Icons.security, iconColor: const Color(0xFFEF4444), label: '登录安全策略', sub: 'IP白名单/设备绑定', onTap: () {}),
              _SettingsItem(icon: Icons.history, iconColor: const Color(0xFF6366F1), label: '操作日志审计', sub: '所有管理员操作记录', onTap: () {}),
              _SettingsItem(icon: Icons.backup, iconColor: const Color(0xFF10B981), label: '数据备份配置', sub: '自动备份周期/目标存储', onTap: () {}),
              _SettingsItem(icon: Icons.warning, iconColor: const Color(0xFFF59E0B), label: '告警规则配置', sub: '设备离线/资金异常/账号风险', onTap: () {}),
            ],
          ),

          const SizedBox(height: 16),

          // 版本信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.info_outline, color: Color(0xFF6366F1), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('智租SaaS 管理后台', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('版本 v2.4.1 · Flutter 3.41.5', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('已是最新', style: TextStyle(fontSize: 11, color: Color(0xFF10B981))),
                ),
              ]),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(children: [
                _VersionItem(Icons.android, 'Android', 'v36'),
                _VersionItem(Icons.desktop_windows, 'Web', 'v2.4.1'),
                _VersionItem(Icons.cloud_done, '服务端', 'v1.8.2'),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          // 关于我们
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _AboutRow(Icons.help_outline, '帮助文档', '常见问题与使用指南'),
              const Divider(height: 20),
              _AboutRow(Icons.description, '用户协议', '平台服务条款'),
              const Divider(height: 20),
              _AboutRow(Icons.privacy_tip, '隐私政策', '数据保护与隐私声明'),
              const Divider(height: 20),
              _AboutRow(Icons.update, '检查更新', '当前已是最新版本'),
            ]),
          ),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(children: items.asMap().entries.map((e) => Column(children: [
      if (e.key > 0) const Divider(height: 1),
      e.value,
    ])).toList()),
  );
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _SettingsItem({required this.icon, required this.iconColor, required this.label, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
        ])),
        const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 18),
      ]),
    ),
  );
}

class _VersionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String version;
  const _VersionItem(this.icon, this.label, this.version);

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Icon(icon, color: const Color(0xFF9E9E9E), size: 20),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
    const SizedBox(height: 2),
    Text(version, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
  ]));
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  const _AboutRow(this.icon, this.label, this.sub);

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () {},
    child: Row(children: [
      Icon(icon, color: const Color(0xFF9E9E9E), size: 20),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
      ])),
      const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 18),
    ]),
  );
}
