import 'package:flutter/material.dart';

/// ============================================================
// 租客 - 帮助中心
/// ============================================================
class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('帮助中心', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // 搜索栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(children: [
              Icon(Icons.search, color: Colors.grey.shade400, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('搜索问题关键词', style: TextStyle(fontSize: 14, color: Colors.grey.shade400))),
            ]),
          ),
          const SizedBox(height: 16),

          // 常见问题分类
          _SectionTitle('租房相关'),
          _HelpCategory(
            icon: Icons.home, title: '如何找房看房', subtitle: '了解找房流程、看房预约、签约步骤',
            items: const [
              '如何搜索想要的房源？',
              '如何预约看房？',
              '看房需要费用吗？',
              '如何联系房东？',
            ],
          ),
          _HelpCategory(
            icon: Icons.receipt_long, title: '合同签约问题', subtitle: '电子合同、签署流程、合同变更',
            items: const [
              '电子合同具有法律效力吗？',
              '如何在线签署合同？',
              '合同到期如何续签？',
              '如何查看已签署的合同？',
            ],
          ),
          _HelpCategory(
            icon: Icons.payment, title: '租金与押金', subtitle: '缴纳方式、押金退还、逾期处理',
            items: const [
              '租金可以用哪些方式支付？',
              '押金什么时候可以退还？',
              '逾期未缴租金会怎样？',
              '如何申请租金减免？',
            ],
          ),
          _HelpCategory(
            icon: Icons.bolt, title: '水电煤缴费', subtitle: '充值缴费、账单查询、充值优惠',
            items: const [
              '如何查询水电用量？',
              '如何在线充值缴费？',
              '充值后多久到账？',
              '如何申请账单报销？',
            ],
          ),
          _HelpCategory(
            icon: Icons.lock, title: '门锁与安防', subtitle: '密码管理、临时密码、门锁异常',
            items: const [
              '如何修改门锁密码？',
              '临时密码如何使用？',
              '门锁离线了怎么办？',
              '如何添加多个开锁用户？',
            ],
          ),
          _HelpCategory(
            icon: Icons.build, title: '维修与报修', subtitle: '提交报修、处理进度、维修评价',
            items: const [
              '如何提交维修申请？',
              '报修后多久上门处理？',
              '维修费用由谁承担？',
              '如何对维修服务评价？',
            ],
          ),
          _HelpCategory(
            icon: Icons.local_shipping, title: '好物订单与快递', subtitle: '订单查询、物流追踪、退换货',
            items: const [
              '如何查看订单物流？',
              '商品坏了可以退换吗？',
              '快递寄到哪了？',
              '如何申请退款？',
            ],
          ),

          const SizedBox(height: 8),
          _SectionTitle('账号与安全'),
          _HelpCategory(
            icon: Icons.person, title: '账号与登录', subtitle: '登录问题、密码找回、账号注销',
            items: const [
              '忘记登录密码怎么办？',
              '如何更换绑定的手机号？',
              '账号可以注销吗？',
              '如何修改个人信息？',
            ],
          ),

          const SizedBox(height: 8),
          _SectionTitle('其他问题'),
          _HelpCategory(
            icon: Icons.feedback, title: '意见与建议', subtitle: '反馈问题、投诉建议、表扬鼓励',
            items: const [
              '如何反馈使用问题？',
              '投诉房东会有处理吗？',
              '可以表扬房东/室友吗？',
              '功能建议在哪里提？',
            ],
          ),

          const SizedBox(height: 8),
          // 联系客服
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.headset_mic, color: Color(0xFF6366F1), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('遇到问题未解决？', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('联系客服，获取人工帮助', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ])),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('联系客服'),
              ),
            ]),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
    child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
  );
}

class _HelpCategory extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> items;
  const _HelpCategory({required this.icon, required this.title, required this.subtitle, required this.items});

  void _showItems(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.3, maxChildSize: 0.9, expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: const Color(0xFF6366F1), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ])),
            ]),
            const SizedBox(height: 16),
            const Divider(),
            ...items.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item, style: const TextStyle(fontSize: 13)),
              trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFFBDBDBD)),
              onTap: () {
                Navigator.pop(ctx);
                _showAnswer(ctx, item);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showAnswer(BuildContext ctx, String question) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.help_outline, color: Color(0xFF6366F1), size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
            child: Text(
              '感谢您的问题！如需了解更多详情，请联系客服获取人工帮助，或拨打客服热线 400-123-4567。\n\n正常工作时间：周一至周五 9:00-18:00',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('我知道了'),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _showItems(context),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF6366F1), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ])),
        const Icon(Icons.chevron_right, size: 18, color: Color(0xFFBDBDBD)),
      ]),
    ),
  );
}
