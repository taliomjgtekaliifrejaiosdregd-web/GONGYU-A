import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';
import 'package:gongyu_guanjia/models/device.dart';
import 'package:gongyu_guanjia/pages/landlord/add_device_page.dart';

// ============================================================
// 房东端 - 设备管理（一级总览，全设备导航中心）
// ============================================================
class LandlordDevicePage extends StatefulWidget {
  const LandlordDevicePage({super.key});

  @override
  State<LandlordDevicePage> createState() => _LandlordDevicePageState();
}

class _LandlordDevicePageState extends State<LandlordDevicePage> {
  List<DeviceAlert> _alerts = [];

  @override
  void initState() {
    super.initState();
    _alerts = MockService.getAlerts();
  }

  List<Device> get _devices => MockService.devices;
  List<Device> get _electricMeters => _devices.where((d) => d.type == DeviceType.electricMeter).toList();
  List<Device> get _waterMeters => _devices.where((d) => d.type == DeviceType.waterMeter).toList();
  List<Device> get _smartLocks => _devices.where((d) => d.type == DeviceType.smartLock).toList();

  int get _onlineCount => _devices.where((d) => d.status == DeviceStatus.online).length;
  int get _offlineCount => _devices.where((d) => d.status == DeviceStatus.offline).length;
  int get _warningCount => _devices.where((d) => d.status == DeviceStatus.warning || d.isWarning).length;
  int get _alertCount => _alerts.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('设备管理', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _showAddDevice(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ===== 一、统计卡片 =====
          _StatCards(
            totalCount: _devices.length,
            onlineCount: _onlineCount,
            offlineCount: _offlineCount,
            warningCount: _warningCount,
            alertCount: _alertCount,
          ),

          const SizedBox(height: 16),

          // ===== 二、三类设备快捷入口 =====
          const Text('设备分类', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _DeviceTypeCard(
                icon: Icons.electric_bolt,
                label: '电表',
                count: _electricMeters.length,
                online: _electricMeters.where((d) => d.status == DeviceStatus.online).length,
                color: const Color(0xFFF59E0B),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ElectricMeterListPage())),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DeviceTypeCard(
                icon: Icons.water_drop,
                label: '水表',
                count: _waterMeters.length,
                online: _waterMeters.where((d) => d.status == DeviceStatus.online).length,
                color: const Color(0xFF06B6D4),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WaterMeterListPage())),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DeviceTypeCard(
                icon: Icons.lock,
                label: '门锁',
                count: _smartLocks.length,
                online: _smartLocks.where((d) => d.status == DeviceStatus.online).length,
                color: const Color(0xFF6366F1),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartLockListPage())),
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // ===== 三、告警提醒 =====
          if (_alerts.isNotEmpty) ...[
            Row(children: [
              const Text('异常告警', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('${_alerts.length}条', style: TextStyle(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 10),
            ..._alerts.map((a) => _AlertCard(
              alert: a,
              onTap: () => _navigateToDevice(a.deviceId),
              onHandle: () => _handleAlert(a),
            )),
            const SizedBox(height: 20),
          ],

          // ===== 四、全部设备列表（可滚动查看） =====
          Row(children: [
            const Text('全部设备', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('共${_devices.length}台', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ]),
          const SizedBox(height: 10),
          ..._devices.map((d) => _DeviceRow(
            device: d,
            onTap: () => _navigateToDeviceDetail(d),
          )),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  void _navigateToDevice(int deviceId) {
    final device = _devices.firstWhere((d) => d.id == deviceId, orElse: () => _devices.first);
    _navigateToDeviceDetail(device);
  }

  void _navigateToDeviceDetail(Device device) {
    switch (device.type) {
      case DeviceType.electricMeter:
        Navigator.push(context, MaterialPageRoute(builder: (_) => ElectricMeterDetailPage(device: device)));
        break;
      case DeviceType.waterMeter:
        Navigator.push(context, MaterialPageRoute(builder: (_) => WaterMeterDetailPage(device: device)));
        break;
      case DeviceType.smartLock:
        Navigator.push(context, MaterialPageRoute(builder: (_) => SmartLockDetailPage(device: device)));
        break;
    }
  }

  void _handleAlert(DeviceAlert alert) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('处理告警'),
        content: Text('处理方式：${alert.message}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('稍后处理')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _alerts.removeWhere((a) => a.id == alert.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('告警已处理'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('标记已处理'),
          ),
        ],
      ),
    );
  }

  void _showAddDevice(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddDevicePage(),
        fullscreenDialog: true,
      ),
    );
  }
}

