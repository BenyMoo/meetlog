import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_provider.dart';
import 'routes/app_router.dart';
import 'services/local_db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await LocalDbService.instance.init();
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('应用启动失败: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final lightTheme = ref.watch(appThemeProvider);
    final darkTheme = ref.watch(appDarkThemeProvider);

    return MaterialApp.router(
      title: '遇记',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: toMaterialThemeMode(themeMode),
      routerConfig: router,
    );
  }
}
