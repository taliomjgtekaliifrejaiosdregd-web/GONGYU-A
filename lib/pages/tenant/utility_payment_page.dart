import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/models/device.dart';
import 'package:gongyu_guanjia/models/room.dart';
import 'package:gongyu_guanjia/models/contract.dart';
import 'package:gongyu_guanjia/pages/tenant/device_payment_page.dart';

/// ============================================================
//  租客 - 二级：在线缴费（按设备类型分类 + 房租）
//  一级入口 → 这里 → 点设备 → device_payment_page（三级）
// ============================================================
class UtilityPaymentPage extends StatefulWidget {
  final String tenantPhone;

  const UtilityPaymentPage({super.key, required this.tenantPhone});

  @override
  State<UtilityPaymentPage> createState() => _UtilityPaymentPageState();
}

class _UtilityPaymentPageState extends State<UtilityPaymentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 当前登录租客的合同关联房间
  Contract? get _myContract {
    return MockService.contracts.where(
      (c) => c.tenantPhone == widget.tenantPhone && c.status == ContractStatus.active
    ).firstOrNull;
  }

  // 房租待缴：从租房订单获取（nextBillAmount = 当月账单金额）
  double get _rentAmount {
    final order = MockService.getRentOrderByPhone(widget.tenantPhone);
    if (order != null && order['hasUnpaidBill'] == true) {
      return (order['nextBillAmount'] as double?) ?? _myContract?.rentAmount ?? 0;
    }
    return _myContract?.rentAmount ?? 0;
  }

  // 房租是否已缴
  bool get _rentPaid => MockService.isRentPaidByPhone(widget.tenantPhone);

  List<Device> get _myDevices {
    final contract = _myContract;
    if (contract == null) return [];
    return MockService.devices.where((d) => d.roomId == contract.roomId).toList();
  }

  List<Device> _electricDevices = [];
  List<Device> _waterDevices = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDevices();
  }

  void _loadDevices() {
    final devices = _myDevices;
    setState(() {
      _electricDevices = devices.where((d) => d.type == DeviceType.electricMeter).toList();
      _waterDevices = devices.where((d) => d.type == DeviceType.waterMeter).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 汇总待缴（水电 + 房租）
  double get _totalUnpaid {
    final deviceTotal = [..._electricDevices, ..._waterDevices].fold<double>(
      0, (sum, d) => sum + d.monthCost + (d.balance > 0 ? d.balance : 0)
    );
    final rentTotal = _rentPaid ? 0 : _rentAmount;
    return deviceTotal + rentTotal;
  }

  // 房租单独缴费
  void _payRent() async {
    if (_rentPaid || _rentAmount <= 0) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('缴纳房租'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('房间：${_myContract?.roomTitle ?? "未知"}'),
          const SizedBox(height: 8),
          Text('金额：¥${_rentAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          Text('租期：${_myContract != null ? "${_myContract!.startDate.year}-${_myContract!.startDate.month} 至 ${_myContract!.endDate.year}-${_myContract!.endDate.month}" : ""}'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            child: const Text('确认支付'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context);
    setState(() {
      MockService.markRentPaidByPhone(widget.tenantPhone);
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: Color(0xFF10B981))),
          const SizedBox(width: 12),
          const Text('缴费成功'),
        ]),
        content: Text('已成功缴纳房租 ¥${_rentAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('在线缴费', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: const Color(0xFF9E9E9E),
          indicatorColor: const Color(0xFF6366F1),
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          isScrollable: false,
          tabs: [
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.electric_bolt, size: 18),
                const SizedBox(width: 4),
                const Text('电费'),
                if (_electricDevices.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  _BadgeCount(count: _electricDevices.length),
                ],
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.water_drop, size: 18),
                const SizedBox(width: 4),
                const Text('水费'),
                if (_waterDevices.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  _BadgeCount(count: _waterDevices.length),
                ],
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.home, size: 18),
                const SizedBox(width: 4),
                const Text('房租费'),
                if (!_rentPaid && _rentAmount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(8)),
                    child: const Text('待缴', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ]),
            ),
            const Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.receipt_long, size: 18),
                SizedBox(width: 4),
                Text('其他'),
              ]),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 电费
          _DeviceListTab(
            devices: _electricDevices,
            emptyIcon: Icons.electric_bolt,
            emptyText: '暂无绑定电表',
            emptyHint: '请联系房东绑定电表设备',
            deviceType: DeviceType.electricMeter,
            tenantPhone: widget.tenantPhone,
          ),
          // 水费
          _DeviceListTab(
            devices: _waterDevices,
            emptyIcon: Icons.water_drop,
            emptyText: '暂无绑定水表',
            emptyHint: '请联系房东绑定水表设备',
            deviceType: DeviceType.waterMeter,
            tenantPhone: widget.tenantPhone,
          ),
          // 房租费
          _RentTab(
            contract: _myContract,
            rentAmount: _rentAmount,
            rentPaid: _rentPaid,
            onPay: _payRent,
          ),
          // 其他杂费
          _OtherFeesTab(tenantPhone: widget.tenantPhone),
        ],
      ),
      bottomSheet: _totalUnpaid > 0
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2))],
              ),
              child: SafeArea(
                child: Row(children: [
                  Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('待缴费合计', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                    Text('¥${_totalUnpaid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                  ]),
                  const Spacer(),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => _showPayAllSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      ),
                      child: const Text('一键缴费', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
            )
          : null,
    );
  }

  void _showPayAllSheet(BuildContext context) {
    final contract = _myContract;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('一键缴费确认', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_electricDevices.isNotEmpty) ...[
            _PayConfirmRow(icon: Icons.electric_bolt, label: '电费', amount: _electricDevices.fold<double>(0, (s, d) => s + d.monthCost)),
            const SizedBox(height: 8),
          ],
          if (_waterDevices.isNotEmpty) ...[
            _PayConfirmRow(icon: Icons.water_drop, label: '水费', amount: _waterDevices.fold<double>(0, (s, d) => s + d.monthCost)),
            const SizedBox(height: 8),
          ],
          if (!_rentPaid && _rentAmount > 0) ...[
            _PayConfirmRow(icon: Icons.home, label: '房租费', amount: _rentAmount),
            const SizedBox(height: 8),
          ],
          if (contract != null && contract.depositAmount > 0) ...[
            _PayConfirmRow(icon: Icons.security, label: '押金（${contract.depositAmount.toStringAsFixed(0)}元）', amount: contract.depositAmount, hint: '退租时可退'),
            const SizedBox(height: 8),
          ],
          const Divider(height: 24),
          Row(children: [
            const Text('合计', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('¥${_totalUnpaid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _doPayAll(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('确认支付全部', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _doPayAll(BuildContext context) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context);
    // 缴完后刷新状态
    setState(() {
      MockService.markRentPaidByPhone(widget.tenantPhone);
      _loadDevices();
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: Color(0xFF10B981))),
          const SizedBox(width: 12),
          const Text('缴费成功'),
        ]),
        content: Text('已成功缴纳 ¥${_totalUnpaid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
        actions: [
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  房租费 Tab
// ============================================================
class _RentTab extends StatelessWidget {
  final Contract? contract;
  final double rentAmount;
  final bool rentPaid;
  final VoidCallback onPay;

  const _RentTab({required this.contract, required this.rentAmount, required this.rentPaid, required this.onPay});

  @override
  Widget build(BuildContext context) {
    if (contract == null) {
      return _EmptyState(icon: Icons.home, text: '暂无有效合同', hint: '请先签订租房合同');
    }

    final rent = contract!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 合同信息卡片
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(children: [
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.home_work, color: Color(0xFF6366F1), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(rent.roomTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('租期：${rent.startDate.year}.${rent.startDate.month} - ${rent.endDate.year}.${rent.endDate.month}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: rent.status == ContractStatus.active
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(rent.statusLabel, style: TextStyle(fontSize: 11, color: rent.status == ContractStatus.active ? const Color(0xFF10B981) : Colors.orange)),
              ),
            ]),
            const Divider(height: 24),
            Row(children: [
              _InfoChip(label: '月租金', value: '¥${rent.rentAmount.toStringAsFixed(2)}', valueColor: const Color(0xFFEF4444)),
              const SizedBox(width: 12),
              _InfoChip(label: '押金', value: '¥${rent.depositAmount.toStringAsFixed(2)}'),
              const SizedBox(width: 12),
              _InfoChip(label: '到期天数', value: '${rent.daysToExpire}天', valueColor: rent.daysToExpire < 30 ? Colors.orange : null),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        // 本月房租待缴卡片
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rentPaid ? const Color(0xFF10B981).withOpacity(0.06) : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: rentPaid ? const Color(0xFF10B981).withOpacity(0.3) : const Color(0xFFFDE68A)),
          ),
          child: Column(children: [
            Row(children: [
              Icon(rentPaid ? Icons.check_circle : Icons.access_time, size: 28, color: rentPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(rentPaid ? '本月房租已缴清' : '本月房租待缴纳', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: rentPaid ? const Color(0xFF10B981) : const Color(0xFF92400E))),
                const SizedBox(height: 4),
                Text(rentPaid ? '感谢您的按时缴费' : '请尽快完成缴纳，以免影响租住', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('¥${rentAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: rentPaid ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                Text('/月', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ]),
            ]),
            if (!rentPaid) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: onPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: const Text('立即缴纳房租', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 12),
        // 历史缴费记录
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('最近缴费记录', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(3, (i) {
              final months = ['2026年3月', '2026年2月', '2026年1月'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.check, size: 16, color: Color(0xFF10B981))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(months[i], style: const TextStyle(fontSize: 13)),
                    Text('房租 · ${months[i].replaceFirst('年', '-').replaceFirst('月', '')}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ])),
                  Text('-¥${rentAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF10B981))),
                ]),
              );
            }),
          ]),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoChip({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor ?? Colors.black87)),
    ]));
  }
}

// ============================================================
//  设备列表 Tab（电费/水费）
// ============================================================
class _DeviceListTab extends StatelessWidget {
  final List<Device> devices;
  final IconData emptyIcon;
  final String emptyText;
  final String emptyHint;
  final DeviceType deviceType;
  final String tenantPhone;

  const _DeviceListTab({
    required this.devices,
    required this.emptyIcon,
    required this.emptyText,
    required this.emptyHint,
    required this.deviceType,
    required this.tenantPhone,
  });

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return _EmptyState(icon: emptyIcon, text: emptyText, hint: emptyHint);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12).copyWith(bottom: 100),
      itemCount: devices.length,
      itemBuilder: (ctx, i) {
        final d = devices[i];
        return _DeviceCard(device: d, tenantPhone: tenantPhone);
      },
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final Device device;
  final String tenantPhone;

  const _DeviceCard({required this.device, required this.tenantPhone});

  @override
  Widget build(BuildContext context) {
    final hasBalance = device.balance > 0;
    final total = device.monthCost + (hasBalance ? device.balance : 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: device.status == DeviceStatus.online
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : device.status == DeviceStatus.warning
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              device.type == DeviceType.electricMeter ? Icons.electric_bolt : Icons.water_drop,
              color: device.status == DeviceStatus.online ? const Color(0xFF10B981) : device.status == DeviceStatus.warning ? Colors.orange : Colors.grey,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(device.deviceNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: device.status == DeviceStatus.online
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : device.status == DeviceStatus.warning
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  device.status == DeviceStatus.online ? '在线' : device.status == DeviceStatus.warning ? '余额不足' : '离线',
                  style: TextStyle(fontSize: 10, color: device.status == DeviceStatus.online ? const Color(0xFF10B981) : device.status == DeviceStatus.warning ? Colors.orange : Colors.grey),
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Text('本月用量 ${device.monthUsage.toStringAsFixed(1)} kWh · ${device.lastReadAt != null ? _timeAgo(device.lastReadAt!) : ""}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('¥${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: hasBalance ? const Color(0xFFEF4444) : Colors.black87)),
            if (hasBalance) Text('含余额不足 ¥${device.balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 9, color: Color(0xFFEF4444))),
          ]),
        ]),
        if (device.status == DeviceStatus.warning) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.warning_amber, size: 14, color: Colors.orange),
              const SizedBox(width: 6),
              Expanded(child: Text('账户余额不足（¥${device.balance.toStringAsFixed(2)}），请及时充值', style: const TextStyle(fontSize: 11, color: Colors.orange))),
            ]),
          ),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DevicePaymentPage(device: device, tenantPhone: tenantPhone))),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF6366F1), side: const BorderSide(color: Color(0xFF6366F1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 8)),
            child: const Text('查看详情 / 充值', style: TextStyle(fontSize: 12)),
          )),
        ]),
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}

