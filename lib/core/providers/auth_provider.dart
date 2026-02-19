import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _userEmail = '';
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get userEmail => _userEmail;
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    final user = SupabaseService.client.auth.currentUser;
    _isLoggedIn = user != null;
    _userEmail = user?.email ?? '';
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      _isLoggedIn = user != null;
      _userEmail = user?.email ?? '';
      return _isLoggedIn;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoggedIn = false;
      return false;
    } catch (_) {
      _errorMessage = 'Login failed. Please try again.';
      _isLoggedIn = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await SupabaseService.client.auth.signOut();
    _isLoggedIn = false;
    _userEmail = '';
    _errorMessage = null;
    notifyListeners();
  }
}
