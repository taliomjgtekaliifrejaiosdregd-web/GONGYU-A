import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/room.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';

/// 报修类型枚举
enum RepairType {
  waterMeter('水表问题', Icons.water_drop, Color(0xFF06B6D4)),
  electricMeter('电表问题', Icons.electric_bolt, Color(0xFFF59E0B)),
  smartLock('门锁问题', Icons.lock, Color(0xFF6366F1)),
  other('其他问题', Icons.build, Color(0xFF9E9E9E));

  final String label;
  final IconData icon;
  final Color color;
  const RepairType(this.label, this.icon, this.color);
}

/// 报修工单状态
enum RepairStatus {
  pending('待处理', Color(0xFFF59E0B)),
  assigned('已派单', Color(0xFF06B6D4)),
  processing('处理中', Color(0xFF6366F1)),
  completed('已完成', Color(0xFF10B981)),
  cancelled('已取消', Color(0xFF9E9E9E));

  final String label;
  final Color color;
  const RepairStatus(this.label, this.color);
}

/// 报修数据模型
class RepairOrder {
  final String id;
  final RepairType type;
  final RepairStatus status;
  final String title;
  final String description;
  final String roomTitle;
  final String createdAt;
  final String? handlerName;
  final String? handlerPhone;
  final String? remark;

  const RepairOrder({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    required this.roomTitle,
    required this.createdAt,
    this.handlerName,
    this.handlerPhone,
    this.remark,
  });
}

/// ============================================================
/// 租客 - 报修提交页面
/// ============================================================
class RepairReportPage extends StatefulWidget {
  const RepairReportPage({super.key});

  @override
  State<RepairReportPage> createState() => _RepairReportPageState();
}

class _RepairReportPageState extends State<RepairReportPage> {
  int _currentIndex = 0; // 0=提交报修, 1=我的工单

  // 提交表单状态
  RepairType? _selectedType;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _images = <String>[]; // 模拟图片路径
  bool _isUrgent = false;

