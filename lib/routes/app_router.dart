import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/main_screen.dart';
import '../screens/records_screen.dart';
import '../screens/contacts_screen.dart';
import '../screens/dashboard_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/records',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
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
    ],
  );
});
