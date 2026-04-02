import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_update_info.dart';

class AppUpdateService {
  static const _owner = 'BenyMoo';
  static const _repo = 'meetlog';
  static const _apiUrl =
      'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  Future<PackageInfo> getLocalVersion() async {
    return PackageInfo.fromPlatform();
  }

  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final remoteInfo = AppUpdateInfo.fromJson(
        json,
        assetExtension: Platform.isIOS ? '.ipa' : '.apk',
      );

      final local = await getLocalVersion();
      final localVersion = local.version;
      final localBuild = int.tryParse(local.buildNumber) ?? 0;

      if (_needsUpdate(localVersion, localBuild, remoteInfo.version)) {
        if (remoteInfo.downloadUrl.isEmpty) {
          return null;
        }
        return remoteInfo;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  bool _needsUpdate(
    String localVersion,
    int localBuild,
    String remoteTag,
  ) {
    final remoteVersion = remoteTag.replaceAll(RegExp(r'^[vV]'), '');
    
    // 如果 remoteTag 不是版本号格式（如 master），尝试从 assets 中推断版本
    if (!RegExp(r'^\d+\.\d+').hasMatch(remoteVersion)) {
      return true;
    }
    
    final parts = remoteVersion.split('.');
    final localParts = localVersion.split('.');

    for (var i = 0; i < 3; i++) {
      final r = i < parts.length ? int.tryParse(parts[i]) ?? 0 : 0;
      final l = i < localParts.length ? int.tryParse(localParts[i]) ?? 0 : 0;
      if (r > l) return true;
      if (r < l) return false;
    }
    return false;
  }
}
