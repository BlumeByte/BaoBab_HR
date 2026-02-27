import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// A provider for managing authentication state.
///
/// This class wraps the [`AuthService`] to provide a simple stateful API
/// for logging in, logging out and keeping track of the current user's
/// identity and role. It exposes convenience getters that can be used
/// throughout the UI to determine which dashboard to show or which
/// permissions to grant.
class AuthProvider extends ChangeNotifier {
  /// Constructs a new [AuthProvider].
  ///
  /// An optional [authService] can be passed to facilitate testing; if not
  /// provided the default `AuthService()` will be used.
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    // Subscribe to Supabase auth state changes. Whenever the user's
    // session changes we synchronise the local fields and notify
    // listeners so the UI can rebuild.
    _authSub = _authService.authStateChanges.listen((event) {
      _syncUser(event.session?.user ?? _authService.currentUser);
    });
    // Initialise state from the current session on construction.
    _syncUser(_authService.currentUser);
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
  // Optional fields to track the current company's subscription status and plan.
  // These defaults ensure that getters never hit undefined fields when
  // referenced from the UI.
  String _subscriptionStatus = 'inactive';
  String _subscriptionPlan = 'Basic';

  /// Whether a user is currently logged in.
  bool get isLoggedIn => _isLoggedIn;

  /// Whether an asynchronous auth-related operation is in progress.
  bool get isLoading => _isLoading;

  /// The current user's email address, or an empty string if no user.
  String get userEmail => _userEmail;

  /// The current user's Supabase ID, or an empty string if no user.
  String get userId => _userId;

  /// The internal role associated with the current user.
  String get userRole => _userRole;

  /// Convenience getter: true if the current user has the `employee` role.
  bool get isEmployeeUser => _userRole == 'employee';

  /// Convenience getter: true if the current user has the `hr` role.
  bool get isHrAdmin => _userRole == 'hr';

  /// Convenience getter: true if the current user has the `super_admin` role.
  bool get isSuperAdmin => _userRole == 'super_admin';

  /// Whether the current user's email address has been verified.
  bool get isEmailVerified => _isEmailVerified;

  /// Any error message produced by the last auth operation, or null.
  String? get errorMessage => _errorMessage;

  /// The status of the current company's subscription (e.g. "active", "trial" or "inactive").
  String get subscriptionStatus => _subscriptionStatus;

  /// The name of the subscription plan (e.g. "Basic", "Pro", etc.).
  String get subscriptionPlan => _subscriptionPlan;

  /// Returns true if the subscription is either active or in trial.
  bool get hasActiveSubscription =>
      {'active', 'trial'}.contains(_subscriptionStatus.toLowerCase());

  /// Restores the session from the underlying auth client. This is useful
  /// when the application is started and Supabase restores the session
  /// automatically.
  Future<void> restoreSession() async {
    await _syncUser(_authService.currentUser);
  }

  /// Synchronises local fields with the given [user].
  ///
  /// This method sets the logged in flag, email, user id, email verification
  /// status and role based on the provided user. If a user is present it
  /// attempts to load the role from the database, otherwise it defaults to
  /// `employee`.
  Future<void> _syncUser(User? user) async {
    _isLoggedIn = user != null;
    _userEmail = user?.email ?? '';
    _userId = user?.id ?? '';
    _isEmailVerified = user?.emailConfirmedAt != null;
    _userRole = 'employee';

    if (user != null) {
      await _loadRole(user);
    }
    // Note: loading of subscription details can be added here once
    // the billing integration is implemented.
    notifyListeners();
  }

  /// Loads the role for the supplied [user] from Supabase.
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
      // If we fail to load the role we default to employee.
      _userRole = 'employee';
    }
  }

  /// Attempts to sign in with the given [email] and [password].
  ///
  /// Returns true if the sign in was successful, otherwise false. Any error
  /// message will be stored in [errorMessage].
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await _authService.signIn(email: email, password: password);
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

  /// Sends a password reset email to the given [email].
  Future<void> sendPasswordReset(String email) async {
    _errorMessage = null;
    try {
      await _authService.sendPasswordResetEmail(email);
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to send password reset email.';
    }
    notifyListeners();
  }

  /// Resends an email verification message to the supplied [email].
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

  /// Signs the current user out and clears all local state.
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

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