// ============================================================
// 统计卡片
// ============================================================
class _StatCards extends StatelessWidget {
  final int totalCount, onlineCount, offlineCount, warningCount, alertCount;
  const _StatCards({
    required this.totalCount, required this.onlineCount,
    required this.offlineCount, required this.warningCount, required this.alertCount,
  });
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Column(children: [
      Row(children: [
        const Text('设备总览', style: TextStyle(color: Colors.white70, fontSize: 12)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: Text('$totalCount 台设备', style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        _MiniStat('在线', '$onlineCount', const Color(0xFF10B981)),
        _MiniStat('离线', '$offlineCount', const Color(0xFF9E9E9E)),
        _MiniStat('预警', '$warningCount', const Color(0xFFF59E0B)),
        _MiniStat('告警', '$alertCount', const Color(0xFFEF4444)),
      ]),
    ]),
  );
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
    Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
  ]));
}

// ============================================================
// 设备类型入口卡片
// ============================================================
class _DeviceTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final int online;
  final Color color;
  final VoidCallback onTap;
  const _DeviceTypeCard({
    required this.icon, required this.label, required this.count,
    required this.online, required this.color, required this.onTap,
  });
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('$count 台', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text('$online 在线', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ]),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text('查看详情 →', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600))),
        ),
      ]),
    ),
  );
}

// ============================================================
// 告警卡片
// ============================================================
class _AlertCard extends StatelessWidget {
  final DeviceAlert alert;
  final VoidCallback onTap;
  final VoidCallback onHandle;
  const _AlertCard({required this.alert, required this.onTap, required this.onHandle});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(alert.message, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(alert.roomTitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ])),
        GestureDetector(
          onTap: onHandle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: const Text('处理', style: TextStyle(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.w500)),
          ),
        ),
      ]),
    ),
  );
}

// ============================================================
// 设备列表行
// ============================================================
class _DeviceRow extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;
  const _DeviceRow({required this.device, required this.onTap});

  Color get _typeColor {
    switch (device.type) {
      case DeviceType.electricMeter: return const Color(0xFFF59E0B);
      case DeviceType.waterMeter: return const Color(0xFF06B6D4);
      case DeviceType.smartLock: return const Color(0xFF6366F1);
    }
  }

  IconData get _typeIcon {
    switch (device.type) {
      case DeviceType.electricMeter: return Icons.electric_bolt;
      case DeviceType.waterMeter: return Icons.water_drop;
      case DeviceType.smartLock: return Icons.lock;
    }
  }

  Color get _statusColor {
    switch (device.status) {
      case DeviceStatus.online: return const Color(0xFF10B981);
      case DeviceStatus.offline: return const Color(0xFF9E9E9E);
      case DeviceStatus.warning: return const Color(0xFFF59E0B);
      case DeviceStatus.error: return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: _typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(_typeIcon, color: _typeColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(device.typeLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(device.roomTitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(device.currentValue, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _typeColor)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(device.statusLabel, style: TextStyle(fontSize: 10, color: _statusColor)),
          ),
        ]),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 18),
      ]),
    ),
  );
}

// ============================================================
// 二级：电表列表页
// ============================================================
class ElectricMeterListPage extends StatelessWidget {
  const ElectricMeterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final meters = MockService.devices.where((d) => d.type == DeviceType.electricMeter).toList();

    // 按房源分组
    final grouped = <String, List<Device>>{};
    for (final m in meters) {
      grouped.putIfAbsent(m.roomTitle, () => []).add(m);
    }

