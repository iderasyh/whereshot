import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whereshot/constants/app_constants.dart';
import 'package:whereshot/models/credit_pack.dart';
import 'package:whereshot/providers/purchase_provider.dart';
import 'package:whereshot/providers/user_provider.dart';
import 'package:whereshot/router/app_router.dart';
import 'package:whereshot/theme/app_theme.dart';
import 'package:whereshot/widgets/credit_pack_card.dart';
import 'package:whereshot/widgets/credits_display.dart';
import 'package:whereshot/widgets/custom_app_bar.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  bool _isLoading = false;

  Future<void> _purchaseCreditPack(CreditPack pack) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref.read(purchaseNotifierProvider.notifier)
          .purchaseCreditPack(pack);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppConstants.purchaseSuccess),
              backgroundColor: AppColors.successGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppConstants.purchaseError),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final restored = await ref.read(purchaseNotifierProvider.notifier)
          .restorePurchases();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              restored
                  ? 'Purchases restored successfully!'
                  : 'No purchases to restore',
            ),
            backgroundColor:
                restored ? AppColors.successGreen : AppColors.textGrey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseAsync = ref.watch(purchaseNotifierProvider);
    final userAsync = ref.watch(userNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Store',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(AppRoute.home.name),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.goNamed(AppRoute.result.name),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Credits display
              const CreditsDisplay(),
              
              const SizedBox(height: AppSpacing.m),
              
              // Store heading
              Text(
                'Buy Credits',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.s),
              
              // Subheading
              Text(
                'Credits are used to analyze photos and detect locations',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textGrey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.l),
              
              // Credit packs
              Expanded(
                child: purchaseAsync.when(
                  data: (packs) {
                    if (packs.isEmpty) {
                      return const Center(
                        child: Text('No credit packs available'),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: packs.length,
                      itemBuilder: (context, index) {
                        final pack = packs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.m),
                          child: CreditPackCard(
                            pack: pack,
                            onPurchase: _isLoading 
                                ? null 
                                : () => _purchaseCreditPack(pack),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Error: ${error.toString()}',
                      style: TextStyle(color: AppColors.errorRed),
                    ),
                  ),
                ),
              ),
              
              // Restore purchases button
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _restorePurchases,
                icon: const Icon(Icons.restore),
                label: const Text('Restore Purchases'),
              ),
              
              const SizedBox(height: AppSpacing.m),
              
              // Price explanation
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pricing Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Each photo analysis costs 1 credit',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Cost per analysis: \$${AppConstants.costPerImage.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 