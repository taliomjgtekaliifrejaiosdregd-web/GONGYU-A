import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

/// 收房状态
enum AcquisitionStatus {
  pending('待审核', Color(0xFFF59E0B)),
  active('托管中', Color(0xFF10B981)),
  paused('暂停托管', Color(0xFF9E9E9E)),
  terminated('已解约', Color(0xFFEF4444));

  final String label;
  final Color color;
  const AcquisitionStatus(this.label, this.color);
}

/// 收房记录
class Acquisition {
  final String id;
  final String communityName;
  final String address;
  final String ownerName;
  final String ownerPhone;
  final AcquisitionStatus status;
  final double monthlyRent;    // 收房月租（付给房东）
  final double marketRent;     // 市场价格
  final String startDate;
  final int totalRooms;
  final int rentedRooms;

  const Acquisition({
    required this.id,
    required this.communityName,
    required this.address,
    required this.ownerName,
    required this.ownerPhone,
    required this.status,
    required this.monthlyRent,
    required this.marketRent,
    required this.startDate,
    required this.totalRooms,
    required this.rentedRooms,
  });
}

/// ============================================================
// 房东端 - 收房管理（房源托管）
// ============================================================
class LandlordAcquisitionPage extends StatefulWidget {
  const LandlordAcquisitionPage({super.key});

  @override
  State<LandlordAcquisitionPage> createState() => _LandlordAcquisitionPageState();
}

class _LandlordAcquisitionPageState extends State<LandlordAcquisitionPage> {
  AcquisitionStatus? _filterStatus;

  // Mock收房数据
  final List<Acquisition> _acquisitions = [
    const Acquisition(
      id: 'ACQ001', communityName: '陆家嘴花园', address: '浦东新区陆家嘴路199号',
      ownerName: '王先生', ownerPhone: '13800138001',
      status: AcquisitionStatus.active,
      monthlyRent: 4500, marketRent: 5800,
      startDate: '2024-01-01', totalRooms: 3, rentedRooms: 2,
    ),
    const Acquisition(
      id: 'ACQ002', communityName: '浦东大道公寓', address: '浦东新区浦东大道1000号',
      ownerName: '李女士', ownerPhone: '13900139002',
      status: AcquisitionStatus.active,
      monthlyRent: 2800, marketRent: 3200,
      startDate: '2024-02-01', totalRooms: 2, rentedRooms: 2,
    ),
    const Acquisition(
      id: 'ACQ003', communityName: '静安公馆', address: '静安区南京西路200号',
      ownerName: '赵先生', ownerPhone: '13700137003',
      status: AcquisitionStatus.paused,
      monthlyRent: 10000, marketRent: 12000,
      startDate: '2023-09-01', totalRooms: 5, rentedRooms: 0,
    ),
    const Acquisition(
      id: 'ACQ004', communityName: '徐家汇精品公寓', address: '徐汇区漕溪北路88号',
      ownerName: '陈先生', ownerPhone: '13600136004',
      status: AcquisitionStatus.pending,
      monthlyRent: 5800, marketRent: 6800,
      startDate: '2026-04-20', totalRooms: 2, rentedRooms: 0,
    ),
    const Acquisition(
      id: 'ACQ005', communityName: '前滩小区', address: '浦东新区前滩路88号',
      ownerName: '刘先生', ownerPhone: '13500135005',
      status: AcquisitionStatus.terminated,
      monthlyRent: 3800, marketRent: 4500,
      startDate: '2023-06-01', totalRooms: 1, rentedRooms: 0,
    ),
  ];

  List<Acquisition> get _filtered {
    if (_filterStatus == null) return _acquisitions;
    return _acquisitions.where((a) => a.status == _filterStatus).toList();
  }

  double get _totalMonthlyRent => _acquisitions
      .where((a) => a.status == AcquisitionStatus.active)
      .fold(0.0, (s, a) => s + a.monthlyRent);

