// ============================================================
// 合同与账单相关模型
// ============================================================

/// 合同状态
enum ContractStatus {
  draft,          // 草稿
  pendingSign,    // 待签署
  active,         // 生效中
  expiring,       // 即将到期
  expired,        // 已到期
  terminated,     // 已终止
}

/// 账单状态
enum BillStatus { pending, partiallyPaid, paid, overdue }

/// 账单类型
enum BillType { rent, water, electric, deposit, penalty, other }

/// ============================================================
// 合同版本模型
// ============================================================
class ContractVersion {
  final String id;
  final String version;       // "V1.0", "V1.1", "V2.0"
  final String? fileName;      // 上传的文件名
  final String? fileUrl;       // 文件访问地址
  final int? fileSize;         // 文件大小（字节）
  final DateTime createdAt;
  final bool isLocked;         // 是否已锁定（锁定后不可编辑）
  final bool isCurrent;        // 是否是当前版本
  final String? lockedBy;      // 锁定人
  final String? lockedReason;  // 锁定说明（如：双方签署确认）

  const ContractVersion({
    required this.id,
    required this.version,
    this.fileName,
    this.fileUrl,
    this.fileSize,
    required this.createdAt,
    this.isLocked = false,
    this.isCurrent = false,
    this.lockedBy,
    this.lockedReason,
  });

  /// 锁定状态标签
  String get lockLabel {
    if (isLocked) return '已锁定';
    if (isCurrent) return '当前版本';
    return '历史版本';
  }

  /// 文件大小格式化
  String get fileSizeLabel {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '${fileSize}B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize! / 1024 / 1024).toStringAsFixed(1)}MB';
  }

  ContractVersion copyWith({
    String? id,
    String? version,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    DateTime? createdAt,
    bool? isLocked,
    bool? isCurrent,
    String? lockedBy,
    String? lockedReason,
  }) {
    return ContractVersion(
      id: id ?? this.id,
      version: version ?? this.version,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      isLocked: isLocked ?? this.isLocked,
      isCurrent: isCurrent ?? this.isCurrent,
      lockedBy: lockedBy ?? this.lockedBy,
      lockedReason: lockedReason ?? this.lockedReason,
    );
  }
}

/// ============================================================
// 合同模型（扩展版）
// ============================================================
class Contract {
  final int id;
  final String contractNo;
  final int roomId;
  final String roomTitle;
  final String tenantName;
  final String tenantPhone;
  final DateTime startDate;
  final DateTime endDate;
  final double rentAmount;
  final double depositAmount;
  final ContractStatus status;
  final int daysToExpire;
  // --- 新增字段 ---
  final String contractVersion;  // 当前合同版本号，如 "V1.0"
  final List<ContractVersion> versions;  // 所有历史版本
  final ContractVersion? currentVersion; // 当前版本详情

  const Contract({
    required this.id,
    required this.contractNo,
    required this.roomId,
    required this.roomTitle,
    required this.tenantName,
    required this.tenantPhone,
    required this.startDate,
    required this.endDate,
    required this.rentAmount,
    required this.depositAmount,
    required this.status,
    required this.daysToExpire,
    this.contractVersion = 'V1.0',
    this.versions = const [],
    this.currentVersion,
  });

  /// 合同是否有已上传的文件
  bool get hasFile => currentVersion?.fileName != null;

  /// 是否可以编辑（草稿 或 未锁定版本）
  bool get canEdit {
    if (status == ContractStatus.draft) return true;
    if (currentVersion == null) return true;
    return !currentVersion!.isLocked;
  }

  String get statusLabel {
    switch (status) {
      case ContractStatus.draft: return '草稿';
      case ContractStatus.pendingSign: return '待签署';
      case ContractStatus.active: return '生效中';
      case ContractStatus.expiring: return '即将到期';
      case ContractStatus.expired: return '已到期';
      case ContractStatus.terminated: return '已终止';
    }
  }

  /// 含版本信息的复制
  Contract copyWithVersions({
    String? contractVersion,
    List<ContractVersion>? versions,
    ContractVersion? currentVersion,
  }) {
    return Contract(
      id: id, contractNo: contractNo, roomId: roomId, roomTitle: roomTitle,
      tenantName: tenantName, tenantPhone: tenantPhone,
      startDate: startDate, endDate: endDate,
      rentAmount: rentAmount, depositAmount: depositAmount,
      status: status, daysToExpire: daysToExpire,
      contractVersion: contractVersion ?? this.contractVersion,
      versions: versions ?? this.versions,
      currentVersion: currentVersion ?? this.currentVersion,
    );
  }
}

/// 账单模型
class Bill {
  final int id;
  final String billNo;
  final int roomId;
  final String roomTitle;
  final String tenantName;
  final BillType type;
  final double amount;
  final double paidAmount;
  final BillStatus status;
  final DateTime dueDate;
  final String billingMonth;
  final double? waterCost;
  final double? electricCost;
  final double? penaltyAmount;

  const Bill({
    required this.id,
    required this.billNo,
    required this.roomId,
    required this.roomTitle,
    required this.tenantName,
    required this.type,
    required this.amount,
    this.paidAmount = 0,
    required this.status,
    required this.dueDate,
    required this.billingMonth,
    this.waterCost,
    this.electricCost,
    this.penaltyAmount,
  });

  String get statusLabel {
    switch (status) {
      case BillStatus.pending: return '待支付';
      case BillStatus.partiallyPaid: return '部分支付';
      case BillStatus.paid: return '已支付';
      case BillStatus.overdue: return '已逾期';
    }
  }

  double get unpaidAmount => amount - paidAmount;
}

/// 收支记录
class IncomeRecord {
  final int id;
  final String type; // income / expense
  final String category;
  final double amount;
  final String source;
  final String? remark;
  final DateTime createdAt;

  const IncomeRecord({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.source,
    this.remark,
    required this.createdAt,
  });
}

