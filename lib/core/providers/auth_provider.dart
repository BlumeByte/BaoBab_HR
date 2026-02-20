import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _userEmail = '';
  String _userId = '';
  String _userRole = 'hr';
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get userEmail => _userEmail;
  String get userId => _userId;
  String get userRole => _userRole;
  bool get isEmployeeUser => _userRole.toLowerCase() == 'employee';
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    final user = SupabaseService.client.auth.currentUser;
    _isLoggedIn = user != null;
    _userEmail = user?.email ?? '';
    _userId = user?.id ?? '';
    if (user != null) {
      await _loadRole(user);
    }
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
      _userId = user?.id ?? '';
      if (user != null) {
        await _loadRole(user);
      }
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

  Future<void> _loadRole(User user) async {
    try {
      final profile = await SupabaseService.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      _userRole = (profile?['role'] ?? user.userMetadata?['role'] ?? 'hr').toString();
    } catch (_) {
      _userRole = (user.userMetadata?['role'] ?? 'hr').toString();
    }
  }

  Future<void> logout() async {
    await SupabaseService.client.auth.signOut();
    _isLoggedIn = false;
    _userEmail = '';
    _userId = '';
    _userRole = 'hr';
    _errorMessage = null;
    notifyListeners();
  }
}
