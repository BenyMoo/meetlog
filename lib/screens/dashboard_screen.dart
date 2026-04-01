import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('复盘'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('数据统计面板 - 待开发'),
      ),
    );
  }
}
