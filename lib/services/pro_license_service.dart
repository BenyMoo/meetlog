import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const proActivationWechat = '易悦网络';

// Replace these PEM public keys with your production keys before release.
const proRequestPublicKeyPem = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtLEEZvRT9KVMR+guV7Or
YegyJovksqEcSFSfbWVF4Q9UX8qNT/5vepuujyq1zAis1N9NyzticZRwqwkROOXq
PuwHaZV7VKC4h/ctAdtxW1ga2uAyBBP4Iz8qkzp5HsCMiFXrvkEi0jwRFnLF8QMh
WyOJko9T6h9kbXsUiCTLD/9cIgdoxeq0kb5yDxoVrZRmbJpECyZnzqdCb05eUbut
S9M3rflEncO/w09z3/PHu8DLOgc5YM/ZoehcNce9SsRX7t+9wh0adStVkEe03apX
9WiUdlqA0hPphuypMkU7CW5oAVPCLffFWuDqgzAMdoZjnmgJeI3IoVrjKIEtfDsS
cQIDAQAB
-----END PUBLIC KEY-----
''';

const proLicenseVerifyPublicKeyPem = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoyKS7v/IH2nmDuSECRw9
1srpYcid+c1RNgbWGe+U3+YCH/tvFap4H2aLQYPjTEyXyFAni+ZLTldhTfKzKpNY
IwdKWcYJ/03U1CorTlplOQbcKLS7rL3pYOZBqpRMSYso2GmwuVANtE7aokhCz155
FJzF7M+XM1Da7zTIC3VQaJxlthYYF14MoCfY+Ts7d2dBcx14gt0Y5jNMt5l45+a3
LKyulLGqLLMLVN9sf+y1nwHJvRcXz/8bQAL9ZVz1hjUj1hrvyk/FXN9YzAK7cTc3
2sFRL3pWLAZ/xA+hFnlo1erKbSYEcD0J/X6rJwklYUCAhNDacpusjF2+LCi0iN56
HQIDAQAB
-----END PUBLIC KEY-----
''';

const proAppId = 'meetlog.pro';

class DeviceIdentity {
  const DeviceIdentity({
    required this.deviceIdType,
    required this.maskedDeviceId,
    required this.deviceFingerprint,
  });

  final String deviceIdType;
  final String maskedDeviceId;
  final String deviceFingerprint;

  factory DeviceIdentity.fromMap(Map<Object?, Object?> map) {
    return DeviceIdentity(
      deviceIdType: (map['deviceIdType'] ?? 'unknown').toString(),
      maskedDeviceId: (map['maskedDeviceId'] ?? '').toString(),
      deviceFingerprint: (map['deviceFingerprint'] ?? '').toString(),
    );
  }
}

class LicenseVerificationResult {
  const LicenseVerificationResult({
    required this.valid,
    required this.reason,
    this.payload,
  });

  final bool valid;
  final String reason;
  final Map<String, dynamic>? payload;

  factory LicenseVerificationResult.fromMap(Map<Object?, Object?> map) {
    final rawPayload = map['payload'];
    return LicenseVerificationResult(
      valid: map['valid'] == true,
      reason: (map['reason'] ?? '').toString(),
      payload: rawPayload is Map
          ? rawPayload.map(
              (key, value) => MapEntry(key.toString(), value),
            )
          : null,
    );
  }
}

class ProLicenseService {
  ProLicenseService._internal();

  static final ProLicenseService instance = ProLicenseService._internal();

  static const _channel = MethodChannel('com.meetlog.meetlog/license');
  static const _licenseKey = 'pro_license';

  void _ensureRequestKeyConfigured() {
    if (proRequestPublicKeyPem.contains('REPLACE_WITH_')) {
      throw Exception('尚未配置请求加密公钥，请先替换 `proRequestPublicKeyPem`');
    }
  }

  void _ensureVerifyKeyConfigured() {
    if (proLicenseVerifyPublicKeyPem.contains('REPLACE_WITH_')) {
      throw Exception('尚未配置许可证验签公钥，请先替换 `proLicenseVerifyPublicKeyPem`');
    }
  }

  Future<DeviceIdentity> getDeviceIdentity() async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'getDeviceIdentity',
    );
    if (result == null) {
      throw Exception('无法读取设备标识');
    }
    return DeviceIdentity.fromMap(result);
  }

  Future<String> buildActivationRequest() async {
    _ensureRequestKeyConfigured();
    final encrypted = await _channel.invokeMethod<String>(
      'buildActivationRequest',
      {
        'appId': proAppId,
        'publicKeyPem': proRequestPublicKeyPem,
      },
    );
    if (encrypted == null || encrypted.isEmpty) {
      throw Exception('生成激活请求失败');
    }
    return encrypted;
  }

  Future<LicenseVerificationResult> verifyLicense(String license) async {
    _ensureVerifyKeyConfigured();
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'verifyLicense',
      {
        'license': license,
        'appId': proAppId,
        'publicKeyPem': proLicenseVerifyPublicKeyPem,
      },
    );
    if (result == null) {
      return const LicenseVerificationResult(
        valid: false,
        reason: '本地验证失败',
      );
    }
    return LicenseVerificationResult.fromMap(result);
  }

  Future<void> persistLicense(String license) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_licenseKey, license.trim());
  }

  Future<String?> getPersistedLicense() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_licenseKey);
  }

  Future<void> clearPersistedLicense() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_licenseKey);
  }

  Future<bool> hasValidPersistedLicense() async {
    final license = await getPersistedLicense();
    if (license == null || license.trim().isEmpty) {
      return false;
    }
    final result = await verifyLicense(license);
    if (!result.valid) {
      await clearPersistedLicense();
      return false;
    }
    return true;
  }

  String prettyPrintPayload(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) {
      return '';
    }
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}
