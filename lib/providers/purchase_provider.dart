import 'package:flutter/services.dart'; // Required for PlatformException
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../constants/app_constants.dart';

part 'purchase_provider.g.dart';

// Provider to handle RevenueCat offerings and purchases
@riverpod
class Purchase extends _$Purchase {
  @override
  Future<Offerings> build() async {
    // Initial fetch of offerings when the provider is first read.
    return _fetchOfferings();
  }

  // Internal method to fetch offerings from RevenueCat
  Future<Offerings> _fetchOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } on PlatformException catch (_) {
      // Handle specific RevenueCat errors
      throw Exception(AppConstants.failedLoadingPackages);
    } catch (e) {
      throw Exception(AppConstants.failedLoadingPackages);
    }
  }

  // Method to manually refresh offerings data
  Future<void> refreshOfferings() async {
    state = const AsyncValue.loading(); // Set state to loading
    // Guard against errors during fetch and update state
    state = await AsyncValue.guard(() => _fetchOfferings());
  }

  // Method to purchase a specific RevenueCat package
  Future<CustomerInfo> purchasePackage(Package packageToPurchase) async {
    try {
      // Perform the purchase
      CustomerInfo customerInfo = await Purchases.purchasePackage(
        packageToPurchase,
      );
      // The listener in main.dart might handle further logic, or you can add it here.
      return customerInfo;
    } on PlatformException catch (e) {
      // Handle specific purchase errors
      var message = AppConstants.purchaseError;
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        message = AppConstants.purchaseCancelled;
      } else {
        message = AppConstants.purchaseFailed;
      }
      throw Exception(message);
    } catch (e) {
      // Handle unexpected errors during purchase
      throw Exception(AppConstants.purchaseError);
    }
  }

  // Method to restore previous purchases
  Future<CustomerInfo> restorePurchases() async {
    try {
      // Perform restore purchases
      CustomerInfo restoredInfo = await Purchases.restorePurchases();
      // Check restored customerInfo to see if entitlements are now active.
      // The listener in main.dart might handle credit updates, or you can add logic here.
      return restoredInfo;
    } on PlatformException catch (_) {
      // Handle errors during restore
      throw Exception(AppConstants.restorePurchasesError);
    } catch (e) {
      // Handle unexpected errors during restore
      throw Exception(AppConstants.restorePurchasesError);
    }
  }
}
