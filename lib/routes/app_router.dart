import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/main_screen.dart';
import '../screens/records_screen.dart';
import '../screens/contacts_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/add_record_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/launch_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/launch',
    routes: [
      GoRoute(
        path: '/launch',
        name: 'launch',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LaunchScreen(),
        ),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/records',
            name: 'records',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RecordsScreen(),
            ),
          ),
          GoRoute(
            path: '/contacts',
            name: 'contacts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ContactsScreen(),
            ),
          ),
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/add-record',
        name: 'add-record',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: AddRecordScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: SettingsScreen(),
        ),
      ),
    ],
  );
});
