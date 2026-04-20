// ============================================================
// 涂鸦智能门锁服务层
// 文档：https://developer.tuya.com/cn/docs/iot/device-management?id=Kbqgg3t9t1m8d
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gongyu_guanjia/models/device.dart';
import 'package:gongyu_guanjia/services/mock_service.dart';

/// 开锁方式
enum UnlockMethod {
  password('密码开锁', 'password'),
  fingerprint('指纹开锁', 'finger_print'),
  icCard('门卡开锁', 'face_id'),
  face('人脸开锁', 'face_recognition'),
  remote('APP开锁', 'remote');

  final String label;
  final String tuyaCode;
  const UnlockMethod(this.label, this.tuyaCode);
}

/// 密码类型
enum PasswordType {
  permanent('永久密码', 'active'),
  temporary('临时密码', 'dynamic'),
  periodic('周期密码', 'cycle');

  final String label;
  final String tuyaCode;
  const PasswordType(this.label, this.tuyaCode);
}

/// 开锁记录
class LockUnlockRecord {
  final String id;
  final DateTime time;
  final UnlockMethod method;
  final bool success;
  final String? lockName;
  final String? lockNo;

  const LockUnlockRecord({
    required this.id,
    required this.time,
    required this.method,
    required this.success,
    this.lockName,
    this.lockNo,
  });
}

/// 门锁密码
class LockPassword {
  final String id;
  final String password; // 显示用（部分隐藏）
  final PasswordType type;
  final DateTime? validFrom;
  final DateTime? validTo;
  final int? maxUseCount;
  final int usedCount;
  final bool isActive;

  const LockPassword({
    required this.id,
    required this.password,
    required this.type,
    this.validFrom,
    this.validTo,
    this.maxUseCount,
    this.usedCount = 0,
    this.isActive = true,
  });
}

/// 门锁状态
class LockStatus {
  final String lockId;
  final String lockName;
  final String lockNo;
  final int batteryLevel; // 0-100
  final bool isOnline;
  final bool isLocked;
  final int alertCount;

  const LockStatus({
    required this.lockId,
    required this.lockName,
    required this.lockNo,
    required this.batteryLevel,
    required this.isOnline,
    required this.isLocked,
    this.alertCount = 0,
  });
}

/// 涂鸦门锁服务
/// 配置说明：
/// 1. 注册涂鸦 IoT 平台：https://iot.tuya.com/user/login
/// 2. 创建应用，获取 AccessId / AccessKey
/// 3. 在涂鸦开发者后台添加智能门锁设备
/// 4. 将 _useMock 改为 false，填入真实凭证
class TuyaLockService {
  // ===================== API配置 =====================
  static const String _accessId  = 'YOUR_TUYA_ACCESS_ID';
  static const String _accessKey = 'YOUR_TUYA_ACCESS_KEY';
  // 美区: openapi.tuyaus.com  国内: openapi.tuyacn.com  欧洲: openapi.tuyaeu.com
  static const String _baseUrl   = 'https://openapi.tuyaus.com';
  static const Duration _timeout = Duration(seconds: 10);

  // ===================== Mock开关 =====================
  // 正式上线时改为 false
  static const bool _useMock = true;

  // ===================== Token管理 =====================
  static String? _token;
  static DateTime? _tokenExpire;

