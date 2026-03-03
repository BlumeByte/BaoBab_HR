import 'package:baobab_hr/models/user_model.dart';
import 'package:baobab_hr/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    firebaseAuth: FirebaseAuth.instance,
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirestoreService _firestoreService;

  AuthService({
    required FirebaseAuth firebaseAuth,
    required FirestoreService firestoreService,
  })  : _firebaseAuth = firebaseAuth,
        _firestoreService = firestoreService;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update last login
        await _firestoreService.updateUserLastLogin(userCredential.user!.uid);

        // Fetch user data
        return await _firestoreService.getUser(userCredential.user!.uid);
      }
      return null;
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String?> getUserRole() async {
    if (currentUser == null) return null;

    final user = await _firestoreService.getUser(currentUser!.uid);
    return user?.role.toString().split('.').last;
  }
}
