import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/models/device.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

class ElectricAnalysisPage extends StatefulWidget {
  const ElectricAnalysisPage({super.key});

  @override
  State<ElectricAnalysisPage> createState() => _ElectricAnalysisPageState();
}

class _ElectricAnalysisPageState extends State<ElectricAnalysisPage> {
  int _selectedMonth = 0; // 0=本月, 1=上月, 2=近3月

  List<Map<String, dynamic>> get _monthlyData {
    return [
      {'month': '2026-01', 'usage': 2840, 'cost': 1704, 'rooms': 6},
      {'month': '2026-02', 'usage': 2650, 'cost': 1590, 'rooms': 6},
      {'month': '2026-03', 'usage': 3210, 'cost': 1926, 'rooms': 7},
      {'month': '2026-04', 'usage': 2980, 'cost': 1788, 'rooms': 7},
    ];
  }

  Map<String, dynamic> get _currentMonth {
    return _monthlyData.last;
  }

  List<Device> get _electricDevices {
    return MockService.devices.where((d) => d.type == DeviceType.electricMeter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalUsage = (_currentMonth['usage'] as int);
    final totalCost = (_currentMonth['cost'] as int);
    final avgUsage = totalUsage ~/ (_currentMonth['rooms'] as int);
    final prevMonth = _monthlyData[_monthlyData.length - 2];
    final growth = ((totalUsage - (prevMonth['usage'] as int)) / (prevMonth['usage'] as int) * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('用电分析', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('导出报表', style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSummaryCard(totalUsage, totalCost, avgUsage, growth),
            const SizedBox(height: 12),
            _buildMonthSelector(),
            const SizedBox(height: 12),
            _buildTrendChart(),
            const SizedBox(height: 12),
            _buildRoomList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int totalUsage, int totalCost, int avgUsage, String growth) {
    final isUp = !growth.startsWith('-');
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.electric_bolt, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              const Text('本月用电汇总', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUp ? Colors.red.shade300 : Colors.green.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white, size: 10),
                    const SizedBox(width: 2),
                    Text('$growth%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$totalUsage', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('kWh', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                    const SizedBox(height: 4),
                    const Text('总用电量', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              Container(width: 1, height: 60, color: Colors.white30),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('¥$totalCost', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text('总费用', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('均价 ¥0.6/kWh', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 60, color: Colors.white30),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$avgUsage', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text('kWh/房', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('${_currentMonth['rooms']}间房源', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    final labels = ['本月', '上月', '近3月'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(3, (i) {
          final selected = _selectedMonth == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMonth = i),
              child: Container(
                margin: EdgeInsets.only(left: i > 0 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFF59E0B) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTrendChart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('月度用电趋势 (kWh)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _monthlyData.map((item) {
                final maxVal = 3500.0;
                final h = ((item['usage'] as int) / maxVal).clamp(0.05, 1.0);
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${item['usage']}',
                        style: const TextStyle(fontSize: 9, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: h,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (item['month'] as String).substring(5),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
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

  Widget _buildRoomList() {
    final devices = _electricDevices;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('各房源用电明细', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          ...devices.map((device) {
            final usage = device.monthUsage;
            final cost = device.monthCost;
            final maxUsage = 500.0;
            final barW = (usage / maxUsage).clamp(0.0, 1.0);
            final statusColor = device.status == 'online'
                ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.home, color: const Color(0xFFF59E0B).withValues(alpha: 0.7), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          device.roomTitle ?? '未知房源',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        device.status == DeviceStatus.online ? '在线' : '离线',
                        style: TextStyle(fontSize: 11, color: statusColor),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${usage.toStringAsFixed(0)} kWh',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '¥${cost.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: barW.toDouble(),
                      minHeight: 4,
                      backgroundColor: const Color(0xFFF5F5F5),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