    double totalBalance = meters.fold(0, (s, d) => s + d.balance);
    double totalMonthUsage = meters.fold(0, (s, d) => s + d.monthUsage);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('电表管理', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(children: [
        // 汇总
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFF59E0B).withOpacity(0.08),
          child: Row(children: [
            Expanded(child: _SummaryItem('设备数', '${meters.length}', const Color(0xFFF59E0B))),
            Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
            Expanded(child: _SummaryItem('本月用电', '${totalMonthUsage.toStringAsFixed(0)}度', const Color(0xFFF59E0B))),
            Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
            Expanded(child: _SummaryItem('账户余额', '¥${totalBalance.toStringAsFixed(0)}', const Color(0xFF10B981))),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: grouped.length,
            itemBuilder: (_, i) {
              final roomTitle = grouped.keys.elementAt(i);
              final devices = grouped[roomTitle]!;
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _RoomHeader(roomTitle),
                ...devices.map((d) => _ElectricMeterRow(device: d)),
                const SizedBox(height: 8),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryItem(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Column(children: [
    Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
  ]);
}

class _RoomHeader extends StatelessWidget {
  final String title;
  const _RoomHeader(this.title);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      const Icon(Icons.home, size: 14, color: AppColors.primary),
      const SizedBox(width: 6),
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
    ]),
  );
}

class _ElectricMeterRow extends StatelessWidget {
  final Device device;
  const _ElectricMeterRow({required this.device});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ElectricMeterDetailPage(device: device))),
    child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.electric_bolt, color: Color(0xFFF59E0B), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(device.deviceNo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Row(children: [
            Text('今日: ${device.todayUsage}度', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(width: 12),
            Text('本月: ${device.monthUsage}度', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${device.currentReading}度', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
          const SizedBox(height: 2),
          Text('余额 ¥${device.balance.toStringAsFixed(0)}', style: TextStyle(fontSize: 10, color: device.balance < 10 ? const Color(0xFFEF4444) : Colors.grey.shade500)),
        ]),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 18),
      ]),
    ),
  );
}

// ============================================================
// 三级：电表详情页
// ============================================================
class ElectricMeterDetailPage extends StatelessWidget {
  final Device device;
  const ElectricMeterDetailPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(device.roomTitle, style: const TextStyle(fontSize: 15)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          // 实时读数卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(children: [
              const Icon(Icons.electric_bolt, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              const Text('当前读数', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${device.currentReading}', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                const Text(' 度', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _MeterStat('余额', '¥${device.balance.toStringAsFixed(0)}', Colors.green.shade200),
                _MeterStat('今日用电', '${device.todayUsage}度', Colors.white70),
                _MeterStat('本月用电', '${device.monthUsage}度', Colors.white70),
                _MeterStat('本月费用', '¥${device.monthCost.toStringAsFixed(0)}', Colors.white70),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // 操作按钮
          Row(children: [
            Expanded(
              child: _ActionCard(Icons.payment, '充值电费', const Color(0xFF10B981), () => _recharge(context)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionCard(Icons.history, '历史记录', const Color(0xFF6366F1), () => _showHistory(context)),
            ),
          ]),
          const SizedBox(height: 16),

          // 设备信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('设备信息', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _InfoRow('设备编号', device.deviceNo),
              _InfoRow('设备品牌', device.brand),
              _InfoRow('设备类型', '智能电表'),
              _InfoRow('最后读取', device.lastReadAt?.toString().substring(0, 16) ?? '刚刚'),
              _InfoRow('在线状态', device.statusLabel),
            ]),
          ),
          const SizedBox(height: 16),

          // 本月用电曲线（模拟）
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('近7日用电量', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Bar('昨天', 12, 45),
                    _Bar('今天', 8, 32),
                    _Bar('周一', 15, 58),
                    _Bar('周二', 10, 40),
                    _Bar('周三', 18, 70),
                    _Bar('周四', 14, 55),
                    _Bar('周五', 9, 38),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  void _recharge(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('电表充值', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [50, 100, 200, 500].map((a) => GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Text('¥$a (${(a / 0.4).toStringAsFixed(0)}度)', style: const TextStyle(fontSize: 13, color: Color(0xFFF59E0B))),
            ),
          )).toList()),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('充值成功！金额已到账'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              child: const Text('立即充值', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, sc) => Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Text('用电历史记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(controller: sc, padding: const EdgeInsets.all(12), children: [
              ...['2026-04-16 今日', '2026-04-15', '2026-04-14', '2026-04-13', '2026-04-12'].asMap().entries.map((e) => _HistoryRow(
                date: e.value,
                usage: 10.0 + e.key * 2.5,
                cost: (10.0 + e.key * 2.5) * 0.4,
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _MeterStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MeterStat(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(label, style: TextStyle(color: color, fontSize: 10)),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
  ]));
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard(this.icon, this.label, this.color, this.onTap);
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
    ]),
  );
}

class _Bar extends StatelessWidget {
  final String label;
  final double height;
  final double maxH;
  const _Bar(this.label, this.height, this.maxH);
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: (height / maxH).clamp(0.1, 1.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
        ),
      ),
    ),
    const SizedBox(height: 4),
    Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
    Text('${height.toStringAsFixed(0)}度', style: const TextStyle(fontSize: 8)),
  ]));
}

