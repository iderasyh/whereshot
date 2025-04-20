import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:whereshot/models/user.dart' as app_user;
import 'package:whereshot/providers/service_providers.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<app_user.User?> build() async {
    final storageService = ref.watch(storageServiceProvider);
    final firebaseService = ref.watch(firebaseServiceProvider);
    
    try {
      // Get device ID
      final deviceId = await storageService.getDeviceId();
      
      // Try to get user from Firestore first
      app_user.User? user = await firebaseService.getUser(deviceId);
      
      // If not found in Firestore, create a new user
      if (user == null) {
        user = app_user.User(
          deviceId: deviceId,
          credits: storageService.getCredits(),
          defaultSaveMode: storageService.getDefaultStorageMode(),
          lastUpdated: DateTime.now(),
        );
        
        // Save user to Firestore
        await firebaseService.saveUser(user);
      } else {
        // Update local storage to match Firestore
        await storageService.setCredits(user.credits);
        await storageService.setDefaultStorageMode(user.defaultSaveMode);
      }
      
      return user;
    } catch (e) {
      // Fallback to local data if Firebase fails
      final deviceId = await storageService.getDeviceId();
      return app_user.User(
        deviceId: deviceId,
        credits: storageService.getCredits(),
        defaultSaveMode: storageService.getDefaultStorageMode(),
        lastUpdated: DateTime.now(),
      );
    }
  }
  
  // Add credits to user
  Future<void> addCredits(int amount) async {
    state = const AsyncValue.loading();
    
    try {
      final currentUser = await future;
      if (currentUser == null) {
        state = AsyncValue.error('User not found', StackTrace.current);
        return;
      }
      
      final storageService = ref.read(storageServiceProvider);
      final firebaseService = ref.read(firebaseServiceProvider);
      
      // Add credits to user
      final updatedUser = currentUser.addCredits(amount);
      
      // Update Firestore
      await firebaseService.saveUser(updatedUser);
      
      // Update local storage
      await storageService.setCredits(updatedUser.credits);
      
      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  // Use credits (if available)
  Future<bool> useCredits(int amount) async {
    try {
      final currentUser = await future;
      if (currentUser == null) {
        return false;
      }
      
      // Check if user has enough credits
      if (currentUser.credits < amount) {
        return false;
      }
      
      final updatedUser = currentUser.useCredits(amount);
      if (updatedUser == null) {
        return false;
      }
      
      final storageService = ref.read(storageServiceProvider);
      final firebaseService = ref.read(firebaseServiceProvider);
      
      // Update Firestore
      await firebaseService.saveUser(updatedUser);
      
      // Update local storage
      await storageService.setCredits(updatedUser.credits);
      
      state = AsyncValue.data(updatedUser);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Toggle default save mode
  Future<void> toggleDefaultSaveMode() async {
    state = const AsyncValue.loading();
    
    try {
      final currentUser = await future;
      if (currentUser == null) {
        state = AsyncValue.error('User not found', StackTrace.current);
        return;
      }
      
      final storageService = ref.read(storageServiceProvider);
      final firebaseService = ref.read(firebaseServiceProvider);
      
      // Toggle save mode
      final updatedUser = currentUser.toggleDefaultSaveMode();
      
      // Update Firestore
      await firebaseService.saveUser(updatedUser);
      
      // Update local storage
      await storageService.setDefaultStorageMode(updatedUser.defaultSaveMode);
      
      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
} 