// ============================================================
// 模拟数据服务 - 提供完整Mock数据，支持后续API对接
// 数据结构与后端接口完全一致，对接时只需替换此Service
// ============================================================

import '../models/user.dart';
import '../models/room.dart';
import '../models/device.dart';
import '../models/contract.dart';

/// Mock数据服务
/// 使用方法：直接调用 MockService.xxx 获取数据
/// 对接真实API时：实现相同接口的ApiService替换即可
class MockService {
  // ==================== 用户数据 ====================

  /// 当前登录用户（可切换角色演示）
  static User currentUser = const User(
    id: 1,
    phone: '13812345678',
    name: '李明',
    role: UserRole.landlord,
    landlordId: 1,
    realNameStatus: RealNameStatus.approved,
    creditScore: 98,
    points: 2580,
  );

  /// 切换用户角色
  static void switchRole(UserRole role) {
    switch (role) {
      case UserRole.landlord:
        currentUser = const User(
          id: 1, phone: '13812345678', name: '李明',
          role: UserRole.landlord, landlordId: 1,
          realNameStatus: RealNameStatus.approved,
          creditScore: 98, points: 2580,
        );
        break;
      case UserRole.tenant:
        currentUser = const User(
          id: 2, phone: '13912345678', name: '张伟',
          role: UserRole.tenant, tenantId: 1,
          realNameStatus: RealNameStatus.approved,
          creditScore: 100, points: 520,
        );
        break;
      case UserRole.admin:
        currentUser = const User(
          id: 3, phone: '13700000000', name: '管理员',
          role: UserRole.admin,
          realNameStatus: RealNameStatus.approved,
          creditScore: 100, points: 0,
        );
        break;
    }
  }

  // ==================== 房源数据 ====================

  static final List<Community> communities = [
    const Community(id: 1, name: '陆家嘴花园', address: '浦东新区陆家嘴路199号', district: '浦东新区'),
    const Community(id: 2, name: '浦东大道公寓', address: '浦东新区浦东大道1000号', district: '浦东新区'),
    const Community(id: 3, name: '前滩小区', address: '浦东新区前滩路88号', district: '浦东新区'),
    const Community(id: 4, name: '静安公馆', address: '静安区南京西路200号', district: '静安区'),
  ];

