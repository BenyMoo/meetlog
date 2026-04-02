import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const proActivationWechat = '易悦网络';

// 激活码，用于激活专业版功能
const _proActivationCode = 'qwe123';
// const _proActivationCode = 'YYWL-PRO-2026';

final proActivatedProvider =
    StateNotifierProvider<ProActivationNotifier, bool>((ref) {
  return ProActivationNotifier();
});

class ProActivationNotifier extends StateNotifier<bool> {
  static const String _key = 'pro_activated';

  ProActivationNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<bool> activate(String code) async {
    if (code.trim().toUpperCase() != _proActivationCode) {
      return false;
    }
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    return true;
  }
}
