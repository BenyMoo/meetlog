import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/pro_license_service.dart';

final proActivatedProvider =
    StateNotifierProvider<ProActivationNotifier, bool>((ref) {
  return ProActivationNotifier();
});

class ProActivationNotifier extends StateNotifier<bool> {
  final ProLicenseService _service = ProLicenseService.instance;

  ProActivationNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    state = await _service.hasValidPersistedLicense();
  }

  Future<DeviceIdentity> getDeviceIdentity() {
    return _service.getDeviceIdentity();
  }

  Future<String> buildActivationRequest() {
    return _service.buildActivationRequest();
  }

  Future<LicenseVerificationResult> activate(String license) async {
    final result = await _service.verifyLicense(license);
    if (!result.valid) {
      state = false;
      return result;
    }
    await _service.persistLicense(license);
    state = true;
    return result;
  }

  Future<void> deactivate() async {
    await _service.clearPersistedLicense();
    state = false;
  }
}
