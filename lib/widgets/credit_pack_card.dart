import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whereshot/models/credit_pack.dart';
import 'package:whereshot/providers/purchase_provider.dart';
import 'package:whereshot/theme/app_theme.dart';

class CreditPackCard extends ConsumerStatefulWidget {
  final CreditPack pack;
  final VoidCallback? onPurchase;

  const CreditPackCard({super.key, required this.pack, this.onPurchase});

  @override
  ConsumerState<CreditPackCard> createState() => _CreditPackCardState();
}

class _CreditPackCardState extends ConsumerState<CreditPackCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Play animation when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savingsPercent = widget.pack.savingsPercentage.round();
    final futurePrice = ref.watch(
      FutureProvider(
        (ref) => ref
            .read(purchaseNotifierProvider.notifier)
            .getPriceString(widget.pack),
      ),
    );

    final bool isPopular = widget.pack.description == 'Popular Choice';
    final bool isBestValue = widget.pack.description == 'Best Value';
    final bool isHighlighted = isPopular || isBestValue;

    final accentColor =
        isBestValue
            ? AppColors.accentAlt
            : isPopular
            ? AppColors.accent
            : AppColors.darkGrey;

    // Generate colors based on pack tier
    final List<Color> cardGradientColors = _getGradientColors(
      widget.pack.credits,
      isHighlighted,
    );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Card
            Card(
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.l),
              ),
              clipBehavior: Clip.hardEdge,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: cardGradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Upper part with credits icon and amount
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.m,
                        AppSpacing.l,
                        AppSpacing.m,
                        AppSpacing.s,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Credit amount with icon
                          Row(
                            children: [
                              // Credits icon
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.flash_on_rounded,
                                  color: accentColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.m),
                              // Credit info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.pack.title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs / 2),
                                    Text(
                                      '${widget.pack.credits} credits',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.m),

                          // Price with per-credit calculation
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.s),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.m),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Price
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Price',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs / 2),
                                    futurePrice.when(
                                      data:
                                          (priceString) => Text(
                                            priceString ??
                                                '\$${widget.pack.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                      loading:
                                          () => Container(
                                            height: 18,
                                            width: 60,
                                            color: Colors.white.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                      error:
                                          (_, __) => Text(
                                            '\$${widget.pack.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                                // Per credit
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Per Credit',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs / 2),
                                    Text(
                                      '\$${widget.pack.pricePerCredit.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom part with purchase button on white background
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Savings badge if applicable
                          if (savingsPercent > 0)
                            Container(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.s,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                                horizontal: AppSpacing.s,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successGreen.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.s,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.successGreen,
                                    size: 16,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'Save $savingsPercent% compared to standard price',
                                    style: const TextStyle(
                                      color: AppColors.successGreen,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Buy button
                          ElevatedButton(
                            onPressed: widget.onPurchase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.m,
                                horizontal: AppSpacing.m,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.m,
                                ),
                              ),
                            ),
                            child: const Text(
                              'PURCHASE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Corner ribbon for highlighted packs
            if (isHighlighted)
              Positioned(
                top: -4,
                right: -4,
                child: _buildRibbon(
                  isBestValue ? 'BEST VALUE' : 'POPULAR',
                  accentColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Generate gradient colors based on the credit amount and highlight status
  List<Color> _getGradientColors(int credits, bool isHighlighted) {
    if (isHighlighted) {
      if (widget.pack.description == 'Best Value') {
        // Gold/premium gradient for best value
        return [
          const Color(0xFFFF7A5C), // Main accent alt
          const Color(0xFFFF5C3E), // Darker accent alt
        ];
      } else {
        // Blue gradient for popular
        return [
          const Color(0xFF007AFF), // Main accent
          const Color(0xFF0055CC), // Darker accent
        ];
      }
    } else {
      // Determine gradient based on credit tier
      if (credits <= 5) {
        return [const Color(0xFF6A6A6A), const Color(0xFF4A4A4A)];
      } else if (credits <= 15) {
        return [const Color(0xFF607D8B), const Color(0xFF455A64)];
      } else {
        return [const Color(0xFF455A64), const Color(0xFF263238)];
      }
    }
  }

  Widget _buildRibbon(String text, Color color) {
    return Banner(
      message: text,
      location: BannerLocation.topEnd,
      color: color,
      child: const SizedBox(width: 48, height: 48),
    );
  }
}
