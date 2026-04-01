import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final currentTabIndexProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabIndexProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        height: 44,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(currentTabIndexProvider.notifier).state = index;
          switch (index) {
            case 0:
              context.go('/records');
              break;
            case 1:
              context.go('/contacts');
              break;
            case 2:
              context.go('/dashboard');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined, size: 16),
            selectedIcon: Icon(Icons.edit_note, size: 16),
            label: '记录',
          ),
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined, size: 16),
            selectedIcon: Icon(Icons.contacts, size: 16),
            label: '联系人',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined, size: 16),
            selectedIcon: Icon(Icons.analytics, size: 16),
            label: '复盘',
          ),
        ],
      ),
    );
  }
}