class _HistoryRow extends StatelessWidget {
  final String date;
  final double usage;
  final double cost;
  const _HistoryRow({required this.date, required this.usage, required this.cost});
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.electric_bolt, color: Color(0xFFF59E0B), size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        Text('用量 ${usage.toStringAsFixed(1)}度', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('¥${cost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        Text('已支付', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      ]),
    ]),
  );
}

// ============================================================
// 二级：水表列表页
// ============================================================
class WaterMeterListPage extends StatelessWidget {
  const WaterMeterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final meters = MockService.devices.where((d) => d.type == DeviceType.waterMeter).toList();
    final grouped = <String, List<Device>>{};
    for (final m in meters) {
      grouped.putIfAbsent(m.roomTitle, () => []).add(m);
    }
    double totalMonthUsage = meters.fold(0, (s, d) => s + d.monthUsage);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('水表管理', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF06B6D4).withOpacity(0.08),
          child: Row(children: [
            Expanded(child: _SummaryItem('设备数', '${meters.length}', const Color(0xFF06B6D4))),
            Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
            Expanded(child: _SummaryItem('本月用水', '${totalMonthUsage.toStringAsFixed(1)}吨', const Color(0xFF06B6D4))),
            Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
            Expanded(child: _SummaryItem('告警设备', '${meters.where((d) => d.isWarning).length}', const Color(0xFFEF4444))),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: grouped.length,
            itemBuilder: (_, i) {
              final roomTitle = grouped.keys.elementAt(i);
              final devices = grouped[roomTitle]!;
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _RoomHeader(roomTitle),
                ...devices.map((d) => _WaterMeterRow(device: d)),
                const SizedBox(height: 8),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}

class _WaterMeterRow extends StatelessWidget {
  final Device device;
  const _WaterMeterRow({required this.device});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WaterMeterDetailPage(device: device))),
    child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: const Color(0xFF06B6D4).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.water_drop, color: Color(0xFF06B6D4), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(device.deviceNo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Row(children: [
            Text('今日: ${device.todayUsage}吨', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(width: 12),
            Text('本月: ${device.monthUsage}吨', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${device.currentReading}吨', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF06B6D4))),
          if (device.isWarning) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text('告警', style: TextStyle(fontSize: 10, color: Color(0xFFEF4444))),
            ),
          ],
        ]),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 18),
      ]),
    ),
  );
}

// ============================================================
// 三级：水表详情页
// ============================================================
class WaterMeterDetailPage extends StatelessWidget {
  final Device device;
  const WaterMeterDetailPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06B6D4), foregroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(device.roomTitle, style: const TextStyle(fontSize: 15)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0891B2)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: const Color(0xFF06B6D4).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(children: [
              const Icon(Icons.water_drop, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              const Text('当前读数', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${device.currentReading}', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                const Text(' 吨', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _MeterStat('今日用水', '${device.todayUsage}吨', Colors.white70),
                _MeterStat('本月用水', '${device.monthUsage}吨', Colors.white70),
                _MeterStat('月费用', '¥${(device.monthUsage * 8.06).toStringAsFixed(0)}', Colors.green.shade200),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('设备信息', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _InfoRow('设备编号', device.deviceNo),
              _InfoRow('设备品牌', device.brand),
              _InfoRow('预警阈值', '${device.warningThreshold ?? 1}吨'),
              _InfoRow('设备状态', device.statusLabel),
            ]),
          ),
          const SizedBox(height: 16),
          // 用量曲线
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('近7日用水量', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              SizedBox(height: 100, child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _WaterBar('昨天', 1.2, 3.5),
                  _WaterBar('今天', 0.8, 3.5),
                  _WaterBar('周一', 2.0, 3.5),
                  _WaterBar('周二', 1.5, 3.5),
                  _WaterBar('周三', 1.8, 3.5),
                  _WaterBar('周四', 1.0, 3.5),
                  _WaterBar('周五', 0.6, 3.5),
                ],
              )),
            ]),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _WaterBar extends StatelessWidget {
  final String label;
  final double height;
  final double maxH;
  const _WaterBar(this.label, this.height, this.maxH);
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: (height / maxH).clamp(0.1, 1.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
        ),
      ),
    ),
    const SizedBox(height: 4),
    Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
    Text('${height.toStringAsFixed(1)}吨', style: const TextStyle(fontSize: 8)),
  ]));
}