  int get _activeCount => _acquisitions.where((a) => a.status == AcquisitionStatus.active).length;
  int get _pendingCount => _acquisitions.where((a) => a.status == AcquisitionStatus.pending).length;

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
        title: const Text('收房管理', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _showAddAcquisition(context),
          ),
        ],
      ),
      body: Column(children: [
        // 统计卡片
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('托管中', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text('$_activeCount 个房源', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('月成本 ¥${0}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                ]),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('待审核', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12)),
                  const SizedBox(height: 6),
                  Text('$_pendingCount 个房源', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('月成本 ¥${0}', style: TextStyle(color: Colors.orange.shade300, fontSize: 11)),
                ]),
              ),
            ),
          ]),
        ),

        // 筛选
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: Row(children: [
            const Text('状态：', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('全部', style: TextStyle(fontSize: 11)),
              selected: _filterStatus == null,
              selectedColor: AppColors.primary,
              backgroundColor: const Color(0xFFF5F5F5),
              labelStyle: TextStyle(fontSize: 11, color: _filterStatus == null ? Colors.white : Colors.black87),
              onSelected: (_) => setState(() => _filterStatus = null),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
            ...AcquisitionStatus.values.where((s) => s != AcquisitionStatus.terminated).map((s) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(s.label, style: TextStyle(fontSize: 11, color: _filterStatus == s ? Colors.white : Colors.black87)),
                selected: _filterStatus == s,
                selectedColor: s.color,
                backgroundColor: const Color(0xFFF5F5F5),
                onSelected: (_) => setState(() => _filterStatus = s),
                visualDensity: VisualDensity.compact,
              ),
            )),
          ]),
        ),

        const Divider(height: 1),

        // 列表
        Expanded(
          child: _filtered.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.home_work_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('暂无收房记录', style: TextStyle(color: Colors.grey.shade500)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _AcquisitionCard(
                    acquisition: _filtered[i],
                    onTap: () => _showDetail(context, _filtered[i]),
                    onAction: () => _showAction(context, _filtered[i]),
                  ),
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAcquisition(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('新增收房', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showDetail(BuildContext context, Acquisition a) {
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
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.home_work, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.communityName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(a.address, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: a.status.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(a.status.label, style: TextStyle(fontSize: 11, color: a.status.color, fontWeight: FontWeight.w600)),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(controller: sc, padding: const EdgeInsets.all(16), children: [
              // 收益对比卡片
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Expanded(child: _StatCol('收房月租', '¥${a.monthlyRent}', const Color(0xFFEF4444))),
                  Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
                  Expanded(child: _StatCol('市场月租', '¥${a.marketRent}', const Color(0xFF10B981))),
                  Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
                  Expanded(child: _StatCol('差价收益', '¥${a.marketRent - a.monthlyRent}', const Color(0xFF6366F1))),
                ]),
              ),
              const SizedBox(height: 16),
              _DetailRow('房源编号', a.id),
              _DetailRow('小区', a.communityName),
              _DetailRow('地址', a.address),
              _DetailRow('房东姓名', a.ownerName),
              _DetailRow('房东电话', a.ownerPhone),
              _DetailRow('托管起始', a.startDate),
              _DetailRow('总房间数', '${a.totalRooms}间'),
              _DetailRow('已出租', '${a.rentedRooms}间'),
              _DetailRow('空置', '${a.totalRooms - a.rentedRooms}间'),
              const SizedBox(height: 16),
              // 操作
              if (a.status == AcquisitionStatus.pending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () { Navigator.pop(context); _showAction(context, a); },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text('审核通过', style: TextStyle(color: Colors.white)),
                  ),
                ),
              if (a.status == AcquisitionStatus.active)
                Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.warning, padding: const EdgeInsets.symmetric(vertical: 10)),
                    child: const Text('暂停托管'),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, padding: const EdgeInsets.symmetric(vertical: 10)),
                    child: const Text('解除托管'),
                  )),
                ]),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showAction(BuildContext context, Acquisition a) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(a.communityName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (a.status == AcquisitionStatus.pending) ...[
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.check_circle, color: Color(0xFF10B981))),
              title: const Text('审核通过'),
              subtitle: const Text('确认收房合同，正式开始托管'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('收房审核已通过'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)));
              },
            ),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.cancel, color: Color(0xFFEF4444))),
              title: const Text('拒绝收房'),
              subtitle: const Text('拒绝此次收房申请'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已拒绝收房申请'), behavior: SnackBarBehavior.floating));
              },
            ),
          ],
          if (a.status == AcquisitionStatus.active) ...[
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.pause_circle, color: Color(0xFFF59E0B))),
              title: const Text('暂停托管'),
              subtitle: const Text('暂时停止此房源的托管服务'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('托管已暂停'), behavior: SnackBarBehavior.floating));
              },
            ),
            ListTile(
              leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.cancel, color: Color(0xFFEF4444))),
              title: const Text('解除托管'),
              subtitle: const Text('终止与房东的托管合同'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('托管已解除'), behavior: SnackBarBehavior.floating));
              },
            ),
          ],
        ]),
      ),
    );
  }

  void _showAddAcquisition(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('新增收房', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('录入房东委托托管的房源信息', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          const Text('小区名称', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(decoration: const InputDecoration(hintText: '请输入小区名称', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('收房月租', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '¥0', border: OutlineInputBorder())),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('房间数量', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '0间', border: OutlineInputBorder())),
            ])),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('收房信息已录入，等待房东确认'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF10B981)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              child: const Text('提交', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _AcquisitionCard extends StatelessWidget {
  final Acquisition acquisition;
  final VoidCallback onTap;
  final VoidCallback onAction;
  const _AcquisitionCard({required this.acquisition, required this.onTap, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final a = acquisition;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              child: const Icon(Icons.home_work, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.communityName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(a.address, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: a.status.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(a.status.label, style: TextStyle(fontSize: 11, color: a.status.color, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(children: [
            _InfoPill(Icons.person, a.ownerName),
            const SizedBox(width: 8),
            _InfoPill(Icons.door_front_door, '${a.totalRooms}间/${a.rentedRooms}已租'),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('收房 ¥${a.monthlyRent}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
              Text('市场 ¥${a.marketRent}', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            ]),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: a.status.color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Text(a.status == AcquisitionStatus.pending ? '审核' : '操作', style: TextStyle(fontSize: 11, color: a.status.color, fontWeight: FontWeight.w500)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoPill(this.icon, this.text);
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: Colors.grey.shade400),
    const SizedBox(width: 4),
    Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
  ]);
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCol(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Column(children: [
    Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
  ]);
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
    ]),
  );
}
