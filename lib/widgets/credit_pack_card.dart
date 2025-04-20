import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whereshot/models/credit_pack.dart';
import 'package:whereshot/providers/purchase_provider.dart';
import 'package:whereshot/theme/app_theme.dart';

class CreditPackCard extends ConsumerWidget {
  final CreditPack pack;
  final VoidCallback? onPurchase;
  
  const CreditPackCard({
    super.key,
    required this.pack,
    this.onPurchase,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsPercent = pack.savingsPercentage.round();
    final futurePrice = ref.watch(
      FutureProvider((ref) => ref.read(purchaseNotifierProvider.notifier)
          .getPriceString(pack)),
    );
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.m),
        side: BorderSide(
          color: pack.id == 'medium' ? AppColors.accent : Colors.transparent,
          width: pack.id == 'medium' ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Badge if best value
            if (pack.id == 'large')
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentAlt,
                  borderRadius: BorderRadius.circular(AppRadius.s),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            if (pack.id == 'large')
              const SizedBox(height: AppSpacing.s),
            
            // Popular badge
            if (pack.id == 'medium')
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadius.s),
                ),
                child: const Text(
                  'POPULAR CHOICE',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            if (pack.id == 'medium')
              const SizedBox(height: AppSpacing.s),
            
            // Pack title
            Text(
              pack.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppSpacing.xs),
            
            // Price
            Row(
              children: [
                futurePrice.when(
                  data: (priceString) {
                    return Text(
                      priceString ?? '\$${pack.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                  loading: () => Text(
                    '\$${pack.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  error: (_, __) => Text(
                    '\$${pack.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (savingsPercent > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      borderRadius: BorderRadius.circular(AppRadius.s),
                    ),
                    child: Text(
                      'SAVE $savingsPercent%',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.s),
            
            // Per credit price
            Text(
              '\$${pack.pricePerCredit.toStringAsFixed(2)} per credit',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            
            const SizedBox(height: AppSpacing.m),
            
            // Buy button
            ElevatedButton(
              onPressed: onPurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
              ),
              child: const Text('BUY NOW'),
            ),
          ],
        ),
      ),
    );
  }
} 