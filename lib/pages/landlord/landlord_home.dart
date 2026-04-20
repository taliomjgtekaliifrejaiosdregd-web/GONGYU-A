import 'package:url_launcher/url_launcher.dart';
import 'package:gongyu_guanjia/pages/room_detail_page.dart';
import 'package:gongyu_guanjia/pages/landlord/landlord_profile_page.dart';
import 'package:gongyu_guanjia/pages/landlord/landlord_device_page.dart';
import 'package:gongyu_guanjia/pages/landlord/guide_page.dart';
import 'package:gongyu_guanjia/pages/landlord/landlord_property_page.dart';
import 'package:gongyu_guanjia/pages/landlord/repair_manage_page.dart';
import 'package:gongyu_guanjia/pages/landlord/termination_manage_page.dart';
import 'package:gongyu_guanjia/pages/landlord/contract_change_page.dart';
import 'package:gongyu_guanjia/pages/landlord/electric_analysis_page.dart';
import 'package:gongyu_guanjia/pages/landlord/landlord_bill_page.dart';
import 'package:gongyu_guanjia/pages/landlord/landlord_contract_page.dart';
import 'package:gongyu_guanjia/pages/landlord/landlord_wallet_page.dart';
import 'package:gongyu_guanjia/pages/landlord/landlord_expense_page.dart';
import 'package:gongyu_guanjia/pages/landlord/landlord_acquisition_page.dart';
import 'package:gongyu_guanjia/pages/landlord/landlord_stats_page.dart';
import 'package:gongyu_guanjia/pages/landlord/landlord_reservation_page.dart';
import 'package:gongyu_guanjia/pages/landlord/landlord_checkin_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';
import 'package:gongyu_guanjia/models/device.dart';
import 'package:gongyu_guanjia/models/room.dart';