// ============================================================
// 二级：门锁列表页
// ============================================================
class SmartLockListPage extends StatelessWidget {
  const SmartLockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locks = MockService.devices.where((d) => d.type == DeviceType.smartLock).toList();
    final grouped = <String, List<Device>>{};
    for (final l in locks) {
      grouped.putIfAbsent(l.roomTitle, () => []).add(l);
    }
    int lowBattery = locks.where((d) => d.balance < 20).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('门锁管理', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF6366F1).withOpacity(0.08),
          child: Row(children: [
            Expanded(child: _SummaryItem('设备数', '${locks.length}', const Color(0xFF6366F1))),
            Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
            Expanded(child: _SummaryItem('正常', '${locks.length - lowBattery}', const Color(0xFF10B981))),
            Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
            Expanded(child: _SummaryItem('低电量', '$lowBattery', const Color(0xFFF59E0B))),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: grouped.length,
            itemBuilder: (_, i) {
              final roomTitle = grouped.keys.elementAt(i);
              final devices = grouped[roomTitle]!;
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _RoomHeader(roomTitle),
                ...devices.map((d) => _SmartLockRow(device: d)),
                const SizedBox(height: 8),
              ]);
            },
          ),
        ),
      ]),
    );
  }
}

class _SmartLockRow extends StatelessWidget {
  final Device device;
  const _SmartLockRow({required this.device});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SmartLockDetailPage(device: device))),
    child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: device.balance < 20 ? Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)) : null,
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.lock, color: Color(0xFF6366F1), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(device.deviceNo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Row(children: [
            Icon(Icons.battery_std, size: 14, color: device.balance > 50 ? const Color(0xFF10B981) : device.balance > 20 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
            const SizedBox(width: 4),
            Text('${device.balance.toInt()}%', style: TextStyle(fontSize: 11, color: device.balance > 50 ? const Color(0xFF10B981) : device.balance > 20 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444))),
            if (device.balance < 20) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text('低电量', style: TextStyle(fontSize: 9, color: Color(0xFFF59E0B))),
              ),
            ],
          ]),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: device.status == DeviceStatus.online ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF9E9E9E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(device.statusLabel, style: TextStyle(fontSize: 10, color: device.status == DeviceStatus.online ? const Color(0xFF10B981) : const Color(0xFF9E9E9E))),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 18),
      ]),
    ),
  );
}

