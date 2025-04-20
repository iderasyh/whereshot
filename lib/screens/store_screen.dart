import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../models/credit_pack.dart';
import '../providers/purchase_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/credit_pack_card.dart';
import '../widgets/credits_display.dart';
import '../widgets/custom_app_bar.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _purchaseCreditPack(CreditPack pack) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref
          .read(purchaseNotifierProvider.notifier)
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
      final restored =
          await ref.read(purchaseNotifierProvider.notifier).restorePurchases();

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

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Store',
        leading: AppTheme.adaptiveWidget(
          context: context,
          material: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.goNamed(AppRoute.home.name),
          ),
          cupertino: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.goNamed(AppRoute.home.name),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.goNamed(AppRoute.history.name),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: CustomPaint(
            painter: PatternPainter(Theme.of(context).scaffoldBackgroundColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with credits display
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _animationController,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.l),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const CreditsDisplay(),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            'Get more credits to analyze photos',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.l),

                // Credit packs list
                Expanded(
                  child: AsyncValueWidget(
                    value: purchaseAsync,
                    loading: const Center(child: CircularProgressIndicator()),
                    error:
                        (error, stackTrace) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.errorRed,
                                size: 48,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              Text(
                                'Failed to load credit packs',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: AppColors.errorRed),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              ElevatedButton(
                                onPressed:
                                    () => ref.refresh(purchaseNotifierProvider),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
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
                          return AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              final delay = index * 0.2;
                              final slideAnimation = Tween<Offset>(
                                begin: const Offset(0.3, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    delay.clamp(0.0, 0.8),
                                    (delay + 0.2).clamp(0.0, 1.0),
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              );

                              final fadeAnimation = Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    delay.clamp(0.0, 0.8),
                                    (delay + 0.2).clamp(0.0, 1.0),
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              );

                              return FadeTransition(
                                opacity: fadeAnimation,
                                child: SlideTransition(
                                  position: slideAnimation,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.m,
                                    ),
                                    child: CreditPackCard(
                                      pack: pack,
                                      onPurchase:
                                          _isLoading
                                              ? null
                                              : () => _purchaseCreditPack(pack),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // Restore purchases button with animation
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.6, 1.0),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(top: AppSpacing.m),
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _restorePurchases,
                        icon: const Icon(Icons.restore),
                        label: const Text('Restore Purchases'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.m,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PatternPainter extends CustomPainter {
  final Color backgroundColor;
  final math.Random _random = math.Random();

  PatternPainter(this.backgroundColor);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);

    final paint = Paint()
        ..color = AppColors.darkGrey.withValues(alpha: 0.03)
        ..style = PaintingStyle.fill;

    const spacing = 25.0;
    const dotSize = 1.5;

    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final offsetX = (x + (_random.nextDouble() - 0.5) * 5) % (size.width + spacing);
        final offsetY = (y + (_random.nextDouble() - 0.5) * 5) % (size.height + spacing);
        canvas.drawCircle(Offset(offsetX, offsetY), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PatternPainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor;
}
