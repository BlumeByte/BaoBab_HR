import 'package:flutter/material.dart';

import '../services/supabase_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isSaving = false;

  bool get isDarkMode => _isDarkMode;
  bool get isSaving => _isSaving;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadThemePreference() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      _isDarkMode = false;
      notifyListeners();
      return;
    }

    try {
      final profile = await SupabaseService.client
          .from('profiles')
          .select('theme_mode')
          .eq('id', user.id)
          .maybeSingle();
      final themeMode = (profile?['theme_mode'] ?? 'light').toString().toLowerCase();
      _isDarkMode = themeMode == 'dark';
      notifyListeners();
    } catch (_) {
      _isDarkMode = false;
      notifyListeners();
    }
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    _isSaving = true;
    notifyListeners();

    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      try {
        await SupabaseService.client.from('profiles').upsert({
          'id': user.id,
          'theme_mode': value ? 'dark' : 'light',
        });
      } catch (_) {}
    }

    _isSaving = false;
    notifyListeners();
  }
}