class LandlordHomePage extends StatefulWidget {
  const LandlordHomePage({super.key});
  @override State<LandlordHomePage> createState() => _LandlordHomePageState();
}
class _LandlordHomePageState extends State<LandlordHomePage> {
  String get _name => MockService.currentUser.name;

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        _buildAppBar(),
        _buildQuickActions(),
        _buildGrid(),
        _buildGuide(),
        _buildDashboard(),
        _buildAlerts(),
        _buildWorkOrders(),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ]),
    );
  }

  Widget _buildAppBar() => SliverAppBar(
    floating: true, pinned: true, expandedHeight: 130, backgroundColor: AppColors.primary, elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    flexibleSpace: FlexibleSpaceBar(background: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, Color(0xFF3451D1)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(children: [
          Row(children: [
            CircleAvatar(radius: 18, backgroundColor: Colors.white.withValues(alpha: 0.2), child: const Icon(Icons.person, color: Colors.white, size: 20)),
            const SizedBox(width: 10),
            Text(_name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            GestureDetector(onTap: () => _showNotifications(), child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24)),
          ]),
          const SizedBox(height: 14),
          GestureDetector(onTap: () => _showAISearch(), child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Row(children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Expanded(child: Text('搜房源、合同、设备...', style: TextStyle(color: AppColors.textHint, fontSize: 12))),
              const Icon(Icons.mic, color: AppColors.primary, size: 18),
            ]),
          )),
        ]),
      )),
    )),
  );

  Widget _buildQuickActions() => SliverToBoxAdapter(child: _Card(
    margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
    child: Row(children: [
      _Quick(Icons.description, '创建合同', AppColors.primary, () => _createContract()),
      _Quick(Icons.account_balance_wallet, '我的账单', AppColors.success, () => _showBills()),
      _Quick(Icons.home_work, '空房分享', AppColors.warning, () => _showShare()),
      _Quick(Icons.electric_bolt, '用电分析', AppColors.danger, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ElectricAnalysisPage()))),
    ]),
  ));

  Widget _buildGrid() => SliverToBoxAdapter(child: _Card(
    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
    padding: const EdgeInsets.all(12),
    child: Column(children: [
      Row(children: [
        _Grid(Icons.apartment, '房源管理', AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordPropertyPage()))),
        _Grid(Icons.description, '我的合同', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordContractPage()))),
        _Grid(Icons.account_balance_wallet, '我的钱包', AppColors.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordWalletPage()))),
        _Grid(Icons.receipt_long, '费用管理', AppColors.info, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordExpensePage()))),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _Grid(Icons.developer_board, '我的设备', AppColors.info, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordDevicePage()))),
        _Grid(Icons.home, '收房管理', AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordAcquisitionPage()))),
        _Grid(Icons.bar_chart, '数据统计', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordStatsPage()))),
        _Grid(Icons.calendar_month, '预定管理', AppColors.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordReservationPage()))),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _Grid(Icons.check_circle, '我的入住', AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordCheckinPage()))),
        _Grid(Icons.more_horiz, '更多', AppColors.textHint, () => _showMore()),
        const Expanded(child: SizedBox()),
        const Expanded(child: SizedBox()),
      ]),
    ]),
  ));

  Widget _buildGuide() => SliverToBoxAdapter(child: _Card(
    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    child: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidePage())), behavior: HitTestBehavior.opaque, child: Row(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), child: const Text('新手指引', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
      const SizedBox(width: 10),
      const Expanded(child: Text('点击进入智慧房东使用教程', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
      const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
    ])),
  ));

  Widget _buildDashboard() => SliverToBoxAdapter(child: _Card(
    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
    title: '数据看板',
    child: Column(children: [
      Row(children: [_Stat('近30日合同即将到期', '5', '户', AppColors.warning, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordContractPage()))), const SizedBox(width: 8), _Stat('合同逾期数量', '2', '户', AppColors.danger, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordContractPage())))]),
      const SizedBox(height: 10),
      Row(children: [_Stat('近30日待收金额', '12.8', '万元', AppColors.success, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordBillPage()))), const SizedBox(width: 8), _Stat('其中逾期', '0.3', '万元', AppColors.danger, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordBillPage())))]),
      const Divider(height: 24),
      Row(children: [Expanded(child: _Mini('全部房源', '24户', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordPropertyPage())))), Expanded(child: _Mini('已租', '18户', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordPropertyPage())))), Expanded(child: _Mini('空置', '6户', AppColors.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordPropertyPage()))))]),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: _Mini('出租率', '75%', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordStatsPage())))), Expanded(child: _Mini('续签率', '82%', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordStatsPage())))), Expanded(child: _Mini('收房均价', '4200元/月', null, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordStatsPage()))))]),
    ]),
  ));

  Widget _buildAlerts() => SliverToBoxAdapter(child: _Card(
    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
    title: '异常提醒',
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
    child: Column(children: [
      _Alert(Icons.electric_bolt, '电表不足5度', '陆家嘴花园整租', AppColors.danger),
      _Alert(Icons.power_off, '电表离线', '浦东大道合租', AppColors.danger),
      _Alert(Icons.water_drop, '水表不足1吨', '前滩公寓', AppColors.warning),
      _Alert(Icons.lock, '门锁电量不足', '静安寺整租', AppColors.warning),
      _Alert(Icons.ac_unit, '门锁冻结', '徐家汇合租', AppColors.danger),
    ]),
  ));

  Widget _buildWorkOrders() => SliverToBoxAdapter(child: _Card(
    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
    title: '待办工单',
    child: Row(children: [
      _Work(Icons.exit_to_app, '退租审批', '3', AppColors.danger, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminationManagePage()))),
      _Work(Icons.receipt_long, '账单审批', '5', AppColors.warning, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandlordBillPage()))),
      _Work(Icons.description, '合同审批', '2', AppColors.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContractChangePage()))),
      _Work(Icons.build, '在线维修', '4', AppColors.success, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RepairManagePage()))),
    ]),
  ));

  void _showNotifications() {
    final alerts = MockService.getAlerts();
    showModalBottomSheet(context: context, backgroundColor: Colors.white, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (_) => DraggableScrollableSheet(initialChildSize: 0.7, minChildSize: 0.5, maxChildSize: 0.95, expand: false, builder: (_, sc) => Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('消息通知', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))])),
      const Divider(height: 1),
      Expanded(child: ListView.builder(controller: sc, itemCount: alerts.length, itemBuilder: (_, i) {
        final a = alerts[i];
        return ListTile(leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: a.level == AlertLevel.critical ? AppColors.danger.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.warning_amber_rounded, color: a.level == AlertLevel.critical ? AppColors.danger : AppColors.warning, size: 20)), title: Text(a.message), subtitle: Text(a.roomTitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)));
      })),
    ])));
  }

  void _showAISearch() {
    showModalBottomSheet(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (_) => Container(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('AI 智能搜索', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [Chip(avatar: const Icon(Icons.apartment, size: 16), label: const Text('搜房源')), Chip(avatar: const Icon(Icons.description, size: 16), label: const Text('搜合同')), Chip(avatar: const Icon(Icons.developer_board, size: 16), label: const Text('搜设备')), Chip(avatar: const Icon(Icons.person, size: 16), label: const Text('搜租客'))]),
      const SizedBox(height: 16),
      TextField(decoration: InputDecoration(hintText: '输入关键词搜索...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    ])));
  }

  void _createContract() {
    showModalBottomSheet(context: context, backgroundColor: Colors.white, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (_) => DraggableScrollableSheet(initialChildSize: 0.8, minChildSize: 0.5, maxChildSize: 0.95, expand: false, builder: (_, sc) => Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('创建合同', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))])),
      const Divider(height: 1),
      Expanded(child: ListView(controller: sc, padding: const EdgeInsets.all(16), children: [
        const Text('选择房源', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...MockService.rooms.where((r) => r.status == RoomStatus.available).map((r) => ListTile(title: Text(r.title), subtitle: Text(r.communityName + ' | ' + r.layout), trailing: Text(r.price.toString() + '元/月'), onTap: () {})),
        const SizedBox(height: 16),
        const Text('选择合同模板', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...['标准租赁合同', '商业租赁合同', '公寓托管合同', '合租协议'].map((t) => ListTile(title: Text(t), trailing: const Icon(Icons.chevron_right), onTap: () {})),
      ])),
    ])));
  }

  void _showBills() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('我的账单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF818CF8)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('本月待收', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                const Text('¥12,800', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('逾期', style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 4),
                Text('¥300', style: TextStyle(color: Colors.red.shade200, fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.receipt_long, size: 18), label: const Text('账单明细')),
            const SizedBox(width: 8),
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.merge_type, size: 18), label: const Text('合并账单')),
            const SizedBox(width: 8),
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.bar_chart, size: 18), label: const Text('收支报表')),
          ]),
        ]),
      ),
    );
  }

  void _showShare() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _VacantRoomShareSheet(
        onRoomTap: (room) {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => RoomDetailPage(room: room),
          ));
        },
      ),
    );
  }

  void _showMore() {
    showModalBottomSheet(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (_) => Container(padding: const EdgeInsets.all(16), child: GridView.count(
      crossAxisCount: 4, shrinkWrap: true, mainAxisSpacing: 16, crossAxisSpacing: 16,
      children: const [_More(Icons.electrical_services, '增值服务'), _More(Icons.ev_station, '充电桩'), _More(Icons.map_outlined, '用户地图'), _More(Icons.person_outline, '用户画像'), _More(Icons.menu_book, '操作指南'), _More(Icons.fact_check, '租赁审批'), _More(Icons.edit, '编辑'), _More(Icons.more_horiz, '更多')],
    )));
  }
}




