import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
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
  bool _isEmailVerified = false;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get userEmail => _userEmail;
  String get userId => _userId;
  String get userRole => _userRole;
  bool get isEmployeeUser => _userRole == 'employee';
  bool get isHrAdmin => _userRole == 'hr';
  bool get isSuperAdmin => _userRole == 'super_admin';
  bool get isEmailVerified => _isEmailVerified;
  String? get errorMessage => _errorMessage;
  String get subscriptionStatus => _subscriptionStatus;
  String get subscriptionPlan => _subscriptionPlan;
  bool get hasActiveSubscription =>
      {'active', 'trial'}.contains(_subscriptionStatus);

  bool get isSuperAdmin => null;

  bool get isHrAdmin => null;

  bool get isEmailVerified => null;

  Future<void> restoreSession() async {
    await _syncUser(_authService.currentUser);
  }

  Future<void> _syncUser(User? user) async {
    _isLoggedIn = user != null;
    _userEmail = user?.email ?? '';
    _userId = user?.id ?? '';
    _isEmailVerified = user?.emailConfirmedAt != null;
    _userRole = 'employee';

    if (user != null) {
      await _loadRole(user);
    }

    notifyListeners();
  }

  Future<void> _loadRole(User user) async {
    final roleFromMetadata = user.userMetadata?['role']?.toString();

    if (roleFromMetadata != null && roleFromMetadata.isNotEmpty) {
      _userRole = roleFromMetadata;
      return;
    }

    try {
      final profile = await _authService.fetchUserProfileRole(user.id);
      final dbRole = profile?['role']?.toString();
      _userRole = (dbRole == null || dbRole.isEmpty) ? 'employee' : dbRole;
    } catch (_) {
      _userRole = 'employee';
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signIn(email: email, password: password);
      await _syncUser(response.user ?? _authService.currentUser);
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
      final profile = await SupabaseService.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      _userRole =
          (profile?['role'] ?? user.userMetadata?['role'] ?? 'hr').toString();
    } catch (_) {
      _errorMessage = 'Failed to send password reset email.';
    }
    notifyListeners();
  }

  Future<void> resendVerification(String email) async {
    _errorMessage = null;
    try {
      await _authService.resendEmailVerification(email);
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to resend verification email.';
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _isLoggedIn = false;
    _isLoading = false;
    _userEmail = '';
    _userId = '';
    _userRole = 'employee';
    _isEmailVerified = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _syncUser(User? user) async {
    _isLoggedIn = user != null;
    _userEmail = user?.email ?? '';
    _userId = user?.id ?? '';

    if (user != null) {
      await _loadRole(user);
    } else {
      _userRole = 'hr';
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
