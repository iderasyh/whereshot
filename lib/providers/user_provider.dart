import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/app_constants.dart';
import '../models/credit_pack.dart';
import '../models/user.dart' as app_user;
import '../providers/purchase_provider.dart';
import '../providers/service_providers.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<app_user.User?> build() async {
    final authService = ref.watch(authServiceProvider);
    final storageService = ref.watch(storageServiceProvider);
    final firebaseService = ref.watch(firebaseServiceProvider);
    
    try {
      // Get device ID
      final uid = authService.currentUser?.uid;

      if (uid == null) {
        return null;
      }
      
      // Try to get user from Firestore first
      app_user.User? user = await firebaseService.getUser(uid);
      
      // If not found in Firestore, create a new user
      if (user == null) {
        user = app_user.User(
          uid: uid,
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
      
      // Listen for purchase updates after initial load
      _listenForPurchaseUpdates();
      
      return user;
    } catch (e) {
      // Fallback to local data if Firebase fails
      final uid = authService.currentUser?.uid;
      if (uid == null) {
        return null;
      }
      // Listen for purchase updates even on fallback
      _listenForPurchaseUpdates();
      return app_user.User(
        uid: uid,
        credits: storageService.getCredits(),
        defaultSaveMode: storageService.getDefaultStorageMode(),
        lastUpdated: DateTime.now(),
      );
    }
  }
  
  // Set up listener for RevenueCat purchase updates
  void _listenForPurchaseUpdates() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _processPurchaseCompletion(customerInfo);
    });
  }
  
  // Process completed purchases from RevenueCat CustomerInfo
  Future<void> _processPurchaseCompletion(CustomerInfo customerInfo) async {
    // This is a basic example. You might need more robust logic
    // to handle different product types, check transaction history,
    // or verify receipts server-side.

    // Get the current offerings to map product IDs to credit packs
    final offeringsAsyncValue = ref.read(purchaseProvider);
    // Use .whenData to safely access offerings only if available
    offeringsAsyncValue.whenData((offerings) async {
      if (offerings.current == null) return; // No offerings available

      int creditsToAdd = 0;

      // Alternative: Iterate through non-subscription purchases
      // This is more common for consumable credits.
      for (final transaction in customerInfo.nonSubscriptionTransactions) {
        // Check if this transaction's product corresponds to a known credit pack
        final package = offerings.current!.availablePackages.firstWhereOrNull(
          (pkg) => pkg.storeProduct.identifier == transaction.productIdentifier,
        );

        if (package != null) {
          // IMPORTANT: Verify this transaction hasn't been processed before!
          bool alreadyProcessed = await _checkIfTransactionProcessed(transaction.transactionIdentifier);
          if (!alreadyProcessed) {
            int creditsFromPack = CreditPack.fromRevenueCat(package).credits;
            creditsToAdd += creditsFromPack;
            // Mark transaction as processed
            await _markTransactionAsProcessed(transaction.transactionIdentifier);
          }
        }
      }

      if (creditsToAdd > 0) {
        // Call addCredits only if credits need to be added
        await addCredits(creditsToAdd);
      }
    });
  }

  // --- Transaction processing implementation using SharedPreferences --- 

  // Checks SharedPreferences to see if a transaction ID has been processed.
  Future<bool> _checkIfTransactionProcessed(String transactionId) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final key = 'processed_tx_$transactionId';
    final processed = prefs.getBool(key) ?? false;
    return processed;
  }

  // Marks a transaction ID as processed in SharedPreferences.
  Future<void> _markTransactionAsProcessed(String transactionId) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final key = 'processed_tx_$transactionId';
    await prefs.setBool(key, true);
  }

  // --- End Transaction processing implementation --- 

  // Add credits to user
  Future<void> addCredits(int amount) async {
    // Prevent adding credits if already loading/updating
    if (state is AsyncLoading) return;

    state = const AsyncValue.loading();
    
    try {
      // Use ref.read(future) for potentially stale data or implement logic to get latest
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

  // Restore purchases - delegates to PurchaseProvider and processes result
  Future<void> restorePurchases() async {
    // Set loading state
    state = const AsyncValue.loading();

    try {
      final customerInfo =
          await ref.read(purchaseProvider.notifier).restorePurchases();
      // Process restored info to potentially add credits (if applicable)
      await _processPurchaseCompletion(customerInfo);

      // Refresh user state (even if no credits were added, ensures UI reflects latest)
      // Safely access the potentially updated user data after processing
       final updatedUser = await future; // Re-fetch the state after potential updates
       state = AsyncValue.data(updatedUser);

    } catch (e, stack) {
      // Set error state
      state = AsyncError(e, stack);
      // Optionally rethrow or handle specific error display
      throw Exception(AppConstants.restorePurchasesError);
    }
  }
} 