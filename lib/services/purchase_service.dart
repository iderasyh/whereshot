import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:whereshot/models/credit_pack.dart';

class PurchaseService {
  final String _apiKey;
  bool _isInitialized = false;
  
  PurchaseService({
    required String apiKey,
  }) : _apiKey = apiKey;
  
  // Initialize RevenueCat
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      
      // Configure with API key
      await Purchases.configure(PurchasesConfiguration(_apiKey));
      
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize RevenueCat: $e');
    }
  }
  
  // Get available product offerings
  Future<List<Package>> getOfferings() async {
    try {
      if (!_isInitialized) await initialize();
      
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      
      if (current == null) {
        return [];
      }
      
      return current.availablePackages;
    } catch (e) {
      return [];
    }
  }
  
  // Get specific package by ID
  Future<Package?> getPackageById(String productId) async {
    try {
      final packages = await getOfferings();
      
      for (final package in packages) {
        if (package.storeProduct.identifier == productId) {
          return package;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get price string for a credit pack
  Future<String?> getPriceStringForPack(CreditPack pack) async {
    try {
      final package = await getPackageById(pack.productId);
      return package?.storeProduct.priceString;
    } catch (e) {
      return null;
    }
  }
  
  // Purchase a package
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      if (!_isInitialized) await initialize();
      
      final purchaseResult = await Purchases.purchasePackage(package);
      return purchaseResult;
    } on PurchasesErrorCode catch (e) {
      throw Exception('Purchase failed: $e');
    } catch (e) {
      throw Exception('Purchase failed: $e');
    }
  }
  
  // Purchase a credit pack
  Future<CustomerInfo?> purchaseCreditPack(CreditPack pack) async {
    try {
      final package = await getPackageById(pack.productId);
      
      if (package == null) {
        throw Exception('Package not found for ${pack.productId}');
      }
      
      return await purchasePackage(package);
    } catch (e) {
      throw Exception('Failed to purchase credit pack: $e');
    }
  }
  
  // Get all available credit packs with store information
  Future<List<CreditPack>> getAvailableCreditPacks() async {
    final List<CreditPack> result = [];
    final defaultPacks = CreditPack.defaultPacks;
    
    try {
      for (final pack in defaultPacks) {
        final priceString = await getPriceStringForPack(pack);
        
        if (priceString != null) {
          // Return with store price if available
          result.add(pack);
        }
      }
    } catch (e) {
      // Return default packs if store fails
      return defaultPacks;
    }
    
    // If no packs found in store, return defaults
    return result.isEmpty ? defaultPacks : result;
  }
  
  // Restore purchases
  Future<CustomerInfo> restorePurchases() async {
    try {
      if (!_isInitialized) await initialize();
      
      return await Purchases.restorePurchases();
    } catch (e) {
      throw Exception('Failed to restore purchases: $e');
    }
  }
} 