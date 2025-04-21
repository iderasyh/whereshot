import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

import '../models/detection_result.dart';
import '../theme/app_theme.dart';

class ImageOverlay extends StatelessWidget {
  final DetectionResult? detection;
  final bool isVisible;
  final VoidCallback onClose;

  const ImageOverlay({
    super.key,
    required this.detection,
    required this.isVisible,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (detection?.imageUrl == null) {
      return const SizedBox.shrink();
    }

    // Create a hero tag using the detection ID
    final heroTag = 'image-${detection!.id}';

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Visibility(
        visible:
            isVisible, // Ensures the widget doesn't participate in layout when hidden
        child: GestureDetector(
          onTap: onClose,
          child: Container(
            color: Colors.black.withValues(alpha: 0.95),
            width: double.infinity,
            height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xl,
                bottom: AppSpacing.xl,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.white,
                          size: 30,
                        ),
                        onPressed: onClose,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Hero(
                        tag: heroTag,
                        child: FuturisticImageViewer(
                          imageUrl: detection!.imageUrl!,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Column(
                      children: [
                        Text(
                          'ANALYZED PHOTO',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Image processed with AI location detection',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// New widget for futuristic image viewer with scanning animation
class FuturisticImageViewer extends StatefulWidget {
  final String imageUrl;

  const FuturisticImageViewer({super.key, required this.imageUrl});

  @override
  State<FuturisticImageViewer> createState() => _FuturisticImageViewerState();
}

class _FuturisticImageViewerState extends State<FuturisticImageViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _scanAnimation = Tween<double>(begin: -0.2, end: 1.2).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    // Repeat the scanning animation indefinitely (will be stopped by Future.delayed)
    _scanController.repeat();

    // Stop continuous scanning after a few loops
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _scanController.stop();
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.m - 1),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            // Image
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.contain,
                placeholder:
                    (context, url) => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                errorWidget:
                    (context, url, error) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.errorRed,
                          size: 48,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          'Could not load image',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.white),
                        ),
                      ],
                    ),
                imageBuilder: (context, imageProvider) {
                  // Mark image as loaded
                  Future.microtask(() {
                    if (mounted && !_isLoaded) {
                      setState(() {
                        _isLoaded = true;
                      });
                    }
                  });

                  return Image(image: imageProvider, fit: BoxFit.contain);
                },
              ),
            ),

            // Scanning effect
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child:
                      _isLoaded
                          ? CustomPaint(
                            painter: ScanLinePainter(
                              progress: _scanAnimation.value,
                              color: AppColors.accent,
                            ),
                          )
                          : const SizedBox.shrink(),
                );
              },
            ),

            // Grid overlay for futuristic feel
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  gridSize: 30,
                ),
              ),
            ),

            // Corner markers
            Positioned(top: 0, left: 0, child: _buildCornerMarker()),
            Positioned(
              top: 0,
              right: 0,
              child: Transform.rotate(
                angle: math.pi / 2,
                child: _buildCornerMarker(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.rotate(
                angle: math.pi,
                child: _buildCornerMarker(),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Transform.rotate(
                angle: 3 * math.pi / 2,
                child: _buildCornerMarker(),
              ),
            ),

            // Scanning indicators
            Positioned(top: 10, right: 10, child: _buildPulsingDot()),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerMarker() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.accent.withValues(alpha: 0.8),
            width: 2,
          ),
          left: BorderSide(
            color: AppColors.accent.withValues(alpha: 0.8),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildPulsingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent.withValues(alpha: value),
          ),
        );
      },
      onEnd: () {
        setState(() {}); // Restart the animation
      },
    );
  }
}

// Painter for the scanning line
class ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ScanLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Diagonal scanning line
    final startX = -size.width * 0.2 + (size.width * 1.4) * progress;
    final endX = startX + size.width * 0.2;

    canvas.drawLine(Offset(startX, 0), Offset(endX, size.height), paint);

    // Add a glow effect
    final glowPaint =
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawLine(Offset(startX, 0), Offset(endX, size.height), glowPaint);
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Painter for grid overlay
class GridPainter extends CustomPainter {
  final Color color;
  final double gridSize;

  GridPainter({required this.color, required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.gridSize != gridSize;
}
