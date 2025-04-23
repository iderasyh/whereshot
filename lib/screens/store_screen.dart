import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_constants.dart';
import '../models/credit_pack.dart';
import '../providers/purchase_provider.dart';
import '../providers/user_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/credit_pack_card.dart';
import '../widgets/custom_app_bar.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen>
    with TickerProviderStateMixin {
  bool _isPurchasing = false;
  bool _isRestoring = false;
  late AnimationController _staggeredController;

  @override
  void initState() {
    super.initState();
    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  Future<void> _purchaseRevenueCatPackage(Package rcPackage) async {
    if (_isPurchasing) return;
    setState(() => _isPurchasing = true);

    try {
      await ref
          .read(purchaseProvider.notifier)
          .purchasePackage(rcPackage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.purchaseSuccess),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    if (_isRestoring) return;
    setState(() => _isRestoring = true);

    try {
      await ref.read(userNotifierProvider.notifier).restorePurchases();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Restore attempt finished. Check your credits.',
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(purchaseProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: CustomAppBar(
        title: 'Get Credits',
        backgroundColor: AppColors.lightGrey,
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
          TextButton.icon(
            icon: _isRestoring
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.restore, size: 20),
            label: const Text('Restore'),
            onPressed: _isRestoring || _isPurchasing ? null : _restorePurchases,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: AsyncValueWidget<Offerings>(
          value: offeringsAsync,
          loading: _buildLoadingState(),
          error: (error, stackTrace) => _buildErrorState(context, error),
          data: (offerings) => _buildStoreContent(context, offerings),
        ),
      ),
    );
  }

  Widget _buildStoreContent(BuildContext context, Offerings offerings) {
    final currentOffering = offerings.current;
    if (currentOffering == null || currentOffering.availablePackages.isEmpty) {
      return _buildEmptyState(context);
    }

    final packs = currentOffering.availablePackages
        .map((rcPackage) => CreditPack.fromRevenueCat(rcPackage))
        .toList();

    packs.sort((a, b) => a.credits.compareTo(b.credits));

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: AppSpacing.m,
        right: AppSpacing.m,
        top: AppSpacing.l,
        bottom: AppSpacing.l,
      ),
      itemCount: packs.length,
      itemBuilder: (context, index) {
        final pack = packs[index];
        final rcPackage = pack.revenueCatPackage;
        
        final intervalStart = (index * 0.15).clamp(0.0, 0.8);
        final intervalEnd = (intervalStart + 0.4).clamp(0.0, 1.0);
        
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _staggeredController,
          curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOutCubic),
        ));
        
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _staggeredController,
          curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOutCubic),
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.l),
              child: CreditPackCard(
                pack: pack,
                onPurchase: _isPurchasing || _isRestoring || rcPackage == null
                    ? null
                    : () => _purchaseRevenueCatPackage(rcPackage),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView( 
      padding: const EdgeInsets.only(
        left: AppSpacing.m,
        right: AppSpacing.m,
        top: AppSpacing.l,
        bottom: AppSpacing.l,
      ),
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.l),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.l),
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_outlined,
              color: AppColors.textGrey.withValues(alpha: 0.6),
              size: 64,
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'No credit packs available',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Please check back later or try refreshing.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Store'),
              onPressed: () =>
                  ref.read(purchaseProvider.notifier).refreshOfferings(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.errorRed,
              size: 64,
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Failed to load store items',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              error.toString().replaceFirst('Exception: ', ''),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () =>
                  ref.read(purchaseProvider.notifier).refreshOfferings(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
              ),
            )
          ],
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
