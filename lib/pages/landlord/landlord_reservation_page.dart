import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

/// 看房预约状态
enum ReservationStatus {
  pending('待确认', Color(0xFFF59E0B)),
  confirmed('已确认', Color(0xFF6366F1)),
  completed('已完成', Color(0xFF10B981)),
  cancelled('已取消', Color(0xFF9E9E9E));

  final String label;
  final Color color;
  const ReservationStatus(this.label, this.color);
}

/// 预约看房记录
class Reservation {
  final String id;
  final ReservationStatus status;
  final String roomTitle;
  final String communityName;
  final String visitorName;
  final String visitorPhone;
  final String date;
  final String time;
  final String? remark;

  const Reservation({
    required this.id,
    required this.status,
    required this.roomTitle,
    required this.communityName,
    required this.visitorName,
    required this.visitorPhone,
    required this.date,
    required this.time,
    this.remark,
  });
}

/// ============================================================
// 房东端 - 预定管理（看房预约）
/// ============================================================
class LandlordReservationPage extends StatefulWidget {
  const LandlordReservationPage({super.key});

  @override
  State<LandlordReservationPage> createState() => _LandlordReservationPageState();
}

class _LandlordReservationPageState extends State<LandlordReservationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  final List<Reservation> _reservations = [
    Reservation(
      id: 'RES001', status: ReservationStatus.pending,
      roomTitle: '陆家嘴花园整租', communityName: '陆家嘴花园',
      visitorName: '孙先生', visitorPhone: '13812345678',
      date: '2026-04-18', time: '14:00-15:00',
    ),
    Reservation(
      id: 'RES002', status: ReservationStatus.pending,
      roomTitle: '前滩公寓', communityName: '前滩小区',
      visitorName: '周小姐', visitorPhone: '13987654321',
      date: '2026-04-18', time: '16:00-17:00',
    ),
    Reservation(
      id: 'RES003', status: ReservationStatus.confirmed,
      roomTitle: '浦东大道合租', communityName: '浦东大道公寓',
      visitorName: '吴先生', visitorPhone: '13723456789',
      date: '2026-04-17', time: '10:00-11:00',
      remark: '客户要求看南向房间',
    ),
    Reservation(
      id: 'RES004', status: ReservationStatus.completed,
      roomTitle: '徐家汇精品公寓', communityName: '汇翠花园',
      visitorName: '郑小姐', visitorPhone: '13698765432',
      date: '2026-04-15', time: '09:00-10:00',
      remark: '客户有意向，需要跟进',
    ),
    Reservation(
      id: 'RES005', status: ReservationStatus.cancelled,
      roomTitle: '新天地服务公寓', communityName: '新天地',
      visitorName: '王先生', visitorPhone: '13567891234',
      date: '2026-04-14', time: '15:00-16:00',
    ),
  ];

  List<Reservation> get _filtered {
    if (_currentTab == 0) return _reservations;
    return _reservations.where((r) {
      final statusMap = {
        1: ReservationStatus.pending,
        2: ReservationStatus.confirmed,
        3: ReservationStatus.completed,
      };
      return r.status == statusMap[_currentTab];
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() => _currentTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('预定管理', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(children: [
        // 统计
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Row(children: [
            _StatChip('待确认', _reservations.where((r) => r.status == ReservationStatus.pending).length, const Color(0xFFF59E0B)),
            const SizedBox(width: 12),
            _StatChip('已确认', _reservations.where((r) => r.status == ReservationStatus.confirmed).length, const Color(0xFF6366F1)),
            const SizedBox(width: 12),
            _StatChip('已完成', _reservations.where((r) => r.status == ReservationStatus.completed).length, const Color(0xFF10B981)),
          ]),
        ),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF9E9E9E),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [Tab(text: '全部'), Tab(text: '待确认'), Tab(text: '已确认'), Tab(text: '已完成')],
        ),
        Expanded(
          child: _filtered.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('暂无预约', style: TextStyle(color: Colors.grey.shade500)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ReservationCard(
                    reservation: _filtered[i],
                    onConfirm: () => _confirmReservation(context, _filtered[i]),
                    onCancel: () => _cancelReservation(context, _filtered[i]),
                    onCall: () => _callVisitor(_filtered[i].visitorPhone),
                  ),
                ),
        ),
      ]),
    );
  }

  void _confirmReservation(BuildContext context, Reservation r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('确认预约'),
        content: Text('确认 ${r.visitorName} 的看房预约？\n${r.date} ${r.time} | ${r.roomTitle}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('预约已确认'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _cancelReservation(BuildContext context, Reservation r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('取消预约'),
        content: Text('确定取消 ${r.visitorName} 的预约吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('预约已取消'), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('确认取消'),
          ),
        ],
      ),
    );
  }

  void _callVisitor(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('拨打 $phone'), behavior: SnackBarBehavior.floating),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip(this.label, this.count, this.color);
  @override Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    const SizedBox(width: 4),
    Text('$count', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
  ]);
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onCall;

  const _ReservationCard({required this.reservation, required this.onConfirm, required this.onCancel, required this.onCall});

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.roomTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(r.communityName, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: r.status.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(r.status.label, style: TextStyle(fontSize: 11, color: r.status.color, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 10),
        Row(children: [
          _InfoItem(Icons.person, r.visitorName),
          const SizedBox(width: 16),
          _InfoItem(Icons.phone, r.visitorPhone),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _InfoItem(Icons.access_time, '${r.date} ${r.time}'),
        ]),
        if (r.remark != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              Icon(Icons.note, size: 12, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(r.remark!, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ]),
          ),
        ],
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.phone, size: 16),
              label: const Text('联系客户', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 8)),
            ),
          ),
          if (r.status == ReservationStatus.pending) ...[
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close, size: 16),
                label: const Text('取消', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, padding: const EdgeInsets.symmetric(vertical: 8)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('确认预约', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 8)),
              ),
            ),
          ],
          if (r.status == ReservationStatus.confirmed)
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle, size: 16),
                label: const Text('确认带看完成', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 8)),
              ),
            ),
        ]),
      ]),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoItem(this.icon, this.text);
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: Colors.grey.shade400),
    const SizedBox(width: 4),
    Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
  ]);
}
