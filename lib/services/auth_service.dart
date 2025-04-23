import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream to listen for authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get the current user (can be null if not signed in)
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign in anonymously
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Rethrow or handle specific errors as needed
      throw Exception('Failed to sign in anonymously: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred during sign-in.');
    }
  }

  // Sign out (optional, but good practice)
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      throw Exception(AppConstants.anErrorOccurred);
    }
  }
}
