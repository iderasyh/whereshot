import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/detection_result.dart';
import '../providers/location_detection_provider.dart';
import '../providers/history_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../utils/async_value_ui.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/map_view.dart';
import '../widgets/image_overlay.dart';
import '../widgets/no_coordinates_background.dart';
import '../widgets/result_details_panel.dart';
import '../widgets/result_location_header.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final String? detectionId;

  const ResultScreen({super.key, this.detectionId});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showMap = false;
  bool _expandedDetails = false;
  bool _showingImage = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Small delay before showing map to allow animations to complete
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _showMap = true;
        });
      }
    });

    // If a detection ID was provided, load it from history
    if (widget.detectionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDetectionFromHistory(widget.detectionId!);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detectionAsync = ref.watch(locationDetectionNotifierProvider);
    ref.listen<AsyncValue<DetectionResult?>>(
      locationDetectionNotifierProvider,
      (_, next) {
        next.showAlertDialogOnError(context);
      },
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      // Wrap AppBar in AnimatedOpacity
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showingImage ? 0.0 : 1.0,
          // Ignore pointer events when hidden
          child: IgnorePointer(
            ignoring: _showingImage,
            child: CustomAppBar(
              title: '',
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: AppTheme.adaptiveWidget(
                context: context,
                material: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                  onPressed:
                      () =>
                          widget.detectionId != null
                              ? context.goNamed(AppRoute.history.name)
                              : context.goNamed(AppRoute.home.name),
                ),
                cupertino: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  onPressed:
                      () =>
                          widget.detectionId != null
                              ? context.goNamed(AppRoute.history.name)
                              : context.goNamed(AppRoute.home.name),
                ),
              ),
              actions: [
                Builder(
                  builder: (context) {
                    final detectionData = detectionAsync.maybeWhen(
                      data: (detection) => detection,
                      orElse: () => null,
                    );
                    
                    // Only show image button if there's an image
                    if (detectionData?.imageUrl != null) {
                      return IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.image, size: 20),
                        ),
                        onPressed: () {
                          setState(() {
                            _showingImage = true;
                          });
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomPaint(
            painter: BubblesPainter(), // Keep the background bubbles
            child: detectionAsync.maybeWhen(
              data: (detection) {
                if (detection == null) {
                  return const Center(
                    child: Text('No detection data available'),
                  );
                }
                return _buildResultContent(context, detection);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.errorRed,
                          size: 64,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          'Error loading result',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.errorRed),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        ElevatedButton(
                          onPressed: () => context.goNamed(AppRoute.home.name),
                          child: const Text('Return Home'),
                        ),
                      ],
                    ),
                  ),
              orElse: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
          
          // Image viewer overlay (using the extracted widget)
          ImageOverlay(
            detection: detectionAsync.asData?.value,
            isVisible: _showingImage,
            onClose: () {
              setState(() {
                _showingImage = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent(BuildContext context, DetectionResult detection) {
    final fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    return Stack(
      children: [
        // Background (Map or No Coordinates)
        Positioned.fill(
          child: FadeTransition(
            opacity: fadeAnimation,
            child: detection.hasCoordinates
                ? _showMap
                    ? MapView(
                        initialPosition: LatLng(
                          detection.latitude!,
                          detection.longitude!,
                        ),
                        initialZoom: 12.0,
                        markers: {
                          Marker(
                            markerId: MarkerId(detection.id),
                            position: LatLng(
                              detection.latitude!,
                              detection.longitude!,
                            ),
                            infoWindow: InfoWindow(
                              title: detection.locationName,
                            ),
                          ),
                        },
                      )
                    : const SizedBox.shrink()
                : NoCoordinatesBackground(
                    locationName: detection.locationName,
                  ),
          ),
        ),

        // Content layout
        Column(
          children: [
            // Top information card (using extracted widget)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.2, 1.0),
                  ),
                  child: ResultLocationHeader(detection: detection),
                ),
              ),
            ),
            
            const Spacer(),
            
            // Bottom information panel (using extracted widget)
            AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              offset: Offset(0, _expandedDetails ? 0 : 0.65),
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    // Swipe up - expand
                    setState(() => _expandedDetails = true);
                  } else if (details.primaryVelocity! > 0) {
                    // Swipe down - collapse
                    setState(() => _expandedDetails = false);
                  }
                },
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.4, 1.0),
                  ),
                  child: ResultDetailsPanel(
                    detection: detection,
                    isExpanded: _expandedDetails,
                    onExpandToggle: () {
                      setState(() {
                        _expandedDetails = !_expandedDetails;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Load a detection from history by ID
  Future<void> _loadDetectionFromHistory(String id) async {
    try {
      final historyAsync = await ref.read(historyNotifierProvider.future);
      
      // Find the detection in history
      final detection = historyAsync.firstWhere(
        (result) => result.id == id,
        orElse: () => throw Exception('Detection not found'),
      );
      
      // Set the current detection
      ref
          .read(locationDetectionNotifierProvider.notifier)
          .setDetectionResult(detection);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading detection: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }
}

// BubblesPainter remains here as it's a simple background effect specific to this screen
class BubblesPainter extends CustomPainter {
  final List<Bubble> bubbles = List.generate(
    15,
    (index) => Bubble(
      radius: 5 + math.Random().nextDouble() * 20,
      position: Offset(
        math.Random().nextDouble() * 400,
        math.Random().nextDouble() * 800,
      ),
      color: AppColors.accent.withValues(
        alpha: 0.05 + math.Random().nextDouble() * 0.05,
      ),
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final bubble in bubbles) {
      paint.color = bubble.color;
      canvas.drawCircle(bubble.position, bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Bubble {
  final double radius;
  final Offset position;
  final Color color;

  Bubble({required this.radius, required this.position, required this.color});
}
