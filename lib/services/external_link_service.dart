import 'package:flutter/services.dart';

class ExternalLinkService {
  ExternalLinkService._();

  static const MethodChannel _channel = MethodChannel(
    'com.meetlog.meetlog/external_link',
  );

  static Future<void> open(String url) async {
    await _channel.invokeMethod<void>('openExternalUrl', {
      'url': url,
    });
  }
}
