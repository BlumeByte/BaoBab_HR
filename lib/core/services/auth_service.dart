import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AuthService {
  AuthService({SupabaseClient? client}) : _client = client ?? SupabaseService.client;

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn({required String email, required String password}) {
    return _client.auth.signInWithPassword(email: email.trim(), password: password);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _client.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> resendEmailVerification(String email) {
    return _client.auth.resend(type: OtpType.signup, email: email.trim());
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  Future<Map<String, dynamic>?> fetchUserProfileRole(String authUserId) {
    return _client.from('users').select('role,company_id').eq('auth_user_id', authUserId).maybeSingle();
  }
}
