import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/detection_result.dart';
import '../providers/history_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/async_value_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/detection_card.dart';
import '../widgets/map_view.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  DetectionResult? _selectedDetection;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Refresh history when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(historyNotifierProvider);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _clearAllHistory() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('This will delete all your detection history. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );

    if (shouldClear == true && mounted) {
      await ref.read(historyNotifierProvider.notifier).clearHistory();
      setState(() {
        _selectedDetection = null;
      });
    }
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
          IconButton(
            icon: const Icon(Icons.storefront),
            onPressed: () => context.goNamed(AppRoute.store.name),
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
                // Header with title and clear button
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
                            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
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
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            'Your Detection History',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.m),
                          OutlinedButton.icon(
                            onPressed: _clearAllHistory,
                            icon: const Icon(Icons.delete_sweep),
                            label: const Text('Clear All History'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.l),

                // Selected detection details
                if (_selectedDetection != null)
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
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
                        margin: const EdgeInsets.only(bottom: AppSpacing.m),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(AppRadius.l),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.m),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Selected Location',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _selectedDetection = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.m),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedDetection!.locationName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s),
                                  if (_selectedDetection!.hasCoordinates)
                                    Text(
                                      'Coordinates: ${_selectedDetection!.latitude!.toStringAsFixed(4)}, ${_selectedDetection!.longitude!.toStringAsFixed(4)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  Text(
                                    'Detected: ${_formatTimestamp(_selectedDetection!.timestamp)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedDetection!.hasCoordinates)
                              SizedBox(
                                height: 200,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: AppRadius.radiusL,
                                    bottomRight: AppRadius.radiusL,
                                  ),
                                  child: MapView(
                                    initialPosition: LatLng(
                                      _selectedDetection!.latitude!,
                                      _selectedDetection!.longitude!,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId: MarkerId(_selectedDetection!.id),
                                        position: LatLng(
                                          _selectedDetection!.latitude!,
                                          _selectedDetection!.longitude!,
                                        ),
                                        infoWindow: InfoWindow(
                                          title: _selectedDetection!.locationName,
                                        ),
                                      ),
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // History list
                Expanded(
                  child: AsyncValueWidget(
                    value: historyAsync,
                    loading: const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
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
                            'Failed to load history',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.errorRed),
                          ),
                          const SizedBox(height: AppSpacing.s),
                          ElevatedButton(
                            onPressed: () => ref.refresh(historyNotifierProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    data: (history) {
                      if (history.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.history,
                                color: AppColors.textGrey,
                                size: 48,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              Text(
                                'No detection history yet',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.textGrey,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.l),
                              ElevatedButton.icon(
                                onPressed: () => context.goNamed(AppRoute.home.name),
                                icon: const Icon(Icons.add_a_photo),
                                label: const Text('Detect a Location'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.l,
                                    vertical: AppSpacing.m,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final detection = history[index];
                          final isSelected = _selectedDetection?.id == detection.id;
                          
                          final delay = index * 0.1;
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
                                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDetection = detection;
                                    });
                                    // Navigate to ResultScreen with the detection ID
                                    context.goNamed(
                                      AppRoute.result.name,
                                      extra: detection.id,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: isSelected
                                          ? Border.all(
                                              color: AppColors.accent,
                                              width: 2.5,
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(AppRadius.l),
                                    ),
                                    child: DetectionCard(
                                      detection: detection,
                                      showActions: true,
                                      onDelete: () async {
                                        final shouldDelete = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Item'),
                                            content: const Text(
                                                'Are you sure you want to delete this item from your history?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text('CANCEL'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text('DELETE'),
                                              ),
                                            ],
                                          ),
                                        );
                                        
                                        if (shouldDelete == true && mounted) {
                                          await ref
                                              .read(historyNotifierProvider.notifier)
                                              .deleteResult(detection);
                                          
                                          if (_selectedDetection?.id == detection.id) {
                                            setState(() {
                                              _selectedDetection = null;
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} at '
        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class PatternPainter extends CustomPainter {
  final Color backgroundColor;
  final math.Random _random = math.Random();

  PatternPainter(this.backgroundColor);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background color first to ensure pattern is on top
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