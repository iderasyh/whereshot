import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/app_constants.dart';
import '../models/user.dart' as app_user;
import 'service_providers.dart';

part 'ui_providers.g.dart';

/// Provider to control whether the initial welcome message should be shown.
/// This is set to true after the first anonymous sign-in and reset after display.
@Riverpod(keepAlive: true)
class ShowWelcomeMessage extends _$ShowWelcomeMessage {
  @override
  bool build() {
    return false; // Default to not showing the message
  }

  Future<void> signInAnonymously() async {
    final authService = ref.read(authServiceProvider);
    final firebaseService = ref.read(firebaseServiceProvider);
    final storageService = ref.read(storageServiceProvider);
    final fb_auth.User? firebaseUser = await authService.signInAnonymously();
    if (firebaseUser != null) {
      final existingUser = await firebaseService.getUser(firebaseUser.uid);
      if (existingUser == null) {
        storageService.setCredits(1);
        storageService.setDefaultStorageMode(AppConstants.defaultStorageMode);
        final newUser = app_user.User(
          uid: firebaseUser.uid,
          credits: 1,
          defaultSaveMode: AppConstants.defaultStorageMode,
          lastUpdated: DateTime.now(),
        );
        final success = await firebaseService.saveUser(newUser);

        if (success) {
          state = true;
        } else {
          throw Exception('Failed to save new user data.');
        }
      }
    } else {
      throw Exception('Anonymous sign-in failed silently.');
    }
  }

  void consumed() {
    state = false;
  }
}