class _VacantRoomShareSheet extends StatefulWidget {
  final void Function(Room room) onRoomTap;

  const _VacantRoomShareSheet({required this.onRoomTap});

  @override
  State<_VacantRoomShareSheet> createState() => _VacantRoomShareSheetState();
}

class _VacantRoomShareSheetState extends State<_VacantRoomShareSheet> {
  String _typeFilter = '全部';
  String _statusFilter = '未出租';

  List<Room> get _filteredRooms {
    var rooms = MockService.rooms.where((r) {
      if (_statusFilter == '未出租') return r.status == RoomStatus.available;
      if (_statusFilter == '已出租') return r.status == RoomStatus.rented;
      if (_statusFilter == '预定中') return r.status == RoomStatus.reserved;
      return true;
    }).toList();

    if (_typeFilter == '整租') rooms = rooms.where((r) => r.type == RoomType.whole).toList();
    if (_typeFilter == '合租') rooms = rooms.where((r) => r.type == RoomType.shared).toList();
    if (_typeFilter == '独栋') rooms = rooms.where((r) => r.type == RoomType.building).toList();

    return rooms;
  }

  String _shareText(Room room) {
    return '${room.title}\n${room.layout} · ${room.area.toStringAsFixed(0)}㎡\n月租 ¥${room.price.toStringAsFixed(0)}元/月\n地址：${room.address}\n点击查看详情 →';
  }

  String _shareUrl(Room room) {
    return 'https://example.com/room/' + room.id.toString();
  }

