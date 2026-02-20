import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService() {
    _authSub = _authService.authStateChanges.listen((event) {
      _syncUser(event.session?.user ?? _authService.currentUser);
    });
  }

  final AuthService _authService;
  StreamSubscription<AuthState>? _authSub;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _userEmail = '';
  String _userId = '';
  String _userRole = 'employee';
  String? _companyId;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get userEmail => _userEmail;
  String get userId => _userId;
  String get userRole => _userRole;
  String? get companyId => _companyId;
  bool get isSuperAdmin => _userRole == 'super_admin';
  bool get isHrAdmin => _userRole == 'hr_admin';
  bool get isEmployeeUser => _userRole == 'employee';
  bool get isEmailVerified => _authService.currentUser?.emailConfirmedAt != null;
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    await _syncUser(_authService.currentUser);
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signIn(email: email, password: password);
      await _syncUser(response.user);
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

  Future<void> sendPasswordReset(String email) async {
    _errorMessage = null;
    try {
      await _authService.sendPasswordResetEmail(email);
    } on AuthException catch (e) {
      _errorMessage = e.message;
    }
    notifyListeners();
  }

  Future<void> resendVerification(String email) async {
    _errorMessage = null;
    try {
      await _authService.resendEmailVerification(email);
    } on AuthException catch (e) {
      _errorMessage = e.message;
    }
    notifyListeners();
  }

  Future<void> _syncUser(User? user) async {
    _isLoggedIn = user != null;
    _userEmail = user?.email ?? '';
    _userId = user?.id ?? '';

    if (user != null) {
      await _loadRoleFromDb(user.id);
    } else {
      _userRole = 'employee';
      _companyId = null;
    }

    notifyListeners();
  }

  Future<void> _loadRoleFromDb(String authUserId) async {
    try {
      final row = await _authService.fetchUserProfileRole(authUserId);
      _userRole = (row?['role'] ?? _userRole).toString();
      _companyId = row?['company_id']?.toString();
    } catch (_) {
      _userRole = 'employee';
      _companyId = null;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _isLoggedIn = false;
    _userEmail = '';
    _userId = '';
    _userRole = 'employee';
    _companyId = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
