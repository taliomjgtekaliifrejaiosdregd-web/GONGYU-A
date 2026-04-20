// ============================================================
// 用户与认证相关模型
// ============================================================

/// 用户角色枚举
enum UserRole { landlord, tenant, admin }

/// 实名认证状态
enum RealNameStatus { pending, approved, rejected }

/// 用户模型
class User {
  final int id;
  final String phone;
  final String name;
  final UserRole role;
  final String? avatarUrl;
  final int? landlordId;
  final int? tenantId;
  final RealNameStatus realNameStatus;
  final int creditScore;
  final int points;

  const User({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.landlordId,
    this.tenantId,
    this.realNameStatus = RealNameStatus.pending,
    this.creditScore = 100,
    this.points = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.landlord,
      ),
      avatarUrl: json['avatar_url'],
      landlordId: json['landlord_id'],
      tenantId: json['tenant_id'],
      realNameStatus: RealNameStatus.values.firstWhere(
        (s) => s.name == json['real_name_status'],
        orElse: () => RealNameStatus.pending,
      ),
      creditScore: json['credit_score'] ?? 100,
      points: json['points'] ?? 0,
    );
  }

  bool get isLandlord => role == UserRole.landlord;
  bool get isTenant => role == UserRole.tenant;
  bool get isAdmin => role == UserRole.admin;
  bool get isRealNameApproved => realNameStatus == RealNameStatus.approved;
}
