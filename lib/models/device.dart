// ============================================================
// 设备相关模型
// ============================================================

/// 设备类型
enum DeviceType { electricMeter, waterMeter, smartLock }

/// 设备状态
enum DeviceStatus { online, offline, warning, error }

/// 设备模型
class Device {
  final int id;
  final String deviceNo;
  final DeviceType type;
  final int roomId;
  final String roomTitle;
  final String brand;
  final DeviceStatus status;
  final double currentReading;
  final double? warningThreshold;
  final double balance;
  final DateTime? lastReadAt;
  final double todayUsage;
  final double monthUsage;
  final double monthCost;
  final double pricePerUnit; // 电价(元/度) 或 水价(元/吨)

  const Device({
    required this.id,
    required this.deviceNo,
    required this.type,
    required this.roomId,
    required this.roomTitle,
    required this.brand,
    required this.status,
    required this.currentReading,
    this.warningThreshold,
    this.balance = 0,
    this.lastReadAt,
    this.todayUsage = 0,
    this.monthUsage = 0,
    this.monthCost = 0,
    this.pricePerUnit = 0.5,
  });

  String get typeLabel {
    switch (type) {
      case DeviceType.electricMeter: return '电表';
      case DeviceType.waterMeter: return '水表';
      case DeviceType.smartLock: return '门锁';
    }
  }

  String get statusLabel {
    switch (status) {
      case DeviceStatus.online: return '在线';
      case DeviceStatus.offline: return '离线';
      case DeviceStatus.warning: return '预警';
      case DeviceStatus.error: return '故障';
    }
  }

  String get currentValue {
    switch (type) {
      case DeviceType.electricMeter: return '${currentReading}度';
      case DeviceType.waterMeter: return '${currentReading}吨';
      case DeviceType.smartLock: return '电量${(balance).toInt()}%';
    }
  }

  bool get isWarning {
    if (type == DeviceType.smartLock) return balance < 20;
    if (warningThreshold != null) return currentReading <= warningThreshold!;
    return false;
  }
}

/// 设备告警模型
class DeviceAlert {
  final int id;
  final int deviceId;
  final String deviceNo;
  final String roomTitle;
  final String alertType;
  final String message;
  final AlertLevel level;
  final bool isRead;
  final DateTime createdAt;

  const DeviceAlert({
    required this.id,
    required this.deviceId,
    required this.deviceNo,
    required this.roomTitle,
    required this.alertType,
    required this.message,
    required this.level,
    this.isRead = false,
    required this.createdAt,
  });
}

enum AlertLevel { info, warning, critical }