  // Mock我的工单数据
  final List<RepairOrder> _myOrders = [
    RepairOrder(
      id: 'WO20260415001',
      type: RepairType.waterMeter,
      status: RepairStatus.processing,
      title: '水表不走字',
      description: '水表有时候不走字，计量不准。',
      roomTitle: '陆家嘴花园整租',
      createdAt: '2026-04-15 09:30',
      handlerName: '张师傅',
      handlerPhone: '13800138001',
    ),
    RepairOrder(
      id: 'WO20260412002',
      type: RepairType.smartLock,
      status: RepairStatus.completed,
      title: '门锁密码无法识别',
      description: '密码指纹都能用，就是密码开不了门。',
      roomTitle: '陆家嘴花园整租',
      createdAt: '2026-04-12 14:20',
      handlerName: '李师傅',
      handlerPhone: '13900139002',
      remark: '已更换门锁面板，问题解决。',
    ),
    RepairOrder(
      id: 'WO20260410003',
      type: RepairType.electricMeter,
      status: RepairStatus.pending,
      title: '电表充值后不到账',
      description: '4月10日充值了100元，但电表余额没有增加。',
      roomTitle: '陆家嘴花园整租',
      createdAt: '2026-04-10 18:45',
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

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
        title: const Text('报修服务', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _showRepairHistory(context),
            child: const Text('报修记录', style: TextStyle(fontSize: 13, color: Color(0xFF6366F1))),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab切换
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _TabBtn('提交报修', _currentIndex == 0, () => setState(() => _currentIndex = 0)),
                const SizedBox(width: 16),
                _TabBtn('我的工单', _currentIndex == 1, () => setState(() => _currentIndex = 1), badge: _myOrders.where((o) => o.status != RepairStatus.completed && o.status != RepairStatus.cancelled).length),
              ],
            ),
          ),
          Expanded(
            child: _currentIndex == 0 ? _buildReportForm() : _buildMyOrders(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 报修类型选择
          _SectionTitle('报修类型'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: RepairType.values.map((t) => _TypeCard(
              type: t,
              selected: _selectedType == t,
              onTap: () => setState(() => _selectedType = t),
            )).toList(),
          ),

          const SizedBox(height: 20),

          // 报修房源
          _SectionTitle('报修房源'),
          const SizedBox(height: 10),
          _RoomSelector(
            roomTitle: '陆家嘴花园整租',
            address: '陆家嘴路199号1号楼1单元101',
            onTap: () => _showRoomPicker(),
          ),

          const SizedBox(height: 20),

          // 报修标题
          _SectionTitle('报修标题'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '一句话描述问题，如：水表不走字',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),

          const SizedBox(height: 20),

          // 问题描述
          _SectionTitle('问题描述'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '详细描述故障情况，帮助师傅更快定位问题...',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),

          const SizedBox(height: 20),

          // 上传图片
          _SectionTitle('上传图片（选填）'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0), style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                if (_images.isEmpty)
                  GestureDetector(
                    onTap: _addImage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('点击上传图片', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          const SizedBox(height: 4),
                          Text('最多上传3张', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                        ],
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      ..._images.map((img) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E8E8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                            Positioned(
                              top: -4, right: -4,
                              child: GestureDetector(
                                onTap: () => setState(() => _images.remove(img)),
                                child: Container(
                                  width: 20, height: 20,
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      if (_images.length < 3)
                        GestureDetector(
                          onTap: _addImage,
                          child: Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Icon(Icons.add, color: Colors.grey.shade400),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 紧急程度
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(_isUrgent ? Icons.warning_amber_rounded : Icons.warning_amber_outlined,
                    color: _isUrgent ? const Color(0xFFEF4444) : const Color(0xFFBDBDBD)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_isUrgent ? '紧急报修' : '普通报修', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(_isUrgent ? '师傅将在2小时内优先处理' : '师傅将在24小时内处理',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Switch(
                  value: _isUrgent,
                  activeColor: const Color(0xFFEF4444),
                  onChanged: (v) => setState(() => _isUrgent = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 联系电话
          _SectionTitle('联系电话'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '请输入手机号',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
                prefixIcon: Icon(Icons.phone_outlined, size: 18, color: Color(0xFF6366F1)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),

          const SizedBox(height: 32),

          // 提交按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submitRepair : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                disabledBackgroundColor: const Color(0xFFE0E0E0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('提交报修', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMyOrders() {
    if (_myOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('暂无报修工单', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _myOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _OrderCard(order: _myOrders[i]),
    );
  }

  bool get _canSubmit => _selectedType != null && _titleController.text.isNotEmpty && _descController.text.isNotEmpty;

  void _addImage() {
    if (_images.length >= 3) return;
    // 模拟：随机加一个占位图
    setState(() => _images.add('img_${DateTime.now().millisecondsSinceEpoch}'));
  }

  void _showRoomPicker() {
    final rooms = MockService.rooms.where((r) => r.status == RoomStatus.rented).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择报修房源', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...rooms.map((r) => ListTile(
              dense: true,
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.home, color: Color(0xFF6366F1), size: 20),
              ),
              title: Text(r.title, style: const TextStyle(fontSize: 13)),
              subtitle: Text(r.address, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              onTap: () => Navigator.pop(context),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRepairHistory(BuildContext context) {
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
              const Text('历史报修', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              controller: sc,
              padding: const EdgeInsets.all(16),
              itemCount: _myOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _OrderCard(order: _myOrders[i]),
            ),
          ),
        ]),
      ),
    );
  }

  void _submitRepair() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
          ),
          const SizedBox(width: 10),
          const Text('提交成功'),
        ]),
        content: const Text('报修工单已提交，师傅将尽快与您联系！\n\n您可以在"我的工单"中实时查看处理进度。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedType = null;
                _titleController.clear();
                _descController.clear();
                _images.clear();
                _isUrgent = false;
                _currentIndex = 1; // 切到我的工单
              });
            },
            child: const Text('查看我的工单'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// 报修工单卡片
/// ============================================================
class _OrderCard extends StatelessWidget {
  final RepairOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOrderDetail(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部行
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: order.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(order.status.label, style: TextStyle(fontSize: 10, color: order.status.color, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text(order.id, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
            ]),
            const SizedBox(height: 10),
            // 标题
            Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: order.type.color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Icon(order.type.icon, size: 15, color: order.type.color),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(order.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 8),
            // 描述
            Text(order.description, style: const TextStyle(fontSize: 11, color: Color(0xFF757575)), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            // 底部分类信息
            Row(children: [
              Icon(Icons.home, size: 12, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(order.roomTitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              const Spacer(),
              Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(order.createdAt, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ]),
            // 处理人信息
            if (order.handlerName != null) ...[
              const Divider(height: 16),
              Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.person, size: 15, color: Color(0xFF6366F1)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('处理师傅：${order.handlerName}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  if (order.handlerPhone != null)
                    Text(order.handlerPhone!, style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1))),
                ])),
                if (order.status == RepairStatus.processing || order.status == RepairStatus.assigned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text('联系师傅', style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w500)),
                  ),
              ]),
            ],
            // 完成备注
            if (order.remark != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(order.remark!, style: const TextStyle(fontSize: 11, color: Color(0xFF10B981)))),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showOrderDetail(BuildContext context) {
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
                width: 36, height: 36,
                decoration: BoxDecoration(color: order.type.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(order.type.icon, color: order.type.color),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: order.status.color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(order.status.label, style: TextStyle(fontSize: 10, color: order.status.color, fontWeight: FontWeight.w600)),
                ),
              ])),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(controller: sc, padding: const EdgeInsets.all(16), children: [
              // 工单信息
              _DetailRow('工单编号', order.id),
              _DetailRow('报修类型', order.type.label),
              _DetailRow('报修房源', order.roomTitle),
              _DetailRow('提交时间', order.createdAt),
              _DetailRow('问题描述', order.description),
              if (order.handlerName != null) _DetailRow('处理师傅', '${order.handlerName} ${order.handlerPhone ?? ''}'),
              if (order.remark != null) _DetailRow('处理备注', order.remark!),
              const SizedBox(height: 16),
              // 进度时间轴
              const Text('处理进度', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _Timeline(
                items: [
                  _TimelineItem('提交报修', order.createdAt, true),
                  if (order.status != RepairStatus.pending) _TimelineItem('师傅接单', _getAssignTime(order), true),
                  if (order.status == RepairStatus.processing) _TimelineItem('上门处理中', '', true),
                  if (order.status == RepairStatus.completed) _TimelineItem('已完成', _getCompleteTime(order), true),
                ],
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  String _getAssignTime(RepairOrder o) => '2026-04-15 10:00';
  String _getCompleteTime(RepairOrder o) => '2026-04-12 16:30';
}

class _TimelineItem {
  final String label;
  final String time;
  final bool done;
  const _TimelineItem(this.label, this.time, this.done);
}

class _Timeline extends StatelessWidget {
  final List<_TimelineItem> items;
  const _Timeline({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length * 2 - 1, (i) {
        if (i.isOdd) {
          // 连接线
          return Container(
            width: 2,
            height: 20,
            margin: const EdgeInsets.only(left: 9),
            color: const Color(0xFF6366F1).withOpacity(0.3),
          );
        }
        final item = items[i ~/ 2];
        return Row(children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: item.done ? const Color(0xFF6366F1) : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(item.label, style: TextStyle(fontSize: 12, color: item.done ? Colors.black87 : Colors.grey))),
          if (item.time.isNotEmpty)
            Text(item.time, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ]);
      }),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 80,
        child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
      ),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
    ]),
  );
}

/// ============================================================
/// 报修类型选择卡片
/// ============================================================
class _TypeCard extends StatelessWidget {
  final RepairType type;
  final bool selected;
  final VoidCallback onTap;
  const _TypeCard({required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 10 * 3) / 4,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: selected ? type.color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? type.color : const Color(0xFFE0E0E0),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(children: [
        Icon(type.icon, color: selected ? type.color : const Color(0xFF9E9E9E), size: 26),
        const SizedBox(height: 6),
        Text(type.label, style: TextStyle(fontSize: 11, color: selected ? type.color : const Color(0xFF757575), fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      ]),
    ),
  );
}

/// ============================================================
/// 房源选择器
/// ============================================================
class _RoomSelector extends StatelessWidget {
  final String roomTitle;
  final String address;
  final VoidCallback onTap;
  const _RoomSelector({required this.roomTitle, required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.home, color: Color(0xFF6366F1), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(roomTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(address, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
        ])),
        const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 20),
      ]),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF424242)));
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final int? badge;
  const _TabBtn(this.label, this.active, this.onTap, {this.badge});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Row(children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? const Color(0xFF6366F1) : const Color(0xFF9E9E9E))),
        if (badge != null && badge! > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
            child: Text('$badge', style: const TextStyle(fontSize: 9, color: Colors.white)),
          ),
        ],
      ]),
      const SizedBox(height: 6),
      Container(height: 2, width: 40, decoration: BoxDecoration(
        color: active ? const Color(0xFF6366F1) : Colors.transparent,
        borderRadius: BorderRadius.circular(1),
      )),
    ]),
  );
}