  static final List<Room> rooms = [
    Room(
      id: 1, title: '陆家嘴花园整租', type: RoomType.whole,
      address: '陆家嘴路199号1号楼1单元101', communityId: '1', communityName: '陆家嘴花园',
      building: '1号楼', unit: '1单元', roomNo: '101',
      floor: 1, totalFloors: 6, area: 85.5, layout: '2室1厅1卫', orientation: '南',
      price: 5800, deposit: 11600, status: RoomStatus.rented,
      facilities: ['空调', '热水器', '洗衣机', '冰箱', '宽带', '电视'],
      tenantName: '张先生', tenantPhone: '13912345678',
      rentExpireDate: '2024-06-30',
      isPublished: false,
      images: [
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=80',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80',
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80',
      ],
    ),
    Room(
      id: 2, title: '浦东大道合租', type: RoomType.shared,
      address: '浦东大道1000号2号楼2单元201', communityId: '2', communityName: '浦东大道公寓',
      building: '2号楼', unit: '2单元', roomNo: '201',
      floor: 2, totalFloors: 8, area: 45.0, layout: '3室1厅2卫', orientation: '南北',
      price: 3200, deposit: 6400, status: RoomStatus.rented,
      facilities: ['空调', '热水器', '洗衣机'],
      tenantName: '李女士', tenantPhone: '13823456789',
      rentExpireDate: '2024-03-15',
      isPublished: false,
      images: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80',
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80',
      ],
    ),
    Room(
      id: 3, title: '前滩公寓', type: RoomType.whole,
      address: '前滩路88号3号楼301', communityId: '3', communityName: '前滩小区',
      building: '3号楼', unit: '', roomNo: '301',
      floor: 3, totalFloors: 5, area: 65.0, layout: '1室1厅1卫', orientation: '东南',
      price: 4500, deposit: 9000, status: RoomStatus.available,
      facilities: ['空调', '热水器', '冰箱'],
      isPublished: true,
      images: [
        'https://images.unsplash.com/photo-1560185007-cde436f6a4d0?w=800&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
        'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800&q=80',
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&q=80',
      ],
    ),
    Room(
      id: 4, title: '静安寺独栋', type: RoomType.building,
      address: '南京西路200号', communityId: '4', communityName: '静安公馆',
      floor: 1, totalFloors: 3, area: 200.0, layout: '5室3厅3卫', orientation: '南',
      price: 12000, deposit: 24000, status: RoomStatus.rented,
      facilities: ['中央空调', '地暖', '智能家居', '车位'],
      tenantName: '王总', tenantPhone: '13712345678',
      rentExpireDate: '2024-09-01',
      isPublished: false,
      images: [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=80',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&q=80',
      ],
    ),
    Room(
      id: 5, title: '徐家汇精品公寓', type: RoomType.whole,
      address: '漕溪北路88号汇翠花园4号楼401', communityId: '1', communityName: '汇翠花园',
      floor: 4, totalFloors: 10, area: 78.0, layout: '2室2厅1卫', orientation: '南',
      price: 6800, deposit: 13600, status: RoomStatus.rented,
      facilities: ['空调', '热水器', '洗衣机', '冰箱', '宽带'],
      tenantName: '陈小姐', tenantPhone: '13687654321',
      rentExpireDate: '2024-02-28',
      isPublished: false,
      images: [
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800&q=80',
        'https://images.unsplash.com/photo-1502005229762-cf1b2da7c5d6?w=800&q=80',
        'https://images.unsplash.com/photo-1567767292278-a4f21aa2d36e?w=800&q=80',
      ],
    ),
    Room(
      id: 6, title: '新天地服务公寓', type: RoomType.whole,
      address: '马当路188号5号楼501', communityId: '2', communityName: '新天地',
      floor: 5, totalFloors: 12, area: 95.0, layout: '3室2厅2卫', orientation: '南北',
      price: 8500, deposit: 17000, status: RoomStatus.signing,
      facilities: ['中央空调', '地暖', '智能门锁', '管家服务'],
      isPublished: false,
      images: [
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=80',
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&q=80',
        'https://images.unsplash.com/photo-1615529182904-14819c35db37?w=800&q=80',
      ],
    ),
    Room(
      id: 7, title: '淮海路老公房', type: RoomType.shared,
      address: '淮海中路99号6号楼601', communityId: '3', communityName: '淮海路小区',
      floor: 6, totalFloors: 6, area: 35.0, layout: '2室1厅1卫', orientation: '东',
      price: 2800, deposit: 5600, status: RoomStatus.available,
      facilities: ['空调', '热水器'],
      isPublished: true,
      images: [
        'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=800&q=80',
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80',
        'https://images.unsplash.com/photo-1556909172-54557c7e4fb7?w=800&q=80',
      ],
    ),
    Room(
      id: 8, title: '虹口足球场旁整租', type: RoomType.whole,
      address: '西江湾路388号7号楼701', communityId: '4', communityName: '虹口花园',
      floor: 7, totalFloors: 9, area: 72.0, layout: '2室1厅1卫', orientation: '南',
      price: 5200, deposit: 10400, status: RoomStatus.reserved,
      facilities: ['空调', '热水器', '洗衣机', '宽带'],
      isPublished: false,
      images: [
        'https://images.unsplash.com/photo-1484154218962-a197022b25ba?w=800&q=80',
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80',
        'https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800&q=80',
      ],
    ),
  ];

  static List<Room> getRoomsByType(RoomType type) {
    return rooms.where((r) => r.type == type).toList();
  }

  static List<Room> getRoomsByStatus(RoomStatus status) {
    return rooms.where((r) => r.status == status).toList();
  }

  static Room? getRoomById(int id) {
    try { return rooms.firstWhere((r) => r.id == id); }
    catch (_) { return null; }
  }

  // ==================== 设备数据 ====================

  static final List<Device> devices = [
    Device(
      id: 1, deviceNo: 'EM-LJZO-001', type: DeviceType.electricMeter,
      roomId: 1, roomTitle: '陆家嘴花园整租', brand: '华立DL/T645-2007',
      status: DeviceStatus.online, currentReading: 1560.0,
      warningThreshold: 5.0, balance: 200.0,
      lastReadAt: DateTime.now().subtract(const Duration(hours: 2)),
      todayUsage: 5.2, monthUsage: 120.5, monthCost: 72.30,
    ),
    Device(
      id: 2, deviceNo: 'EM-PDDD-001', type: DeviceType.electricMeter,
      roomId: 2, roomTitle: '浦东大道合租', brand: '华立DL/T645-2007',
      status: DeviceStatus.warning, currentReading: 4.2,
      warningThreshold: 5.0, balance: 50.0,
      lastReadAt: DateTime.now().subtract(const Duration(minutes: 30)),
      todayUsage: 3.5, monthUsage: 95.0, monthCost: 57.00,
    ),
    Device(
      id: 3, deviceNo: 'WM-LJZO-001', type: DeviceType.waterMeter,
      roomId: 1, roomTitle: '陆家嘴花园整租', brand: '宁波水表LXS-20E',
      status: DeviceStatus.online, currentReading: 89.5,
      warningThreshold: 1.0, balance: 0,
      lastReadAt: DateTime.now().subtract(const Duration(hours: 5)),
      todayUsage: 0.8, monthUsage: 8.5, monthCost: 17.00,
    ),
    Device(
      id: 4, deviceNo: 'SL-LJZO-001', type: DeviceType.smartLock,
      roomId: 1, roomTitle: '陆家嘴花园整租', brand: '德施曼Q5 Pro',
      status: DeviceStatus.online, currentReading: 80.0,
      balance: 80.0,
      lastReadAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Device(
      id: 5, deviceNo: 'EM-QTGY-001', type: DeviceType.electricMeter,
      roomId: 4, roomTitle: '静安寺独栋', brand: '威胜DDS102',
      status: DeviceStatus.online, currentReading: 4560.0,
      balance: 500.0,
      lastReadAt: DateTime.now().subtract(const Duration(hours: 3)),
      todayUsage: 25.0, monthUsage: 450.0, monthCost: 270.00,
    ),
    Device(
      id: 6, deviceNo: 'EM-XJD-001', type: DeviceType.electricMeter,
      roomId: 5, roomTitle: '徐家汇精品公寓', brand: '华立DL/T645-2007',
      status: DeviceStatus.offline, currentReading: 980.0,
      balance: 0,
      lastReadAt: DateTime.now().subtract(const Duration(days: 2)),
      todayUsage: 0, monthUsage: 200.0, monthCost: 120.00,
    ),
    Device(
      id: 7, deviceNo: 'WM-QTGY-001', type: DeviceType.waterMeter,
      roomId: 4, roomTitle: '静安寺独栋', brand: '宁波水表LXS-20E',
      status: DeviceStatus.online, currentReading: 256.0,
      balance: 0,
      lastReadAt: DateTime.now().subtract(const Duration(hours: 4)),
      todayUsage: 2.0, monthUsage: 35.0, monthCost: 70.00,
    ),
    Device(
      id: 8, deviceNo: 'SL-QTGY-001', type: DeviceType.smartLock,
      roomId: 4, roomTitle: '静安寺独栋', brand: '德施曼R7P',
      status: DeviceStatus.warning, currentReading: 15.0,
      balance: 15.0,
      lastReadAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  static List<Device> getDevicesByType(DeviceType type) {
    return devices.where((d) => d.type == type).toList();
  }

  static List<Device> getDevicesByStatus(DeviceStatus status) {
    return devices.where((d) => d.status == status).toList();
  }

  static List<DeviceAlert> getAlerts() {
    return [
      DeviceAlert(
        id: 1, deviceId: 2, deviceNo: 'EM-PDDD-001',
        roomTitle: '浦东大道合租',
        alertType: 'electric_low',
        message: '电表余额不足，请及时充值',
        level: AlertLevel.warning,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      DeviceAlert(
        id: 2, deviceId: 6, deviceNo: 'EM-XJD-001',
        roomTitle: '徐家汇精品公寓',
        alertType: 'electric_offline',
        message: '电表已离线超过48小时',
        level: AlertLevel.critical,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      DeviceAlert(
        id: 3, deviceId: 8, deviceNo: 'SL-QTGY-001',
        roomTitle: '静安寺独栋',
        alertType: 'lock_low_battery',
        message: '门锁电量仅剩15%，请尽快更换电池',
        level: AlertLevel.warning,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      DeviceAlert(
        id: 4, deviceId: 3, deviceNo: 'WM-LJZO-001',
        roomTitle: '陆家嘴花园整租',
        alertType: 'water_low',
        message: '水表余额不足，请注意充值',
        level: AlertLevel.info,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // ==================== 合同数据 ====================

  // 合同版本 Mock 数据
  static final List<ContractVersion> _mockVersions = [
    // 合同1 版本历史
    ContractVersion(
      id: 'v1-1', version: 'V1.0', fileName: 'HT2024010001_租赁合同_V1.0.pdf',
      fileUrl: '/contracts/HT2024010001_V1.0.pdf', fileSize: 245760,
      createdAt: DateTime(2024, 1, 1, 10, 0), isLocked: true, isCurrent: false,
      lockedBy: '房东 + 租客', lockedReason: '双方签署确认',
    ),
    ContractVersion(
      id: 'v1-2', version: 'V1.1', fileName: 'HT2024010001_补充协议_V1.1.pdf',
      fileUrl: '/contracts/HT2024010001_V1.1.pdf', fileSize: 128000,
      createdAt: DateTime(2024, 3, 15, 14, 30), isLocked: true, isCurrent: false,
      lockedBy: '房东',
    ),
    ContractVersion(
      id: 'v1-3', version: 'V1.2', fileName: 'HT2024010001_最终版_V1.2.pdf',
      fileUrl: '/contracts/HT2024010001_V1.2.pdf', fileSize: 512000,
      createdAt: DateTime.now().subtract(const Duration(days: 2)), isLocked: false, isCurrent: true,
    ),
    // 合同2 版本历史
    ContractVersion(
      id: 'v2-1', version: 'V1.0', fileName: 'HT2024020002_租赁合同_V1.0.pdf',
      fileUrl: '/contracts/HT2024020002_V1.0.pdf', fileSize: 234000,
      createdAt: DateTime(2024, 2, 1, 9, 0), isLocked: true, isCurrent: true,
      lockedBy: '房东 + 租客', lockedReason: '电子签章确认',
    ),
    // 合同3 无版本（空）
    // 合同4 无版本
    // 合同5 版本
    ContractVersion(
      id: 'v5-1', version: 'V1.0', fileName: 'HT2023120005_租赁合同.pdf',
      fileUrl: '/contracts/HT2023120005.pdf', fileSize: 198000,
      createdAt: DateTime(2023, 12, 1, 11, 0), isLocked: true, isCurrent: true,
      lockedBy: '房东', lockedReason: '签署归档',
    ),
  ];


  static List<ContractVersion> getContractVersions() => _mockVersions;
  static final List<Contract> contracts = [
    Contract(
      id: 1, contractNo: 'HT2024010001', roomId: 1,
      roomTitle: '陆家嘴花园整租',
      tenantName: '张先生', tenantPhone: '13912345678',
      startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30),
      rentAmount: 5800, depositAmount: 11600,
      status: ContractStatus.active, daysToExpire: 210,
      contractVersion: 'V1.2',
      versions: _mockVersions.where((v) => v.id.startsWith('v1')).toList(),
      currentVersion: _mockVersions.where((v) => v.id == 'v1-3').firstOrNull,
    ),
    Contract(
      id: 2, contractNo: 'HT2024020002', roomId: 2,
      roomTitle: '浦东大道合租',
      tenantName: '李女士', tenantPhone: '13823456789',
      startDate: DateTime(2024, 2, 1), endDate: DateTime(2024, 3, 15),
      rentAmount: 3200, depositAmount: 6400,
      status: ContractStatus.expiring, daysToExpire: 15,
      contractVersion: 'V1.0',
      versions: _mockVersions.where((v) => v.id.startsWith('v2')).toList(),
      currentVersion: _mockVersions.where((v) => v.id == 'v2-1').firstOrNull,
    ),
    Contract(
      id: 3, contractNo: 'HT2023090003', roomId: 4,
      roomTitle: '静安寺独栋',
      tenantName: '王总', tenantPhone: '13712345678',
      startDate: DateTime(2023, 9, 1), endDate: DateTime(2024, 9, 1),
      rentAmount: 12000, depositAmount: 24000,
      status: ContractStatus.active, daysToExpire: 280,
      contractVersion: 'V1.0',
    ),
    Contract(
      id: 4, contractNo: 'HT2024010004', roomId: 5,
      roomTitle: '徐家汇精品公寓',
      tenantName: '陈小姐', tenantPhone: '13687654321',
      startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 2, 28),
      rentAmount: 6800, depositAmount: 13600,
      status: ContractStatus.expiring, daysToExpire: 5,
      contractVersion: 'V1.0',
    ),
    Contract(
      id: 5, contractNo: 'HT2023120005', roomId: 3,
      roomTitle: '前滩公寓',
      tenantName: '', tenantPhone: '',
      startDate: DateTime(2023, 12, 1), endDate: DateTime(2024, 5, 31),
      rentAmount: 4500, depositAmount: 9000,
      status: ContractStatus.active, daysToExpire: 90,
      contractVersion: 'V1.0',
      versions: _mockVersions.where((v) => v.id.startsWith('v5')).toList(),
      currentVersion: _mockVersions.where((v) => v.id == 'v5-1').firstOrNull,
    ),
  ];

  // ==================== 看板统计数据 ====================

  static Map<String, dynamic> getDashboardStats() {
    final totalRooms = rooms.length;
    final rentedRooms = rooms.where((r) => r.status == RoomStatus.rented).length;
    final availableRooms = rooms.where((r) => r.status == RoomStatus.available).length;
    final expiringContracts = contracts.where((c) => c.status == ContractStatus.expiring).length;
    final expiredContracts = contracts.where((c) => c.status == ContractStatus.expired).length;

    return {
      'roomStats': {
        'total': totalRooms,
        'rented': rentedRooms,
        'available': availableRooms,
        'rentalRate': totalRooms > 0 ? (rentedRooms / totalRooms * 100).round() : 0,
      },
      'contractStats': {
        'expiring30d': expiringContracts,
        'expired': expiredContracts,
      },
      'billStats': {
        'pendingAmount': 12.8,
        'overdueAmount': 0.3,
        'totalIncome': 34.8,
      },
      'alerts': getAlerts(),
      'workOrders': {
        'terminationPending': 3,
        'billPending': 5,
        'contractPending': 2,
        'repairPending': 4,
      },
    };
  }



  // ==================== 租客端租房订单 ====================

  static final List<Map<String, dynamic>> rentOrders = [
    {
      'id': 'RO2026040001',
      'contractNo': 'HT2024010001',
      'roomTitle': '陆家嘴花园整租',
      'roomAddress': '上海市浦东新区陆家嘴花园1号楼101',
      'layout': '2室1厅',
      'area': 85.0,
      'rentAmount': 5800.0,
      'depositAmount': 11600.0,
      'startDate': DateTime(2026, 1, 1),
      'endDate': DateTime(2027, 1, 1),
      'status': 'active',
      'nextBillAmount': 5800.0,
      'nextBillDate': DateTime(2026, 5, 1),
      'hasUnpaidBill': true,
    },
    {
      'id': 'RO2026040002',
      'contractNo': 'HT2023090003',
      'roomTitle': '静安寺独栋',
      'roomAddress': '上海市静安区静安寺路88号',
      'layout': '4室2厅',
      'area': 150.0,
      'rentAmount': 12000.0,
      'depositAmount': 24000.0,
      'startDate': DateTime(2026, 3, 1),
      'endDate': DateTime(2027, 3, 1),
      'status': 'active',
      'nextBillAmount': 12000.0,
      'nextBillDate': DateTime(2026, 5, 1),
      'hasUnpaidBill': false,
    },
  ];

  /// 根据租客手机号获取租房订单
  static Map<String, dynamic>? getRentOrderByPhone(String phone) {
    // 先通过手机号找合同
    final contract = contracts.where(
      (c) => c.tenantPhone == phone && c.status == ContractStatus.active
    ).firstOrNull;
    if (contract == null) return null;
    return rentOrders.where((o) => o['contractNo'] == contract.contractNo).firstOrNull;
  }

  /// 根据租客手机号获取待缴房租金额
  static double getUnpaidRentByPhone(String phone) {
    final order = getRentOrderByPhone(phone);
    if (order == null) return 0;
    return (order['hasUnpaidBill'] == true) ? (order['nextBillAmount'] as double? ?? 0) : 0;
  }

  /// 根据租客手机号判断房租是否已缴（当月）
  static bool isRentPaidByPhone(String phone) {
    final order = getRentOrderByPhone(phone);
    if (order == null) return false;
    return order['hasUnpaidBill'] != true;
  }



    /// 标记房租已缴（租客端缴费成功后调用）
  static void markRentPaidByPhone(String phone) {
    final contract = contracts.where(
      (c) => c.tenantPhone == phone && c.status == ContractStatus.active
    ).firstOrNull;
    if (contract == null) return;
    for (var i = 0; i < rentOrders.length; i++) {
      if (rentOrders[i]['contractNo'] == contract.contractNo) {
        rentOrders[i] = {...rentOrders[i], 'hasUnpaidBill': false};
        break;
      }
    }
  }

// ==================== 租客端租房订单 ====================

  static List<String> get communityNames =>
      communities.map((c) => c.name).toList();

  // ==================== 报修数据 ====================

  static final List<Map<String, dynamic>> _repairs = [
    {
      'id': 'WX20260415001',
      'roomId': 1,
      'roomTitle': '陆家嘴花园整租',
      'tenantName': '张先生',
      'type': '水表问题',
      'title': '水表不走字',
      'description': '水表有时候不走字，计量不准，需要维修师傅上门检查。',
      'status': '处理中',
      'time': '2026-04-15 09:30',
    },
    {
      'id': 'WX20260412002',
      'roomId': 2,
      'roomTitle': '浦东大道合租',
      'tenantName': '李女士',
      'type': '门锁问题',
      'title': '门锁密码无法识别',
      'description': '密码指纹都能用，就是密码开不了门，需要更换门锁面板。',
      'status': '已完成',
      'time': '2026-04-12 14:20',
    },
    {
      'id': 'WX20260410003',
      'roomId': 1,
      'roomTitle': '陆家嘴花园整租',
      'tenantName': '张先生',
      'type': '电表问题',
      'title': '电表充值后不到账',
      'description': '4月10日充值了100元，但电表余额没有增加，请帮忙核查。',
      'status': '待处理',
      'time': '2026-04-10 18:45',
    },
  ];

  static List<Map<String, dynamic>> getRepairs() => List.from(_repairs);

  static void updateRepairStatus(String id, String status) {
    final index = _repairs.indexWhere((r) => r['id'] == id);
    if (index != -1) {
      _repairs[index] = {..._repairs[index], 'status': status};
    }
  }

  // ==================== 退租申请数据 ====================

  static final List<Map<String, dynamic>> _terminations = [
    {
      'id': 'TZ20260418001',
      'roomId': 2,
      'roomTitle': '浦东大道合租',
      'tenantName': '李女士',
      'reason': '工作调动，需要搬到公司附近居住，申请提前退租。',
      'requestedDate': '2026-04-30',
      'status': '待审核',
      'time': '2026-04-18 10:15',
    },
    {
      'id': 'TZ20260416002',
      'roomId': 5,
      'roomTitle': '徐家汇精品公寓',
      'tenantName': '陈小姐',
      'reason': '合同到期，不再续租，申请正常退租。',
      'requestedDate': '2026-05-15',
      'status': '待审核',
      'time': '2026-04-16 16:30',
    },
  ];

  static List<Map<String, dynamic>> getTerminations() => List.from(_terminations);

  static void updateTerminationStatus(String id, String status) {
    final index = _terminations.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      _terminations[index] = {..._terminations[index], 'status': status};
    }
  }

  // ==================== 异常提醒数据 ====================

  static final List<Map<String, dynamic>> _alerts = [
    {
      'id': 'ALT001',
      'type': '设备告警',
      'title': '电表余额不足',
      'description': '浦东大道合租房间电表余额仅剩5.2元，请及时提醒租客充值。',
      'severity': 'warning',
      'time': '2026-04-19 14:30',
      'isRead': false,
    },
    {
      'id': 'ALT002',
      'type': '设备告警',
      'title': '门锁电量低',
      'description': '静安寺独栋智能门锁电量仅剩15%，请尽快更换电池。',
      'severity': 'error',
      'time': '2026-04-19 10:15',
      'isRead': false,
    },
    {
      'id': 'ALT003',
      'type': '账单异常',
      'title': '租金逾期未缴',
      'description': '徐家汇精品公寓本月租金已逾期3天，请跟进催缴。',
      'severity': 'error',
      'time': '2026-04-18 09:00',
      'isRead': false,
    },
    {
      'id': 'ALT004',
      'type': '合同提醒',
      'title': '合同即将到期',
      'description': '浦东大道合租合同将于15天后到期，请提前联系租客确认是否续租。',
      'severity': 'info',
      'time': '2026-04-17 08:00',
      'isRead': true,
    },
    {
      'id': 'ALT005',
      'type': '安全警告',
      'title': '设备离线告警',
      'description': '徐家汇精品公寓电表已离线超过48小时，请检查设备状态。',
      'severity': 'error',
      'time': '2026-04-16 20:00',
      'isRead': false,
    },
    {
      'id': 'ALT006',
      'type': '账单异常',
      'title': '水电费异常偏高',
      'description': '静安寺独栋本月电费较上月增长80%，请核查是否存在异常用电。',
      'severity': 'warning',
      'time': '2026-04-15 11:20',
      'isRead': true,
    },
  ];

  static List<Map<String, dynamic>> getAlertsMap() => List.from(_alerts);

  static void markAlertRead(String id) {
    final index = _alerts.indexWhere((a) => a['id'] == id);
    if (index != -1) {
      _alerts[index] = {..._alerts[index], 'isRead': true};
    }
  }
}
