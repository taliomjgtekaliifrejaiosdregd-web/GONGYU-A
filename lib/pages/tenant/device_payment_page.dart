import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/device.dart';

class DevicePaymentPage extends StatefulWidget {
  final Device device;
  final String tenantPhone;
  const DevicePaymentPage({super.key, required this.device, required this.tenantPhone});
  @override
  State<DevicePaymentPage> createState() => _DevicePaymentPageState();
}

class _DevicePaymentPageState extends State<DevicePaymentPage> {
  bool _isLoading = false;
  bool _paySuccess = false;
  double _customAmount = 0;
  String _selectedPayment = 'wechat'; // wechat | alipay | bankcard

  double get _unpaidAmount {
    if (widget.device.type == DeviceType.smartLock) return 0;
    return widget.device.monthCost;
  }

  String get _billPeriod {
    final now = DateTime.now();
    return '${now.year}年${now.month}月';
  }

  Color get _deviceColor {
    switch (widget.device.type) {
      case DeviceType.electricMeter: return const Color(0xFFF59E0B);
      case DeviceType.waterMeter: return const Color(0xFF06B6D4);
      case DeviceType.smartLock: return const Color(0xFF6366F1);
    }
  }

  IconData get _deviceIcon {
    switch (widget.device.type) {
      case DeviceType.electricMeter: return Icons.electric_bolt;
      case DeviceType.waterMeter: return Icons.water_drop;
      case DeviceType.smartLock: return Icons.lock;
    }
  }

  String get _deviceTypeLabel {
    switch (widget.device.type) {
      case DeviceType.electricMeter: return '电费';
      case DeviceType.waterMeter: return '水费';
      case DeviceType.smartLock: return '门锁';
    }
  }

  String get _unit {
    switch (widget.device.type) {
      case DeviceType.electricMeter: return 'kWh';
      case DeviceType.waterMeter: return 'm3';
      case DeviceType.smartLock: return '';
    }
  }

  List<Map<String, dynamic>> get _usageHistory {
    if (widget.device.type == DeviceType.smartLock) return [];
    final now = DateTime.now();
    return List.generate(6, (i) {
      final month = DateTime(now.year, now.month - i, 1);
      final base = widget.device.type == DeviceType.electricMeter ? 120.0 : 8.5;
      final variance = (i * 7 + 15) % 30;
      final usage = (base + variance * (i.isEven ? 1 : -1) * 0.5);
      return {'month': '${month.year}-${month.month.toString().padLeft(2, '0')}', 'usage': usage, 'cost': usage * 0.6};
    });
  }

  String _payLabel(String method) {
    switch (method) {
      case 'wechat': return '微信支付';
      case 'alipay': return '支付宝';
      case 'bankcard': return '银行卡';
      default: return '微信支付';
    }
  }

  Color _payColor(String method) {
    switch (method) {
      case 'wechat': return const Color(0xFF07C160);
      case 'alipay': return const Color(0xFF1677FF);
      case 'bankcard': return const Color(0xFF6366F1);
      default: return const Color(0xFF07C160);
    }
  }

  IconData _payIcon(String method) {
    switch (method) {
      case 'wechat': return Icons.chat_bubble;
      case 'alipay': return Icons.account_balance_wallet;
      case 'bankcard': return Icons.credit_card;
      default: return Icons.chat_bubble;
    }
  }

