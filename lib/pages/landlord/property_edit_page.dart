import 'package:flutter/material.dart';
import 'package:gongyu_guanjia/models/room.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';
import 'package:gongyu_guanjia/utils/app_theme.dart';

// ============================================================
//  房源编辑 / 新增页（room=null 时为新增模式）
// ============================================================
class PropertyEditPage extends StatefulWidget {
  final Room? room; // null = 新增房源
  const PropertyEditPage({super.key, this.room});

  @override
  State<PropertyEditPage> createState() => _PropertyEditPageState();
}

class _PropertyEditPageState extends State<PropertyEditPage> {
  bool get _isCreate => widget.room == null;

  late TextEditingController _titleCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _depositCtrl;
  late TextEditingController _areaCtrl;
  late TextEditingController _floorCtrl;
  late TextEditingController _totalFloorCtrl;
  late TextEditingController _layoutCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _communityCtrl;
  late TextEditingController _descCtrl;

  late RoomType _selectedType;
  late RoomStatus _selectedStatus;
  late List<String> _selectedFacilities;

  bool _isSaving = false;

  final _allFacilities = [
    '床', '空调', 'WiFi', '热水器', '洗衣机', '冰箱',
    '电视', '衣柜', '厨房', '电梯', '车位', '保洁',
    '独立卫生间', '阳台',
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.room;
    _titleCtrl      = TextEditingController(text: r?.title ?? '');
    _priceCtrl      = TextEditingController(text: r?.price.toString() ?? '');
    _depositCtrl    = TextEditingController(text: r?.deposit.toString() ?? '');
    _areaCtrl       = TextEditingController(text: r?.area.toString() ?? '');
    _floorCtrl      = TextEditingController(text: r?.floor.toString() ?? '');
    _totalFloorCtrl = TextEditingController(text: r?.totalFloors.toString() ?? '');
    _layoutCtrl     = TextEditingController(text: r?.layout ?? '');
    _addressCtrl    = TextEditingController(text: r?.address ?? '');
    _communityCtrl  = TextEditingController(text: r?.communityName ?? '');
    _descCtrl       = TextEditingController(text: r?.description ?? '');
    _selectedType   = r?.type ?? RoomType.whole;
    _selectedStatus = r?.status ?? RoomStatus.available;
    _selectedFacilities = List.from(r?.facilities ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _priceCtrl.dispose(); _depositCtrl.dispose();
    _areaCtrl.dispose(); _floorCtrl.dispose(); _totalFloorCtrl.dispose();
    _layoutCtrl.dispose(); _addressCtrl.dispose(); _communityCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _typeLabel(RoomType t) {
    if (t == RoomType.whole) return '整租';
    if (t == RoomType.shared) return '合租';
    return '独栋';
  }

  String _statusLabel(RoomStatus s) {
    if (s == RoomStatus.available) return '未出租';
    if (s == RoomStatus.rented) return '已出租';
    if (s == RoomStatus.reserved) return '预定中';
    if (s == RoomStatus.signing) return '签订中';
    return '不可出租';
  }

  String? _validate() {
    if (_titleCtrl.text.trim().isEmpty) return '请输入房源标题';
    if (_priceCtrl.text.isEmpty || double.tryParse(_priceCtrl.text) == null)
      return '请输入正确的租金价格';
    if (_areaCtrl.text.isNotEmpty && double.tryParse(_areaCtrl.text) == null)
      return '请输入正确的面积';
    if (_floorCtrl.text.isNotEmpty && int.tryParse(_floorCtrl.text) == null)
      return '请输入正确的楼层';
    return null;
  }

  Future<void> _save() async {
    final err = _validate();
    if (err != null) { _showMsg(err, isError: true); return; }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final price      = double.tryParse(_priceCtrl.text) ?? 0;
    final deposit    = double.tryParse(_depositCtrl.text) ?? 0;
    final area       = double.tryParse(_areaCtrl.text) ?? 0;
    final floor      = int.tryParse(_floorCtrl.text) ?? 1;
    final totalFloor = int.tryParse(_totalFloorCtrl.text) ?? 1;

    if (_isCreate) {
      final newId = MockService.rooms.isEmpty
          ? 1
          : MockService.rooms.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;
      final newRoom = Room(
        id: newId,
        title: _titleCtrl.text.trim(),
        type: _selectedType,
        address: _addressCtrl.text.trim(),
        communityId: 'C${newId.toString().padLeft(4, '0')}',
        communityName: _communityCtrl.text.trim(),
        price: price,
        deposit: deposit,
        area: area,
        floor: floor,
        totalFloors: totalFloor,
        layout: _layoutCtrl.text.trim(),
        status: _selectedStatus,
        facilities: _selectedFacilities,
        images: [],
        description: _descCtrl.text.trim(),
        publishedAt: DateTime.now(),
        isPublished: false,
      );
      MockService.rooms.add(newRoom);
    } else {
      final idx = MockService.rooms.indexWhere((r) => r.id == widget.room!.id);
      if (idx >= 0) {
        MockService.rooms[idx] = widget.room!.copyWith(
          title: _titleCtrl.text.trim(),
          type: _selectedType,
          address: _addressCtrl.text.trim(),
          communityName: _communityCtrl.text.trim(),
          price: price,
          deposit: deposit,
          area: area,
          floor: floor,
          totalFloors: totalFloor,
          layout: _layoutCtrl.text.trim(),
          status: _selectedStatus,
          facilities: _selectedFacilities,
          description: _descCtrl.text.trim(),
        );
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      _showMsg(_isCreate ? '房源「${_titleCtrl.text.trim()}」已创建' : '房源信息已保存');
      Navigator.pop(context, true);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        title: Text(
          _isCreate ? '新增房源' : '编辑房源',
          style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('保存', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(children: [

          _buildSection('基础信息', [
            _buildField('房源标题 *', TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(hintText: '如：精装修一居室近地铁'),
              style: const TextStyle(fontSize: 14),
            )),
            _buildField('租金（元/月） *', TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '0'),
              style: const TextStyle(fontSize: 14),
            )),
            _buildField('押金（元）', TextField(
              controller: _depositCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '0'),
              style: const TextStyle(fontSize: 14),
            )),
            _buildChoiceField('房源类型', Wrap(
              spacing: 8,
              children: RoomType.values.map((t) => ChoiceChip(
                label: Text(_typeLabel(t)),
                selected: _selectedType == t,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(fontSize: 12,
                  color: _selectedType == t ? AppColors.primary : Colors.black87),
                onSelected: (_) => setState(() => _selectedType = t),
              )).toList(),
            )),
            _buildChoiceField('房源状态', Wrap(
              spacing: 8,
              children: [RoomStatus.available, RoomStatus.rented, RoomStatus.unavailable]
                  .map((s) => ChoiceChip(
                label: Text(_statusLabel(s)),
                selected: _selectedStatus == s,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(fontSize: 12,
                  color: _selectedStatus == s ? AppColors.primary : Colors.black87),
                onSelected: (_) => setState(() => _selectedStatus = s),
              )).toList(),
            )),
          ]),

          const SizedBox(height: 12),

          _buildSection('位置信息', [
            _buildField('小区名称', TextField(
              controller: _communityCtrl,
              decoration: const InputDecoration(hintText: '如：龙湖时代天街'),
              style: const TextStyle(fontSize: 14),
            )),
            _buildField('详细地址', TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(hintText: '如：武侯区天府大道88号'),
              style: const TextStyle(fontSize: 14),
            )),
          ]),

          const SizedBox(height: 12),

          _buildSection('房屋信息', [
            _buildField('面积（m\u00b2）', TextField(
              controller: _areaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '0'),
              style: const TextStyle(fontSize: 14),
            )),
            _buildField('户型', TextField(
              controller: _layoutCtrl,
              decoration: const InputDecoration(hintText: '如：2室1厅1卫'),
              style: const TextStyle(fontSize: 14),
            )),
            _buildField('当前楼层', TextField(
              controller: _floorCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '如：5'),
              style: const TextStyle(fontSize: 14),
            )),
            _buildField('总楼层', TextField(
              controller: _totalFloorCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '如：33'),
              style: const TextStyle(fontSize: 14),
            )),
          ]),

          const SizedBox(height: 12),

          _buildSection('配套设施', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allFacilities.map((f) => FilterChip(
                label: Text(f, style: const TextStyle(fontSize: 12)),
                selected: _selectedFacilities.contains(f),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(fontSize: 12,
                  color: _selectedFacilities.contains(f) ? AppColors.primary : Colors.black87),
                onSelected: (selected) {
                  setState(() {
                    if (selected) _selectedFacilities.add(f);
                    else _selectedFacilities.remove(f);
                  });
                },
              )).toList(),
            ),
          ]),

          const SizedBox(height: 12),

          _buildSection('房源描述', [
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '描述房源亮点、交通、周边配套等...',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ]),

          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Text(title, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.bold)),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildField(String label, Widget child) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
      const SizedBox(height: 6),
      child,
    ]);
  }

  Widget _buildChoiceField(String label, Widget child) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
      const SizedBox(height: 8),
      child,
      const SizedBox(height: 4),
    ]);
  }
}
