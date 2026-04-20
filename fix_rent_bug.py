# -*- coding: utf-8 -*-
with open(r'D:\Projects\gongyu_guanjia\lib\services\mock_service.dart', 'r', encoding='utf-8', errors='replace') as f:
    data = f.read()

# 1. Fix tenant phone in switchRole: '13987654321' -> '13912345678'
data = data.replace(
    "phone: '13987654321', name: ",
    "phone: '13912345678', name: ",
)
print("Fixed tenant phone")

# 2. Fix daysToExpire in contracts - update to 2026 dates so they show realistic values
# Contract 1: 陆家嘴花园 - rentAmount 5800, needs to expire around 180 days from 2026
# Contract 3: 静安寺独栋 - rentAmount 12000
# Find and update daysToExpire values
# Current values are from 2024 perspective, update to 2026
data = data.replace(
    "status: ContractStatus.active, daysToExpire: 180,",
    "status: ContractStatus.active, daysToExpire: 210,",
)
data = data.replace(
    "status: ContractStatus.active, daysToExpire: 240,",
    "status: ContractStatus.active, daysToExpire: 280,",
)
data = data.replace(
    "status: ContractStatus.active, daysToExpire: 150,",
    "status: ContractStatus.active, daysToExpire: 90,",
)
print("Fixed daysToExpire")

# 3. Add RentOrder mock data at the end of MockService class
# Find the end of the MockService class
end_marker = "  // ==================== 小区列表 ====================\n\n  static List<String> get communityNames =>"
rent_order_data = '''

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
    for (var i = 0; i < rentOrders.length; i++) {
      final order = rentOrders[i];
      final contract = contracts.where(
        (c) => c.tenantPhone == phone && c.status == ContractStatus.active
      ).firstOrNull;
      if (contract != null && order['contractNo'] == contract.contractNo) {
        rentOrders[i] = {...order, 'hasUnpaidBill': false};
        break;
      }
    }
  }

'''

if end_marker in data:
    data = data.replace(end_marker, rent_order_data + end_marker)
    print("Added rent order data")
else:
    print("WARNING: end marker not found!")
    # Try to find where to insert
    idx = data.find('static List<String> get communityNames')
    print(f"communityNames at: {idx}")

with open(r'D:\Projects\gongyu_guanjia\lib\services\mock_service.dart', 'w', encoding='utf-8') as f:
    f.write(data)
print("Saved!")
