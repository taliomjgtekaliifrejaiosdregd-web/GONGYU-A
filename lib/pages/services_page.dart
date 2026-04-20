import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('服务'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 服务入口
          Row(
            children: [
              _buildServiceCard(Icons.cleaning_services, '保洁服务', Color(0xFF00C853), '专业保洁，焕然一新'),
              SizedBox(width: 12),
              _buildServiceCard(Icons.local_shipping, '搬家服务', Color(0xFFFF6D00), '省心搬家，轻松入住'),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildServiceCard(Icons.build, '维修服务', Color(0xFF2196F3), '快速上门，专业可靠'),
              SizedBox(width: 12),
              _buildServiceCard(Icons.inventory_2, '物品存放', Color(0xFF9C27B0), '临时存储，按需计费'),
            ],
          ),
          SizedBox(height: 24),
          // 我的服务订单
          Text('我的服务订单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 48, color: Color(0xFFBDBDBD)),
                SizedBox(height: 12),
                Text('暂无服务订单', style: TextStyle(color: Color(0xFF757575))),
                SizedBox(height: 8),
                Text('登录后查看您的服务订单', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
          SizedBox(height: 24),
          // 服务保障
          Text('服务保障', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          _buildGuaranteeItem(Icons.verified, '品质保障', '专业团队，标准服务流程'),
          _buildGuaranteeItem(Icons.timer, '准时保障', '准时上门，超时赔付'),
          _buildGuaranteeItem(Icons.security, '安全保障', '实名认证，安心托付'),
          _buildGuaranteeItem(Icons.money_off, '满意保障', '不满意免费返工'),
        ],
      ),
    );
  }

  Widget _buildServiceCard(IconData icon, String title, Color color, String desc) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text(desc, style: TextStyle(fontSize: 11, color: Color(0xFF757575)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildGuaranteeItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF00C853), size: 20),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
              Text(desc, style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
            ],
          ),
        ],
      ),
    );
  }
}
