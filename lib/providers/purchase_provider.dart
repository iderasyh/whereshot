import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:whereshot/models/credit_pack.dart';
import 'package:whereshot/providers/service_providers.dart';
import 'package:whereshot/providers/user_provider.dart';

part 'purchase_provider.g.dart';

@riverpod
class PurchaseNotifier extends _$PurchaseNotifier {
  @override
  Future<List<CreditPack>> build() async {
    final purchaseService = ref.watch(purchaseServiceProvider);
    
    try {
      // Initialize the purchase service
      await purchaseService.initialize();
      
      // Get available credit packs
      return await purchaseService.getAvailableCreditPacks();
    } catch (e) {
      // Return default packs if service fails
      return CreditPack.defaultPacks;
    }
  }
  
  // Purchase a credit pack
  Future<bool> purchaseCreditPack(CreditPack pack) async {
    state = const AsyncValue.loading();
    
    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final userNotifier = ref.read(userNotifierProvider.notifier);
      
      // Purchase the pack
      final purchaseResult = await purchaseService.purchaseCreditPack(pack);
      
      if (purchaseResult != null) {
        // Add credits to user account
        await userNotifier.addCredits(pack.credits);
        
        // Refresh available packs
        state = await AsyncValue.guard(() async {
          return await purchaseService.getAvailableCreditPacks();
        });
        
        return true;
      }
      
      // Purchase failed or was cancelled
      state = AsyncValue.data(await purchaseService.getAvailableCreditPacks());
      return false;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
  
  // Restore purchases
  Future<bool> restorePurchases() async {
    state = const AsyncValue.loading();
    
    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final userNotifier = ref.read(userNotifierProvider.notifier);
      
      // Restore purchases
      final customerInfo = await purchaseService.restorePurchases();
      
      // Check for credited entitlements
      bool purchasesRestored = false;
      
      // Process entitlements
      // This depends on how you've set up your RevenueCat products
      // This is a simplistic example
      for (final pack in CreditPack.defaultPacks) {
        if (customerInfo.entitlements.all[pack.productId]?.isActive ?? false) {
          await userNotifier.addCredits(pack.credits);
          purchasesRestored = true;
        }
      }
      
      // Refresh available packs
      state = AsyncValue.data(await purchaseService.getAvailableCreditPacks());
      
      return purchasesRestored;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
  
  // Get price string for a pack
  Future<String?> getPriceString(CreditPack pack) async {
    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      return await purchaseService.getPriceStringForPack(pack);
    } catch (e) {
      return null;
    }
  }
} 