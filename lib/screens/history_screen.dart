import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/detection_result.dart';
import '../providers/history_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/history_list_item.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggeredController;

  @override
  void initState() {
    super.initState();
    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 600,
      ), // Total duration for staggered items
    )..forward();

    // Refresh history when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(historyNotifierProvider);
    });
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  Future<bool?> _confirmClearAll() async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog.adaptive(
            title: const Text('Clear All History?'),
            content: const Text(
              'This will permanently delete all your detection history. This action cannot be undone.',
            ),
            actions: [
              adaptiveAction(
                context,
                'Cancel',
                () => Navigator.of(context).pop(false),
              ),
              adaptiveAction(
                context,
                'Clear All',
                () => Navigator.of(context).pop(true),
                isDestructive: true,
              ),
            ],
          ),
    );
  }

  Future<bool?> _confirmDeleteItem() async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog.adaptive(
            title: const Text('Delete Item?'),
            content: const Text(
              'Are you sure you want to delete this item from your history?',
            ),
            actions: [
              adaptiveAction(
                context,
                'Cancel',
                () => Navigator.of(context).pop(false),
              ),
              adaptiveAction(
                context,
                'Delete',
                () => Navigator.of(context).pop(true),
                isDestructive: true,
              ),
            ],
          ),
    );
  }

  Widget adaptiveAction(
    BuildContext context,
    String text,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    final style = TextStyle(
      color: isDestructive ? AppColors.errorRed : AppColors.accent,
    );
    return AppTheme.adaptiveWidget(
      context: context,
      material: TextButton(
        onPressed: onPressed,
        child: Text(text, style: style),
      ),
      cupertino: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 8.0,
            ),
            child: Text(text, style: style),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'History',
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
          // Clear all button (only if history exists)
          historyAsync.maybeWhen(
            data:
                (history) =>
                    history.isNotEmpty
                        ? IconButton(
                          tooltip: 'Clear All History',
                          icon: const Icon(Icons.delete_sweep_outlined),
                          onPressed: () async {
                            final shouldClear = await _confirmClearAll();
                            if (shouldClear == true && mounted) {
                              await ref
                                  .read(historyNotifierProvider.notifier)
                                  .clearHistory();
                              _staggeredController
                                  .reset(); // Reset animation for empty state
                              _staggeredController.forward();
                            }
                          },
                        )
                        : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false, // Let the list padding handle bottom safe area
        child: CustomPaint(
          painter: SubtleGridPainter(), // New subtle background
          child: AsyncValueWidget(
            value: historyAsync,
            error: (error, stackTrace) => _buildErrorState(context),
            data: (history) => _buildHistoryContent(context, history),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryContent(
    BuildContext context,
    List<DetectionResult> history,
  ) {
    if (history.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: const EdgeInsets.only(
        left: AppSpacing.m,
        right: AppSpacing.m,
        top: AppSpacing.l,
        bottom: AppSpacing.l,
      ),
      itemCount: history.length,
      separatorBuilder:
          (context, index) => const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) {
        final detection = history[index];

        // Calculate animation delay for staggered effect
        final intervalStart = (index * 0.1).clamp(0.0, 0.8);
        final intervalEnd = (intervalStart + 0.3).clamp(0.0, 1.0);

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.2), // Slide up from bottom
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _staggeredController,
            curve: Interval(
              intervalStart,
              intervalEnd,
              curve: Curves.easeOutQuad,
            ),
          ),
        );

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggeredController,
            curve: Interval(
              intervalStart,
              intervalEnd,
              curve: Curves.easeOutQuad,
            ),
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: HistoryListItem(
              detection: detection,
              onTap: () {
                context.goNamed(AppRoute.result.name, extra: detection.id);
              },
              onConfirmDelete: _confirmDeleteItem,
              onDeleted: () {
                ref
                    .read(historyNotifierProvider.notifier)
                    .deleteResult(detection);
                // Optionally show a snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted ${detection.locationName}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _staggeredController, curve: Curves.easeOut),
    );

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggeredController, curve: Curves.easeOut),
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.map_outlined,
                    color: AppColors.accent.withValues(alpha: 0.6),
                    size: 64,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  'No History Found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Locations you analyze will appear here. Let\'s find your first one!',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.textGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton.icon(
                  onPressed: () => context.goNamed(AppRoute.home.name),
                  icon: const Icon(Icons.explore_outlined),
                  label: const Text('Analyze a Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.m,
                    ),
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              color: AppColors.errorRed.withValues(alpha: 0.7),
              size: 64,
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Failed to Load History',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Couldn\'t retrieve your saved locations. Please check your connection and try again.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(historyNotifierProvider),
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

// New painter for a subtle background grid
class SubtleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.darkGrey.withValues(alpha: 0.02)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    const double step = 30.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