  Future<void> _share(Room room) async {
    final text = _shareText(room);
    final url = _shareUrl(room);

    showDialog(context: context, barrierDismissible: true, builder: (_) => _ShareDialog(
      room: room,
      text: text,
      url: url,
      onSelected: (app) async {
        Navigator.pop(context); // close dialog
        if (app == 'wechat') {
          // 微信没有网页分享API，尝试打开微信
          final uri = Uri.parse('weixin://');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) {
              _copyToClipboard(context, text + '\n' + url);
            }
          }
        } else if (app == 'moments') {
          final uri = Uri.parse('weixin://');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) _copyToClipboard(context, text + '\n' + url);
          }
        } else if (app == 'qq') {
          final uri = Uri.parse('mqqapi://');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) _copyToClipboard(context, text + '\n' + url);
          }
        } else if (app == 'sms') {
          final uri = Uri.parse('sms:?body=' + Uri.encodeComponent(text + '\n' + url));
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        } else if (app == 'copy') {
          if (mounted) _copyToClipboard(context, text + '\n链接：' + url);
        }
        // Navigate to room detail after sharing
        widget.onRoomTap(room);
      },
    ));
  }

  void _copyToClipboard(BuildContext context, String text) {
    // Use Flutter's clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('链接已复制到剪贴板'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = _filteredRooms;
    final vacantCount = MockService.rooms.where((r) => r.status == RoomStatus.available).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.home_work, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              const Text('空房分享', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('$vacantCount 套可分享', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
              ),
            ]),
          ]),
        ),
        // Filters
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            // Type filter
            Row(children: [
              Text('类型：', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(width: 8),
              ...['全部', '整租', '合租', '独栋'].map((t) => Padding(padding: const EdgeInsets.only(right: 6), child: FilterChip(
                label: Text(t, style: TextStyle(fontSize: 11, color: _typeFilter == t ? Colors.white : Colors.black87)),
                selected: _typeFilter == t,
                selectedColor: const Color(0xFF6366F1),
                backgroundColor: const Color(0xFFF5F5F5),
                onSelected: (_) => setState(() => _typeFilter = t),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ))),
            ]),
            const SizedBox(height: 8),
            // Status filter
            Row(children: [
              Text('状态：', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(width: 8),
              ...['未出租', '已出租', '预定中'].map((s) => Padding(padding: const EdgeInsets.only(right: 6), child: FilterChip(
                label: Text(s, style: TextStyle(fontSize: 11, color: _statusFilter == s ? Colors.white : Colors.black87)),
                selected: _statusFilter == s,
                selectedColor: const Color(0xFF6366F1),
                backgroundColor: const Color(0xFFF5F5F5),
                onSelected: (_) => setState(() => _statusFilter = s),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ))),
            ]),
          ]),
        ),
        const Divider(height: 20),
        // Room list
        Expanded(
          child: rooms.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.home_outlined, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('暂无符合条件的房源', style: TextStyle(color: Colors.grey.shade500)),
                ]))
              : ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: rooms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _RoomShareCard(
                    room: rooms[i],
                    onTap: () => widget.onRoomTap(rooms[i]),
                    onShare: () => _share(rooms[i]),
                  ),
                ),
        ),
      ]),
    );
  }
}

// ============================================================
// 单个房源分享卡片
// ============================================================
class _RoomShareCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const _RoomShareCard({required this.room, required this.onTap, required this.onShare});

  @override
  Widget build(BuildContext context) {
    final statusColor = room.status == RoomStatus.available
        ? const Color(0xFF10B981)
        : room.status == RoomStatus.reserved
            ? const Color(0xFFF59E0B)
            : const Color(0xFF9E9E9E);
    final statusLabel = room.status == RoomStatus.available
        ? '可出租'
        : room.status == RoomStatus.reserved ? '预定中' : '已出租';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          // 图片
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(children: [
              Container(
                height: 160,
                width: double.infinity,
                color: const Color(0xFFEEEEEE),
                child: room.images.isNotEmpty
                    ? Image.network(room.images.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Icon(Icons.home, size: 48, color: Colors.grey.shade400)))
                    : Center(child: Icon(Icons.home, size: 48, color: Colors.grey.shade400)),
              ),
              // Status badge
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
                  child: Text(statusLabel, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
              // Price
              Positioned(
                bottom: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                  child: Text('¥' + room.price.toStringAsFixed(0) + '/月', style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Row(children: [
                Expanded(child: Text(room.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(room.type == RoomType.whole ? '整租' : room.type == RoomType.shared ? '合租' : '独栋', style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1))),
                ),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 2),
                Expanded(child: Text(room.address, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                _InfoTag(Icons.straighten, room.area.toStringAsFixed(0) + '㎡'),
                const SizedBox(width: 8),
                _InfoTag(Icons.bed_outlined, room.layout),
                const Spacer(),
                // 转发分享按钮
                GestureDetector(
                  onTap: onShare,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF07C160).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.share, size: 14, color: const Color(0xFF07C160)),
                      const SizedBox(width: 4),
                      const Text('转发', style: TextStyle(fontSize: 12, color: Color(0xFF07C160), fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                // 查看详情按钮
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: const Text('详情 →', style: TextStyle(fontSize: 12, color: Color(0xFF6366F1), fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoTag(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: Colors.grey.shade500),
    const SizedBox(width: 2),
    Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
  ]);
}

// ============================================================
// 分享弹窗
// ============================================================
class _ShareDialog extends StatelessWidget {
  final Room room;
  final String text;
  final String url;
  final void Function(String app) onSelected;

  const _ShareDialog({required this.room, required this.text, required this.url, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    // Show a mini share card with room image and share options
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Preview
          if (room.images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(room.images.first, height: 140, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 140, color: const Color(0xFFEEEEEE))),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Text(room.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('¥' + room.price.toStringAsFixed(0) + '/月 · ' + room.layout, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
              const SizedBox(height: 16),
              const Text('分享到', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              // Share options
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _ShareBtn(Icons.chat, '微信', const Color(0xFF07C160), () => onSelected('wechat')),
                _ShareBtn(Icons.group, '朋友圈', const Color(0xFF07C160), () => onSelected('moments')),
                _ShareBtn(Icons.tag, 'QQ', const Color(0xFF1296DB), () => onSelected('qq')),
                _ShareBtn(Icons.sms, '短信', const Color(0xFFFF9500), () => onSelected('sms')),
                _ShareBtn(Icons.link, '复制', const Color(0xFF6366F1), () => onSelected('copy')),
              ]),
            ]),
          ),
          const Divider(height: 1),
          TextButton(onPressed: () { Navigator.pop(context); }, child: const Text('取消', style: TextStyle(color: Color(0xFF9E9E9E)))),
        ]),
      ),
    );
  }
}

class _ShareBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ShareBtn(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(width: 48, height: 48,
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
    ]),
  );
}



