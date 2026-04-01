import 'package:flutter/material.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('记录页面 - 待开发'),
      ),
    );
  }
}
