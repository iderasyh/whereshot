import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_constants.dart';
import '../models/credit_pack.dart';
import '../providers/purchase_provider.dart';
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
  bool _isProcessing = false;
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

  Future<void> _purchaseCreditPack(CreditPack pack) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final success = await ref
          .read(purchaseNotifierProvider.notifier)
          .purchaseCreditPack(pack);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? AppConstants.purchaseSuccess : AppConstants.purchaseError),
            backgroundColor: success ? AppColors.successGreen : AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase Error: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final restored = await ref
          .read(purchaseNotifierProvider.notifier)
          .restorePurchases();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              restored ? 'Purchases restored successfully!' : 'No purchases found to restore.',
            ),
            backgroundColor: restored ? AppColors.successGreen : AppColors.textGrey,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore Error: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseAsync = ref.watch(purchaseNotifierProvider);

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
            icon: const Icon(Icons.restore, size: 20),
            label: const Text('Restore'),
            onPressed: _isProcessing ? null : _restorePurchases,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: AsyncValueWidget(
          value: purchaseAsync,
          loading: _buildLoadingState(),
          error: (error, stackTrace) => _buildErrorState(context, error),
          data: (packs) => _buildStoreContent(context, packs),
        ),
      ),
    );
  }

  Widget _buildStoreContent(BuildContext context, List<CreditPack> packs) {
    if (packs.isEmpty) {
      return _buildEmptyState(context);
    }

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
                onPurchase: _isProcessing ? null : () => _purchaseCreditPack(pack),
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
              'Store Not Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Credit packs couldn\'t be loaded at this time. Please check back later.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textGrey,
                  ),
              textAlign: TextAlign.center,
            ),
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
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.errorRed.withValues(alpha: 0.7),
              size: 64,
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Error Loading Store',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Something went wrong while loading credit packs. Please try again.\nError: ${error.toString()}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textGrey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(purchaseNotifierProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Loading'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentAlt,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.m,
                ),
              ),
            ),
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
