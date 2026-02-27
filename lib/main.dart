import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/supabase_service.dart';
import 'views/shared/error_boundary.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  await runZonedGuarded(() async {
    await SupabaseService.initialize();
    runApp(const BaobabHRApp());
  }, (error, stackTrace) {
    // Preserve for platform logs while showing fallback UI via ErrorWidget.
    // ignore: avoid_print
    print('Unhandled app error: $error');
  });
}

class BaobabHRApp extends StatelessWidget {
  const BaobabHRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..restoreSession()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..loadProfile()),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = context.watch<ThemeProvider>();
          final authProvider = context.watch<AuthProvider>();

          const blueSeed = Color(AppConstants.bambooInspiredBlue);
          ErrorWidget.builder = (details) => AppErrorBoundary(
              error: details.exception, child: const SizedBox());
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: blueSeed, brightness: Brightness.light),
              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: blueSeed, brightness: Brightness.dark),
              useMaterial3: true,
            ),
            routerConfig: createRouter(authProvider),
          );
        },
      ),
    );
  }
}
