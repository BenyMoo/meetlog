import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图鉴'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('联系人图鉴页面 - 待开发'),
      ),
    );
  }
}