  static Future<String> _getToken() async {
    if (_token != null && _tokenExpire != null && DateTime.now().isBefore(_tokenExpire!)) {
      return _token!;
    }
    final resp = await http.post(
      Uri.parse('$_baseUrl/user/user/token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'grant_type': 1,
        'code': '',
        'username': '',
        'password': '',
        'country_code': '86',
      }),
    ).timeout(_timeout);
    final body = jsonDecode(resp.body);
    if (body['success'] == true) {
      _token = body['result']['access_token'];
      _tokenExpire = DateTime.now().add(const Duration(hours: 2));
      return _token!;
    }
    throw Exception('涂鸦Token获取失败: ${body['msg']}');
  }

  // ===================== 核心API =====================

  /// 获取当前用户的所有门锁
  /// tenantId: 租客ID（用于筛选该租客名下的门锁）
  static Future<List<LockStatus>> getLocks(String tenantId) async {
    if (_useMock) return _mockLocks();

    await _getToken();
    final resp = await http.get(
      Uri.parse('$_baseUrl/device/list?last_row_key=&page_size=50'),
      headers: {'Authorization': 'Bearer $_token'},
    ).timeout(_timeout);
    final body = jsonDecode(resp.body);
    final devices = (body['result']?['list'] ?? []) as List;
    return devices
        .where((d) => d['category'] == 'bl') // bl = 智能门锁
        .map((d) => LockStatus(
          lockId: d['id'],
          lockName: d['name'] ?? '未知门锁',
          lockNo: d['dev_id'] ?? '',
          batteryLevel: (d['battery'] ?? 100) as int,
          isOnline: d['online'] ?? false,
          isLocked: true,
          alertCount: 0,
        ))
        .toList();
  }

  /// 获取指定门锁实时状态
  static Future<LockStatus> getLockStatus(String lockId) async {
    if (_useMock) return _mockLocks().firstWhere((l) => l.lockId == lockId, orElse: () => _mockLocks().first);

    await _getToken();
    final resp = await http.get(
      Uri.parse('$_baseUrl/device/$lockId/status'),
      headers: {'Authorization': 'Bearer $_token'},
    ).timeout(_timeout);
    final body = jsonDecode(resp.body);
    final props = body['result']?['properties'] ?? [];
    int battery = 100;
    bool online = false;
    for (var p in props) {
      if (p['code'] == 'battery_percentage') battery = p['value'] as int;
      if (p['code'] == 'online') online = p['value'] as bool;
    }
    return LockStatus(
      lockId: lockId, lockName: '门锁', lockNo: lockId,
      batteryLevel: battery, isOnline: online, isLocked: true,
    );
  }

  /// 远程开锁
  /// 返回 true 表示指令发送成功
  static Future<bool> unlock(String lockId, {UnlockMethod method = UnlockMethod.remote}) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    }
    await _getToken();
    final resp = await http.post(
      Uri.parse('$_baseUrl/device/$lockId/commands'),
      headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
      body: jsonEncode([{'code': 'unlock', 'value': {'type': method.tuyaCode}}]),
    ).timeout(_timeout);
    final body = jsonDecode(resp.body);
    return body['success'] == true;
  }

  /// 获取开锁记录
  static Future<List<LockUnlockRecord>> getUnlockRecords(
    String lockId, {DateTime? startDate, DateTime? endDate, int page = 1, int pageSize = 20}
  ) async {
    if (_useMock) return _mockUnlockRecords();

    await _getToken();
    final params = {
      'page': page.toString(),
      'size': pageSize.toString(),
      if (startDate != null) 'start_time': startDate.millisecondsSinceEpoch.toString(),
      if (endDate != null) 'end_time': endDate.millisecondsSinceEpoch.toString(),
    };
    final resp = await http.get(
      Uri.parse('$_baseUrl/device/$lockId/records').replace(queryParameters: params),
      headers: {'Authorization': 'Bearer $_token'},
    ).timeout(_timeout);
    final body = jsonDecode(resp.body);
    final logs = (body['result']?['records'] ?? []) as List;
    return logs.map((r) {
      final methodStr = r['operate_type'] as String? ?? '';
      UnlockMethod m = UnlockMethod.remote;
      for (var m2 in UnlockMethod.values) {
        if (m2.tuyaCode == methodStr) { m = m2; break; }
      }
      return LockUnlockRecord(
        id: r['record_id'] ?? '',
        time: DateTime.fromMillisecondsSinceEpoch((r['create_time'] ?? 0) as int),
        method: m,
        success: (r['result'] ?? 1) == 1,
        lockName: r['lock_name'],
        lockNo: r['lock_no'],
      );
    }).toList();
  }

  /// 创建门锁密码
  static Future<LockPassword> createPassword(
    String lockId, String password, {
    required PasswordType type,
    DateTime? validFrom, DateTime? validTo, int? maxUseCount,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return LockPassword(
        id: 'pwd_${DateTime.now().millisecondsSinceEpoch}',
        password: _maskPassword(password),
        type: type,
        validFrom: validFrom, validTo: validTo,
        maxUseCount: maxUseCount,
        usedCount: 0, isActive: true,
      );
    }

    await _getToken();
    final payload = {
      'password': password,
      'password_type': type.tuyaCode,
      if (validFrom != null) 'start_time': validFrom.millisecondsSinceEpoch ~/ 1000,
      if (validTo != null) 'end_time': validTo.millisecondsSinceEpoch ~/ 1000,
      if (maxUseCount != null) 'limited_available_times': maxUseCount,
    };
    final resp = await http.post(
      Uri.parse('$_baseUrl/device/$lockId/password'),
      headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(_timeout);
    final body = jsonDecode(resp.body);
    if (body['success'] != true) throw Exception('密码创建失败: ${body['msg']}');
    final result = body['result'];
    return LockPassword(
      id: result['password_id'],
      password: _maskPassword(password),
      type: type,
      validFrom: validFrom, validTo: validTo,
      maxUseCount: maxUseCount,
    );
  }

  /// 删除密码
  static Future<void> deletePassword(String lockId, String passwordId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _getToken();
    final resp = await http.delete(
      Uri.parse('$_baseUrl/device/$lockId/password/$passwordId'),
      headers: {'Authorization': 'Bearer $_token'},
    ).timeout(_timeout);
    final body = jsonDecode(resp.body);
    if (body['success'] != true) throw Exception('密码删除失败: ${body['msg']}');
  }

  /// 获取密码列表
  static Future<List<LockPassword>> getPasswords(String lockId) async {
    if (_useMock) return _mockPasswords();

    await _getToken();
    final resp = await http.get(
      Uri.parse('$_baseUrl/device/$lockId/passwords'),
      headers: {'Authorization': 'Bearer $_token'},
    ).timeout(_timeout);
    final body = jsonDecode(resp.body);
    final list = (body['result'] ?? []) as List;
    return list.map((p) {
      PasswordType type = PasswordType.permanent;
      for (var t in PasswordType.values) {
        if (t.tuyaCode == p['password_type']) { type = t; break; }
      }
      return LockPassword(
        id: p['password_id'],
        password: _maskPassword(p['password'] ?? ''),
        type: type,
        validFrom: p['start_time'] != null
            ? DateTime.fromMillisecondsSinceEpoch((p['start_time'] as int) * 1000) : null,
        validTo: p['end_time'] != null
            ? DateTime.fromMillisecondsSinceEpoch((p['end_time'] as int) * 1000) : null,
        maxUseCount: p['limited_available_times'],
        usedCount: p['available_times'] ?? 0,
        isActive: p['status'] == 1,
      );
    }).toList();
  }

  // 密码脱敏：123456 -> 1*3*5*
  static String _maskPassword(String pwd) {
    if (pwd.length < 4) return pwd;
    return pwd.split('').asMap().entries.map((e) {
      return (e.key > 0 && e.key < pwd.length - 1) ? '*' : e.value;
    }).join();
  }

  // ===================== Mock数据 =====================

  static List<LockStatus> _mockLocks() {
    return MockService.devices
        .where((d) => d.type == DeviceType.smartLock)
        .map((d) => LockStatus(
          lockId: 'lock_${d.id}',
          lockName: d.roomTitle,
          lockNo: d.deviceNo,
          batteryLevel: d.balance.toInt(),
          isOnline: d.status == DeviceStatus.online || d.status == DeviceStatus.warning,
          isLocked: true,
          alertCount: d.status == DeviceStatus.warning ? 1 : 0,
        ))
        .toList();
  }

  static List<LockUnlockRecord> _mockUnlockRecords() {
    final now = DateTime.now();
    return [
      LockUnlockRecord(id: '1', time: now.subtract(const Duration(minutes: 15)), method: UnlockMethod.password, success: true, lockName: '龙湖景粼原著'),
      LockUnlockRecord(id: '2', time: now.subtract(const Duration(hours: 1, minutes: 30)), method: UnlockMethod.fingerprint, success: true, lockName: '龙湖景粼原著'),
      LockUnlockRecord(id: '3', time: now.subtract(const Duration(hours: 3)), method: UnlockMethod.remote, success: true, lockName: '龙湖景粼原著'),
      LockUnlockRecord(id: '4', time: now.subtract(const Duration(hours: 5)), method: UnlockMethod.password, success: false, lockName: '龙湖景粼原著'),
      LockUnlockRecord(id: '5', time: now.subtract(const Duration(hours: 10)), method: UnlockMethod.fingerprint, success: true, lockName: '龙湖景粼原著'),
      LockUnlockRecord(id: '6', time: now.subtract(const Duration(days: 1, hours: 2)), method: UnlockMethod.icCard, success: true, lockName: '龙湖景粼原著'),
      LockUnlockRecord(id: '7', time: now.subtract(const Duration(days: 1, hours: 14)), method: UnlockMethod.remote, success: true, lockName: '龙湖景粼原著'),
      LockUnlockRecord(id: '8', time: now.subtract(const Duration(days: 2)), method: UnlockMethod.fingerprint, success: true, lockName: '龙湖景粼原著'),
      LockUnlockRecord(id: '9', time: now.subtract(const Duration(days: 3)), method: UnlockMethod.password, success: true, lockName: '龙湖景粼原著'),
      LockUnlockRecord(id: '10', time: now.subtract(const Duration(days: 4)), method: UnlockMethod.face, success: true, lockName: '龙湖景粼原著'),
    ];
  }

  static List<LockPassword> _mockPasswords() {
    final now = DateTime.now();
    return [
      LockPassword(id: 'pwd_1', password: '1*3*5*', type: PasswordType.permanent, usedCount: 42, isActive: true),
      LockPassword(id: 'pwd_2', password: '9*7*5*', type: PasswordType.temporary,
        validFrom: now.subtract(const Duration(hours: 2)),
        validTo: now.add(const Duration(hours: 22)),
        maxUseCount: 3, usedCount: 1, isActive: true),
      LockPassword(id: 'pwd_3', password: '8*2*6*', type: PasswordType.permanent, usedCount: 18, isActive: true),
      LockPassword(id: 'pwd_4', password: '7*1*3*', type: PasswordType.temporary,
        validTo: now.subtract(const Duration(hours: 1)), usedCount: 2, isActive: false),
      LockPassword(id: 'pwd_5', password: '3*9*0*', type: PasswordType.permanent, usedCount: 0, isActive: false),
    ];
  }
}
