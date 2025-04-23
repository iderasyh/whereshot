import 'package:purchases_flutter/purchases_flutter.dart' show Package;
import 'package:whereshot/constants/app_constants.dart';

class CreditPack {
  final String id;
  final String title;
  final int credits;
  final double? price; // Made price optional as it comes from RC
  final String? description;
  final String productId; // Already exists, will be matched with RC
  final String priceString; // Added for displaying RC price
  final Package? revenueCatPackage; // Added to hold the original package

  const CreditPack({
    required this.id,
    required this.title,
    required this.credits,
    this.price, // Optional now
    this.description,
    required this.productId,
    required this.priceString,
    this.revenueCatPackage,
  });

  // Factory constructor to create CreditPack from RevenueCat Package
  factory CreditPack.fromRevenueCat(Package rcPackage) {
    // Determine credits based on product ID - **Needs mapping**
    int packCredits = _getCreditsForProductId(rcPackage.storeProduct.identifier);
    String packTitle = _getTitleForProductId(rcPackage.storeProduct.identifier);
    String packId = _getIdForProductId(rcPackage.storeProduct.identifier);
    String? packDescription = _getDescriptionForProductId(rcPackage.storeProduct.identifier);

    return CreditPack(
      id: packId, // Use mapped ID
      title: packTitle, // Use mapped title
      credits: packCredits, // Use mapped credits
      price: rcPackage.storeProduct.price, // Get price from RC
      description: packDescription, // Use mapped description
      productId: rcPackage.storeProduct.identifier, // Get product ID from RC
      priceString: rcPackage.storeProduct.priceString, // Get formatted price string
      revenueCatPackage: rcPackage, // Store the original package
    );
  }

  // Helper function to map RevenueCat product ID to app's credit count
  // IMPORTANT: Update this mapping based on your actual Product IDs in RevenueCat
  static int _getCreditsForProductId(String productId) {
    switch (productId) {
      case AppConstants.fiveCreditsId:
        return AppConstants.fiveCreditsValue;
      case AppConstants.fifteenCreditsId:
        return AppConstants.fifteenCreditsValue;
      case AppConstants.fiftyCreditsId:
        return AppConstants.fiftyCreditsValue;
      default:
        return 0; // Or handle error appropriately
    }
  }

  // Helper function to map RevenueCat product ID to app's title
  static String _getTitleForProductId(String productId) {
    switch (productId) {
      case AppConstants.fiveCreditsId:
        return '5 Credits';
      case AppConstants.fifteenCreditsId:
        return '15 Credits';
      case AppConstants.fiftyCreditsId:
        return '50 Credits';
      default:
        return 'Unknown Pack';
    }
  }

  // Helper function to map RevenueCat product ID to app's internal ID
  static String _getIdForProductId(String productId) {
    switch (productId) {
      case AppConstants.fiveCreditsId:
        return 'small';
      case AppConstants.fifteenCreditsId:
        return 'medium';
      case AppConstants.fiftyCreditsId:
        return 'large';
      default:
        return productId; // Fallback to product ID itself
    }
  }

    // Helper function to map RevenueCat product ID to app's description
  static String? _getDescriptionForProductId(String productId) {
    switch (productId) {
      case AppConstants.fiveCreditsId:
        return 'Basic Pack';
      case AppConstants.fifteenCreditsId:
        return 'Popular Choice';
      case AppConstants.fiftyCreditsId:
        return 'Best Value';
      default:
        return null;
    }
  }

  // Price per credit (uses RC price if available)
  double? get pricePerCredit {
    if (price != null && credits > 0) {
      return price! / credits;
    }
    return null;
  }

  // Savings percentage compared to base rate (uses RC price)
  double? get savingsPercentage {
    final baseRate = AppConstants.costPerImage;
    final actualRate = pricePerCredit;
    if (actualRate != null && baseRate > 0) {
      return ((baseRate - actualRate) / baseRate) * 100;
    }
    return null;
  }

} 