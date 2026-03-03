import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';

class SupabaseService {
  static Future<void> initialize() async {
    if (AppConstants.supabaseUrl.isEmpty || AppConstants.supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing Supabase env vars. Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
      );
    }

    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
