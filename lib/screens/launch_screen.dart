import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/app_update_info.dart';
import '../services/app_update_service.dart';
import '../widgets/update_dialog.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  Timer? _timer;
  AppUpdateInfo? _updateInfo;

  @override
  void initState() {
    super.initState();
    _checkUpdate();
    _timer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        context.go('/records');
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _updateInfo != null) {
            UpdateDialog.show(context, _updateInfo!);
          }
        });
      }
    });
  }

  Future<void> _checkUpdate() async {
    final service = AppUpdateService();
    final info = await service.checkForUpdate();
    if (mounted && info != null) {
      setState(() => _updateInfo = info);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: ColoredBox(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        child: SizedBox.expand(
          child: Image.asset(
            'assets/png/Screen.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