  void _payNow(double amount) async {
    setState(() => _isLoading = true);
    // 模拟唤起支付（实际项目接入微信/支付宝 SDK）
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _paySuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_paySuccess) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 56),
              ),
              const SizedBox(height: 20),
              const Text('支付成功', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                '¥${(_customAmount > 0 ? _customAmount : _unpaidAmount).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _deviceColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('返回', style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ],
          ),
        ),
      );
    }

    final statusColor = widget.device.status == DeviceStatus.online
        ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final statusText = widget.device.status == DeviceStatus.online
        ? '在线' : widget.device.status == DeviceStatus.warning ? '预警' : '离线';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: _deviceColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${_deviceTypeLabel}缴费', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildDeviceCard(statusColor, statusText),
            const SizedBox(height: 12),
            if (widget.device.type != DeviceType.smartLock) ...[
              _buildBillCard(),
              const SizedBox(height: 12),
              _buildUsageChart(),
              const SizedBox(height: 12),
              _buildAmountSelector(),
            ],
            if (widget.device.type == DeviceType.smartLock) ...[
              _buildLockCard(),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: widget.device.type != DeviceType.smartLock
          ? _buildBottomSheet()
          : null,
    );
  }

  Widget _buildDeviceCard(Color statusColor, String statusText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: _deviceColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(_deviceIcon, color: _deviceColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('${_deviceTypeLabel} ${widget.device.deviceNo}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: _deviceColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text('设备名称', style: TextStyle(fontSize: 10, color: _deviceColor, fontWeight: FontWeight.w500)),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text('绑定房源：${widget.device.roomTitle}', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                    Text('品牌型号：${widget.device.brand}', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(statusText, style: TextStyle(fontSize: 12, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem('当前读数', '${widget.device.currentReading} $_unit'),
              _StatItem('本月用量', '${widget.device.monthUsage.toStringAsFixed(1)} $_unit'),
              _StatItem('本月费用', '¥${widget.device.monthCost.toStringAsFixed(2)}', valueColor: const Color(0xFFEF4444)),
            ],
          ),
          if (widget.device.balance > 0)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Color(0xFFF59E0B), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '账户余额不足，当前余额 ¥${widget.device.balance.toStringAsFixed(2)}，建议及时充值以免停电/停水',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBillCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('本期账单', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                child: Text(_billPeriod, style: const TextStyle(fontSize: 11, color: Color(0xFFF59E0B))),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DetailRow('账单编号', 'BILL-2026${DateTime.now().month.toString().padLeft(2, '0')}-${widget.device.deviceNo}'),
          _DetailRow('费用期间', _billPeriod),
          _DetailRow('单价', widget.device.type == DeviceType.electricMeter ? '¥0.60/kWh' : '¥2.00/m3'),
          const Divider(height: 20),
          Row(
            children: [
              const SizedBox(width: 80, child: Text('应付金额', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)))),
              Expanded(
                child: Text(
                  '¥${_unpaidAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
          if (widget.device.balance > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const SizedBox(width: 80, child: Text('账户抵扣', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))),
                  Text('-¥${widget.device.balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Color(0xFF10B981))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUsageChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('近6个月用量趋势', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _usageHistory.reversed.map((item) {
                final maxVal = 200.0;
                final h = (item['usage'] / maxVal).clamp(0.05, 1.0);
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        '¥${(item['cost'] as double).toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 8, color: _deviceColor),
                      ),
                      const SizedBox(height: 2),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: h,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: _deviceColor.withValues(alpha: 0.7),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (item['month'] as String).substring(5),
                        style: const TextStyle(fontSize: 8, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('选择充值金额', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _AmountChip(label: '¥50', value: 50, selected: _customAmount == 50, color: _deviceColor, onTap: () => setState(() => _customAmount = 50)),
              _AmountChip(label: '¥100', value: 100, selected: _customAmount == 100, color: _deviceColor, onTap: () => setState(() => _customAmount = 100)),
              _AmountChip(label: '¥200', value: 200, selected: _customAmount == 200, color: _deviceColor, onTap: () => setState(() => _customAmount = 200)),
              _AmountChip(label: '¥500', value: 500, selected: _customAmount == 500, color: _deviceColor, onTap: () => setState(() => _customAmount = 500)),
              _AmountChip(label: '¥1000', value: 1000, selected: _customAmount == 1000, color: _deviceColor, onTap: () => setState(() => _customAmount = 1000)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('自定义金额', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => _customAmount = double.tryParse(v) ?? 0),
                    decoration: InputDecoration(
                      hintText: '输入金额',
                      hintStyle: const TextStyle(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLockCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.lock, color: _deviceColor, size: 64),
          const SizedBox(height: 12),
          Text(widget.device.roomTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('设备号：${widget.device.deviceNo}', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${widget.device.balance.toInt()}%',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                  ),
                  const Text('剩余电量', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${widget.device.currentReading.toInt()}%',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                  ),
                  const Text('门锁电量', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    final amount = _customAmount > 0 ? _customAmount : _unpaidAmount;
    final payColor = _payColor(_selectedPayment);
    final payIcon = _payIcon(_selectedPayment);
    final payLabel = _payLabel(_selectedPayment);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // 支付方式选择
          InkWell(
            onTap: () => _showPayMethodSheet(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: payColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(payIcon, color: payColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(payLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: payColor)),
                const Spacer(),
                Icon(Icons.expand_more, color: Colors.grey.shade400, size: 20),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          // 金额 + 支付按钮
          Row(children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('实付金额', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                Text(
                  '¥${amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _payNow(amount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: payColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('立即${payLabel}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  void _showPayMethodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('选择支付方式', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _PayMethodItem(
            method: 'wechat',
            icon: Icons.chat_bubble,
            color: const Color(0xFF07C160),
            label: '微信支付',
            hint: '推荐',
            isSelected: _selectedPayment == 'wechat',
            onTap: () { setState(() => _selectedPayment = 'wechat'); Navigator.pop(context); },
          ),
          const Divider(height: 1),
          _PayMethodItem(
            method: 'alipay',
            icon: Icons.account_balance_wallet,
            color: const Color(0xFF1677FF),
            label: '支付宝',
            hint: null,
            isSelected: _selectedPayment == 'alipay',
            onTap: () { setState(() => _selectedPayment = 'alipay'); Navigator.pop(context); },
          ),
          const Divider(height: 1),
          _PayMethodItem(
            method: 'bankcard',
            icon: Icons.credit_card,
            color: const Color(0xFF6366F1),
            label: '银行卡支付',
            hint: null,
            isSelected: _selectedPayment == 'bankcard',
            onTap: () { setState(() => _selectedPayment = 'bankcard'); Navigator.pop(context); },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _StatItem(this.label, this.value, {this.valueColor = const Color(0xFF424242)});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String label;
  final double value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _AmountChip({required this.label, required this.value, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? color : const Color(0xFF424242),
          ),
        ),
      ),
    );
  }
}


// ============================================================
// 支付方式选项
// ============================================================
class _PayMethodItem extends StatelessWidget {
  final String method;
  final IconData icon;
  final Color color;
  final String label;
  final String? hint;
  final bool isSelected;
  final VoidCallback onTap;

  const _PayMethodItem({
    required this.method,
    required this.icon,
    required this.color,
    required this.label,
    this.hint,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isSelected ? color : Colors.black87)),
                if (hint != null) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Color(0xFF07C160).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(hint!, style: TextStyle(fontSize: 10, color: Color(0xFF07C160), fontWeight: FontWeight.w600)),
                  ),
                ],
              ]),
              if (method == 'wechat')
                Text('微信安全支付，保障资金安全', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              if (method == 'alipay')
                Text('支付宝便捷支付，快速到账', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              if (method == 'bankcard')
                Text('支持主流银行储蓄卡/信用卡', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ]),
          ),
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : Colors.transparent,
              border: Border.all(color: isSelected ? color : Color(0xFFBDBDBD), width: 1.5),
            ),
            child: isSelected
                ? Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ]),
      ),
    );
  }
}
