import 'package:whereshot/constants/app_constants.dart';

class CreditPack {
  final String id;
  final String title;
  final String productId;
  final int credits;
  final double price;
  final String? description;

  const CreditPack({
    required this.id,
    required this.title,
    required this.productId,
    required this.credits,
    required this.price,
    this.description,
  });

  // Price per credit
  double get pricePerCredit => price / credits;

  // Savings percentage compared to base rate
  double get savingsPercentage {
    final baseRate = AppConstants.costPerImage;
    final actualRate = pricePerCredit;
    return ((baseRate - actualRate) / baseRate) * 100;
  }

  // Default credit packs
  static const List<CreditPack> defaultPacks = [
    CreditPack(
      id: 'small',
      title: '5 Credits',
      productId: AppConstants.fiveCreditsId,
      credits: AppConstants.fiveCreditsValue,
      price: AppConstants.fiveCreditsPrice,
      description: 'Basic Pack',
    ),
    CreditPack(
      id: 'medium',
      title: '15 Credits',
      productId: AppConstants.fifteenCreditsId,
      credits: AppConstants.fifteenCreditsValue,
      price: AppConstants.fifteenCreditsPrice,
      description: 'Popular Choice',
    ),
    CreditPack(
      id: 'large',
      title: '50 Credits',
      productId: AppConstants.fiftyCreditsId,
      credits: AppConstants.fiftyCreditsValue,
      price: AppConstants.fiftyCreditsPrice,
      description: 'Best Value',
    ),
  ];
} 