// ============================================================
// 三级：门锁详情页
// ============================================================
class SmartLockDetailPage extends StatelessWidget {
  final Device device;
  const SmartLockDetailPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(device.roomTitle, style: const TextStyle(fontSize: 15)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          // 门锁状态卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.lock, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(device.deviceNo, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('门锁正常 · 已上锁', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ])),
                Column(children: [
                  Icon(device.balance > 20 ? Icons.battery_std : Icons.battery_alert, color: device.balance > 20 ? Colors.green.shade200 : Colors.red.shade200, size: 22),
                  const SizedBox(height: 3),
                  Text('${device.balance.toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ]),
              ]),
              const SizedBox(height: 16),
              // 大开锁按钮
              GestureDetector(
                onTap: () => _remoteUnlock(context),
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.lock_open, color: Colors.white, size: 36),
                    const SizedBox(height: 4),
                    const Text('远程开锁', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // 操作按钮
          Row(children: [
            Expanded(child: _ActionCard(Icons.password, '修改密码', const Color(0xFF6366F1), () => _changePassword(context))),
            const SizedBox(width: 8),
            Expanded(child: _ActionCard(Icons.vpn_key, '临时密码', const Color(0xFFF59E0B), () => _tempPassword(context))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _ActionCard(Icons.history, '开锁记录', const Color(0xFF10B981), () => _showUnlockHistory(context))),
            const SizedBox(width: 8),
            Expanded(child: _ActionCard(Icons.settings, '门锁设置', const Color(0xFF9E9E9E), () => _lockSettings(context))),
          ]),
          const SizedBox(height: 16),

          // 设备信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('设备信息', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _InfoRow('设备编号', device.deviceNo),
              _InfoRow('设备品牌', device.brand),
              _InfoRow('设备型号', '德施曼Q5 Pro'),
              _InfoRow('在线状态', device.statusLabel),
              _InfoRow('电池电量', '${device.balance.toInt()}%'),
            ]),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  void _remoteUnlock(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.canPop(context)) Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('门锁已开启！'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
      );
    });
  }

  void _changePassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('修改开门密码', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(keyboardType: TextInputType.number, maxLength: 6, obscureText: true,
            decoration: const InputDecoration(labelText: '新密码（6位数字）', border: OutlineInputBorder(), counterText: '')),
          const SizedBox(height: 12),
          TextField(keyboardType: TextInputType.number, maxLength: 6, obscureText: true,
            decoration: const InputDecoration(labelText: '确认密码', border: OutlineInputBorder(), counterText: '')),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('密码修改成功'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              child: const Text('确认修改', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  void _tempPassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('生成临时密码', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('有效期：30分钟 | 次数：1次', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('8 3 2 1 5 6', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 6, color: Color(0xFFF59E0B))),
              const SizedBox(width: 12),
              Icon(Icons.copy, color: Colors.orange.shade400),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              child: const Text('复制密码并发送', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  void _lockSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: Row(children: [
              const Icon(Icons.settings, color: Color(0xFF6366F1), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('门锁设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(device.deviceNo, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ]),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
          ),

          // 设置项列表
          ...[
            _MapEntry(Icons.label_outline, '设备名称', '修改门锁显示名称', device.roomTitle + '门锁', false),
            _MapEntry(Icons.timer, '自动上锁', '关门后自动锁定的等待时间', '30秒', false),
            _MapEntry(Icons.volume_up, '语音提示', '开锁/上锁语音播报', '开启', false),
            _MapEntry(Icons.wifi, '网络信号', '设备联网状态', '强 · -45dBm', false),
            _MapEntry(Icons.update, '固件版本', '检查并更新门锁固件', 'V2.3.1 · 已是最新', false),
            _MapEntry(Icons.person_add, '亲情号码', '管理家庭成员开锁权限', '3个', false),
            _MapEntry(Icons.notifications_active, '开门提醒', '有人开锁时推送通知', '已开启', false),
            _MapEntry(Icons.warning_amber, '低电量提醒', '电量低于阈值时通知', '20%', false),
            _MapEntry(Icons.link_off, '解除绑定', '将此门锁从系统移除', '', true),
          ].map((item) => _SettingsItem(
            icon: item.icon,
            title: item.title,
            desc: item.desc,
            trailing: item.trailing,
            isDanger: item.isDanger,
            onTap: () => _onSettingsTap(context, item.title, item.isDanger),
          )),

          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  void _onSettingsTap(BuildContext context, String title, bool isDanger) {
    if (isDanger) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('确认解除绑定'),
          content: Text('确定要将 "${device.deviceNo}" 从系统中移除吗？\n\n解除后该门锁将无法通过 APP 控制，请谨慎操作。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 关闭确认框
                Navigator.pop(context); // 关闭设置页
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('门锁已解除绑定'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFFEF4444)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('确认解除', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title 功能开发中...'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showUnlockHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, sc) => Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Text('开锁记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(controller: sc, padding: const EdgeInsets.all(12), children: [
              ...['今天 09:15 密码开锁 成功', '今天 08:30 指纹开锁 成功', '昨天 22:45 远程开锁 成功', '昨天 22:44 密码开锁 失败', '昨天 08:00 指纹开锁 成功', '04-14 19:30 门卡开锁 成功'].asMap().entries.map((e) => _UnlockRecordRow(
                time: e.value.split(' ').first + ' ' + e.value.split(' ')[1],
                method: e.value.split(' ')[2],
                success: !e.value.contains('失败'),
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _UnlockRecordRow extends StatelessWidget {
  final String time;
  final String method;
  final bool success;
  const _UnlockRecordRow({required this.time, required this.method, required this.success});
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: (success ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(success ? Icons.check_circle : Icons.cancel, color: success ? const Color(0xFF10B981) : const Color(0xFFEF4444), size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(method, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        Text(time, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ])),
      Text(success ? '成功' : '失败', style: TextStyle(fontSize: 11, color: success ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
    ]),
  );
}

// ============================================================
// 门锁设置项
// ============================================================
// ============================================================
// 门锁设置数据项
// ============================================================
class _MapEntry {
  final IconData icon;
  final String title;
  final String desc;
  final String trailing;
  final bool isDanger;
  const _MapEntry(this.icon, this.title, this.desc, this.trailing, this.isDanger);
}

// ============================================================
// 门锁设置项
// ============================================================
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final String trailing;
  final bool isDanger;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.trailing,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? const Color(0xFFEF4444) : const Color(0xFF6366F1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 0.5)),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDanger ? color : Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ]),
          ),
          if (trailing.isNotEmpty) ...[
            Text(trailing, style: TextStyle(fontSize: 12, color: isDanger ? color : Colors.grey.shade500)),
            const SizedBox(width: 4),
          ],
          Icon(Icons.chevron_right, color: isDanger ? color : const Color(0xFFBDBDBD), size: 18),
        ]),
      ),
    );
  }
}

