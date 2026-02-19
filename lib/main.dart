import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const BaobabHRApp());
}

class BaobabHRApp extends StatelessWidget {
  const BaobabHRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..restoreSession()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = context.watch<ThemeProvider>();
          final authProvider = context.watch<AuthProvider>();

          const blueSeed = Color(AppConstants.bambooInspiredBlue);
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: blueSeed, brightness: Brightness.light),
              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: blueSeed, brightness: Brightness.dark),
              useMaterial3: true,
            ),
            routerConfig: createRouter(authProvider),
          );
        },
      ),
    );
  }
}
