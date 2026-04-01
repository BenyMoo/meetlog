import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        context.go('/records');
      }
    });
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
