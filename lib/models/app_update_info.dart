class AppUpdateInfo {
  final String version;
  final String buildNumber;
  final String releaseNotes;
  final String downloadUrl;
  final String publishDate;
  final bool forceUpdate;

  const AppUpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.publishDate,
    this.forceUpdate = false,
  });

  factory AppUpdateInfo.fromJson(
    Map<String, dynamic> json, {
    required String assetExtension,
  }) {
    final assets = json['assets'] as List? ?? [];
    String downloadUrl = '';
    for (final asset in assets) {
      final name = (asset as Map)['name'] as String? ?? '';
      if (name.toLowerCase().endsWith(assetExtension.toLowerCase())) {
        downloadUrl = (asset['browser_download_url'] as String?) ?? '';
        break;
      }
    }

    if (downloadUrl.isEmpty && assets.isNotEmpty) {
      final firstAsset = assets.first as Map;
      downloadUrl = (firstAsset['browser_download_url'] as String?) ?? '';
    }

    return AppUpdateInfo(
      version: json['tag_name'] as String? ?? '',
      buildNumber: '',
      releaseNotes: _cleanBody(json['body'] as String? ?? ''),
      downloadUrl: downloadUrl,
      publishDate: json['published_at'] as String? ?? '',
    );
  }

  static String _cleanBody(String body) {
    return body
        .replaceAll(RegExp(r'##\s*'), '')
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'-\s*'), '• ')
        .trim();
  }
}