// ==================== 共享组件 ====================

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final String? title;
  const _Card({required this.child, this.margin, this.padding, this.title});
  @override Widget build(BuildContext context) => Container(
    margin: margin ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    padding: padding ?? const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (title != null) ...[Text(title!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 12)], child]),
  ); }

class _Quick extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _Quick(this.icon, this.label, this.color, this.onTap);
  @override Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap, child: Column(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)), const SizedBox(height: 6), Text(label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center)]))); }

class _Grid extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback? onTap;
  const _Grid(this.icon, this.label, this.color, [this.onTap]);
  @override Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap ?? () {}, child: Column(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 22)), const SizedBox(height: 5), Text(label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)]))); }

class _Stat extends StatelessWidget {
  final String label; final String v; final String u; final Color color;
  final VoidCallback? onTap;
  const _Stat(this.label, this.v, this.u, this.color, {this.onTap});
  @override Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), Text(u, style: TextStyle(fontSize: 11, color: color))]), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600))])))); }

class _Mini extends StatelessWidget {
  final String label; final String v; final Color? color;
  final VoidCallback? onTap;
  const _Mini(this.label, this.v, [this.color, this.onTap]);
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Column(children: [Text(v, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color ?? AppColors.primary)), Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600))])); }

class _Alert extends StatelessWidget {
  final IconData icon; final String title; final String sub; final Color color;
  const _Alert(this.icon, this.title, this.sub, this.color);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey.shade600))])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text('查看', style: TextStyle(fontSize: 10, color: color)))])); }

class _Work extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;
  final VoidCallback? onTap;
  const _Work(this.icon, this.label, this.count, this.color, {this.onTap});
  @override Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Expanded(
              child: Column(children: [
                Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Icon(icon, color: color, size: 18),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _More extends StatelessWidget {
  final IconData icon;
  final String label;
  const _More(this.icon, this.label);
  @override Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700), textAlign: TextAlign.center),
    ]);
  }
}


// 房东端底部导航包装器（4个Tab）
class LandlordHomeWrapper extends StatefulWidget {
  const LandlordHomeWrapper({super.key});
  @override
  State<LandlordHomeWrapper> createState() => _LandlordHomeWrapperState();
}

class _LandlordHomeWrapperState extends State<LandlordHomeWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    LandlordHomePage(),
    LandlordPropertyPage(),
    LandlordDevicePage(),
    LandlordProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _NavBarItem(Icons.home_outlined, Icons.home, '首页', 0),
                _NavBarItem(Icons.apartment_outlined, Icons.apartment, '房源', 1),
                _NavBarItem(Icons.developer_board_outlined, Icons.developer_board, '设备', 2),
                _NavBarItem(Icons.person_outline, Icons.person, '我的', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _NavBarItem(IconData icon, IconData activeIcon, String label, int index) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.primary : AppColors.textHint,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

// ============================================================
// 空房分享 BottomSheet
// ============================================================

}