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
      final uid = authService.currentUser?.uid;
      if (uid == null) {
        return null;
      }

      app_user.User? user = await firebaseService.getUser(uid);
      
      if (user == null) {
        user = app_user.User(
          uid: uid,
          credits: storageService.getCredits(),
          defaultSaveMode: storageService.getDefaultStorageMode(),
          lastUpdated: DateTime.now(),
        );
        
        await firebaseService.saveUser(user);
        await storageService.setCredits(user.credits);
        await storageService.setDefaultStorageMode(user.defaultSaveMode);
      } else {
        await storageService.setCredits(user.credits);
        await storageService.setDefaultStorageMode(user.defaultSaveMode);
      }
      
      _listenForPurchaseUpdates();
      return user;
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }
  
  void _listenForPurchaseUpdates() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _processPurchaseCompletion(customerInfo);
    });
  }
  
  Future<void> _processPurchaseCompletion(CustomerInfo customerInfo) async {
    final offeringsAsyncValue = ref.read(purchaseProvider);
    offeringsAsyncValue.whenData((offerings) async {
      if (offerings.current == null) return;
      int creditsToAdd = 0;
      for (final transaction in customerInfo.nonSubscriptionTransactions) {
        final package = offerings.current!.availablePackages.firstWhereOrNull(
          (pkg) => pkg.storeProduct.identifier == transaction.productIdentifier,
        );
        if (package != null) {
          bool alreadyProcessed = await _checkIfTransactionProcessed(transaction.transactionIdentifier);
          if (!alreadyProcessed) {
            int creditsFromPack = CreditPack.fromRevenueCat(package).credits;
            creditsToAdd += creditsFromPack;
            await _markTransactionAsProcessed(transaction.transactionIdentifier);
          }
        }
      }
      if (creditsToAdd > 0) {
        await addCredits(creditsToAdd);
      }
    });
  }

  Future<bool> _checkIfTransactionProcessed(String transactionId) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final key = 'processed_tx_$transactionId';
    final processed = prefs.getBool(key) ?? false;
    return processed;
  }

  Future<void> _markTransactionAsProcessed(String transactionId) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final key = 'processed_tx_$transactionId';
    await prefs.setBool(key, true);
  }

  Future<void> addCredits(int amount) async {
    final currentState = state;
    if (currentState is! AsyncData<app_user.User?> || currentState.value == null) {
      return;
    }
    final currentUser = currentState.value!;

    state = const AsyncValue.loading();
    
    try {
      final storageService = ref.read(storageServiceProvider);
      final firebaseService = ref.read(firebaseServiceProvider);
      
      final updatedUser = currentUser.addCredits(amount);
      
      await firebaseService.saveUser(updatedUser);
      await storageService.setCredits(updatedUser.credits);
      
      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<bool> useCredits(int amount) async {
    final currentState = state;
    if (currentState is! AsyncData<app_user.User?> || currentState.value == null) {
      return false;
    }
    final currentUser = currentState.value!;
    
    if (currentUser.credits < amount) {
      return false;
    }
    
    try {
      final updatedUser = currentUser.useCredits(amount);
      if (updatedUser == null) return false;
      
      final storageService = ref.read(storageServiceProvider);
      final firebaseService = ref.read(firebaseServiceProvider);
      
      await firebaseService.saveUser(updatedUser);
      await storageService.setCredits(updatedUser.credits);
      
      state = AsyncValue.data(updatedUser);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> toggleDefaultSaveMode() async {
    final currentState = state;
    if (currentState is! AsyncData<app_user.User?> || currentState.value == null) {
      return;
    }
    final currentUser = currentState.value!;

    state = const AsyncValue.loading();
    
    try {
      final storageService = ref.read(storageServiceProvider);
      final firebaseService = ref.read(firebaseServiceProvider);
      
      final updatedUser = currentUser.toggleDefaultSaveMode();
      
      await firebaseService.saveUser(updatedUser);
      await storageService.setDefaultStorageMode(updatedUser.defaultSaveMode);
      
      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> restorePurchases() async {
    state = const AsyncValue.loading();

    try {
      final customerInfo =
          await ref.read(purchaseProvider.notifier).restorePurchases();
      await _processPurchaseCompletion(customerInfo);

      final finalState = state;
      if (finalState is AsyncData<app_user.User?>) {
        state = AsyncValue.data(finalState.value);
      } else if (finalState is AsyncError) {
      } else {
        ref.invalidateSelf();
      }

    } catch (e, stack) {
      state = AsyncError(e, stack);
      throw Exception(AppConstants.restorePurchasesError);
    }
  }
} 