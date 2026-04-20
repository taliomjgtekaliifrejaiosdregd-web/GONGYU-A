import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

/// 阿里云 OSS 配置
class OssConfig {
  final String accessKeyId;
  final String accessKeySecret;
  final String bucket;
  final String region;
  String get endpoint => 'https://$bucket.$region.aliyuncs.com';

  const OssConfig({
    required this.accessKeyId,
    required this.accessKeySecret,
    required this.bucket,
    required this.region,
  });
}

/// OSS 服务 - Web 端通过预签名 URL 上传
class OssService {
  final OssConfig config;

  OssService(this.config);

  /// 生成预签名上传 URL（V1 签名）
  String _buildPresignedUrl({
    required String objectKey,
    required String httpMethod,
    int expiresSeconds = 3600,
    String contentType = '',
    Map<String, String>? customHeaders,
  }) {
    final now = DateTime.now().toUtc();
    final expires = now.millisecondsSinceEpoch ~/ 1000 + expiresSeconds;
    final date = DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US').format(now) + ' GMT';

    final canonicalizedHeaders = customHeaders != null && customHeaders.isNotEmpty
        ? customHeaders.entries
            .map((e) => '${e.key.toLowerCase()}:${e.value}')
            .join('\n') + '\n'
        : '';

    final canonicalizedResource = '/${config.bucket}/$objectKey';

    // CORS 预检请求需要的方法和额外头部
    final stringToSign = '$httpMethod\n\n$contentType\n$expires\n'
        '${customHeaders?.keys.map((k) => k.toLowerCase()).join(';') ?? ''}\n'
        '$canonicalizedHeaders'
        '$canonicalizedResource';

    final signature = Hmac(sha1, utf8.encode(config.accessKeySecret))
        .convert(utf8.encode(stringToSign))
        .toString();

    final params = {
      'Expires': '$expires',
      'OSSAccessKeyId': config.accessKeyId,
      'Signature': signature,
    };

    final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return '${config.endpoint}/$objectKey?$queryString';
  }

  /// 上传文件到 OSS
  /// [file] HTML File 对象
  /// [folder] OSS 目录前缀，如 'room-images/'
  /// 返回文件的公开访问 URL
  Future<String> uploadFile(html.File file, {String folder = 'uploads/'}) async {
    final ext = file.name.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final objectKey = '${folder}${timestamp}_${file.name}';

    // 读取文件内容
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();
    reader.onLoadEnd.listen((_) {
      completer.complete(reader.result as Uint8List);
    });
    reader.readAsArrayBuffer(file);
    final bytes = await completer.future;

    // 生成预签名 URL
    final url = _buildPresignedUrl(
      objectKey: objectKey,
      httpMethod: 'PUT',
      contentType: file.type,
    );

    // 上传
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': file.type},
      body: bytes,
    );

    if (response.statusCode == 200) {
      return 'https://${config.bucket}.${config.region}.aliyuncs.com/$objectKey';
    } else {
      throw Exception('OSS 上传失败: ${response.statusCode} ${response.body}');
    }
  }

  /// 上传字节数据到 OSS
  Future<String> uploadBytes(
    Uint8List bytes, {
    required String fileName,
    String contentType = 'image/jpeg',
    String folder = 'uploads/',
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final objectKey = '${folder}${timestamp}_$fileName';

    final url = _buildPresignedUrl(
      objectKey: objectKey,
      httpMethod: 'PUT',
      contentType: contentType,
    );

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': contentType},
      body: bytes,
    );

    if (response.statusCode == 200) {
      return 'https://${config.bucket}.${config.region}.aliyuncs.com/$objectKey';
    } else {
      throw Exception('OSS 上传失败: ${response.statusCode} ${response.body}');
    }
  }

  /// 删除文件
  Future<void> deleteFile(String objectKey) async {
    final url = _buildPresignedUrl(
      objectKey: objectKey,
      httpMethod: 'DELETE',
    );

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode != 204) {
      throw Exception('OSS 删除失败: ${response.statusCode}');
    }
  }

  /// 获取文件列表（简单版，最多100条）
  Future<List<String>> listFiles({String prefix = ''}) async {
    final date = DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US').format(DateTime.now().toUtc()) + ' GMT';
    final canonicalizedResource = '/${config.bucket}/';
    final stringToSign = 'GET\n\n\n\n/$canonicalizedResource';

    final signature = Hmac(sha1, utf8.encode(config.accessKeySecret))
        .convert(utf8.encode(stringToSign))
        .toString();

    final params = {
      'prefix': prefix,
      'max-keys': '100',
      'OSSAccessKeyId': config.accessKeyId,
      'Signature': signature,
    };

    final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final url = '${config.endpoint}?$queryString';

    final response = await http.get(Uri.parse(url), headers: {
      'Date': date,
    });

    if (response.statusCode == 200) {
      // 解析 XML 响应
      final regExp = RegExp(r'<Key>([^<]+)</Key>');
      return regExp.allMatches(response.body).map((m) => m.group(1)!).toList();
    } else {
      throw Exception('OSS 列表失败: ${response.statusCode}');
    }
  }
}

/// 全局 OSS 实例
late OssService ossService;

/// 初始化 OSS 服务（在 main.dart 中调用）
void initOss({
  required String accessKeyId,
  required String accessKeySecret,
  required String bucket,
  required String region,
}) {
  final config = OssConfig(
    accessKeyId: accessKeyId,
    accessKeySecret: accessKeySecret,
    bucket: bucket,
    region: region,
  );
  ossService = OssService(config);
}

/// 显示文件选择器并上传
Future<String?> pickAndUploadFile({String folder = 'uploads/'}) async {
  final upload = html.FileUploadInputElement();
  upload.accept = 'image/*';
  upload.click();

  await upload.onChange.first;
  if (upload.files == null || upload.files!.isEmpty) return null;

  final file = upload.files!.first;
  return ossService.uploadFile(file, folder: folder);
}