// ============================================================
//  其他杂费 Tab
// ============================================================
class _OtherFeesTab extends StatelessWidget {
  final String tenantPhone;

  const _OtherFeesTab({required this.tenantPhone});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockOtherFees = [
      {'label': '停车费', 'amount': 300.0, 'desc': '2026年4月地面停车位'},
      {'label': '物业费', 'amount': 150.0, 'desc': '2026年4月物业管理费'},
      {'label': '网络费', 'amount': 80.0, 'desc': '2026年4月宽带费'},
    ];
    final hasAny = mockOtherFees.any((f) => (f['amount'] as double) > 0);

    if (!hasAny) {
      return _EmptyState(icon: Icons.receipt_long, text: '暂无其他费用', hint: '其他杂费将显示在这里');
    }

    return ListView(
      padding: const EdgeInsets.all(12).copyWith(bottom: 100),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('本月其他费用', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...mockOtherFees.map((fee) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.receipt, size: 18, color: Color(0xFF6366F1))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(fee['label'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    Text(fee['desc'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('¥${(fee['amount'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                    const Text('待缴', style: TextStyle(fontSize: 10, color: Color(0xFFEF4444))),
                  ]),
                ]),
              )),
              const Divider(height: 24),
              Row(children: [
                const Text('合计', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('¥${mockOtherFees.fold<double>(0, (s, f) => s + (f['amount'] as double)).toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
              ]),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('其他杂费暂不支持线上支付，请联系房东'))),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: const Text('联系房东缴纳', style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
//  通用空状态
// ============================================================
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  final String hint;

  const _EmptyState({required this.icon, required this.text, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 56, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      Text(text, style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
      const SizedBox(height: 6),
      Text(hint, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
    ]));
  }
}

// ============================================================
//  小工具组件
// ============================================================
class _BadgeCount extends StatelessWidget {
  final int count;
  const _BadgeCount({required this.count});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(8)),
    child: Text('$count', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
  );
}

class _PayConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final String? hint;

  const _PayConfirmRow({required this.icon, required this.label, required this.amount, this.hint});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: Colors.grey.shade600),
    const SizedBox(width: 8),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13)),
      if (hint != null) Text(hint!, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
    ])),
    Text('¥${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
  ]);
}