import 'dart:math' show Random, pi, sqrt, cos, sin;
import 'package:flutter/material.dart';
import 'package:whereshot/theme/app_theme.dart';

// Widget for when no coordinates are available
class NoCoordinatesBackground extends StatefulWidget {
  final String locationName;
  
  const NoCoordinatesBackground({super.key, required this.locationName});
  
  @override
  State<NoCoordinatesBackground> createState() =>
      _NoCoordinatesBackgroundState();
}

class _NoCoordinatesBackgroundState extends State<NoCoordinatesBackground> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<MapPoint> _mapPoints = [];
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    // Generate random map points
    _generateMapPoints();
  }
  
  void _generateMapPoints() {
    // Generate between 30-50 random points
    final pointCount = 30 + _random.nextInt(20);
    
    for (int i = 0; i < pointCount; i++) {
      _mapPoints.add(
        MapPoint(
          position: Offset(
            _random.nextDouble() * 1.5 - 0.25, // x position (-0.25 to 1.25)
            _random.nextDouble() * 1.5 - 0.25, // y position (-0.25 to 1.25)
          ),
          size: 2.0 + _random.nextDouble() * 4.0,
          alpha: 0.3 + _random.nextDouble() * 0.3,
          speed: 0.0002 + _random.nextDouble() * 0.0003,
          direction: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.darkGrey.withValues(alpha: 0.05),
            AppColors.accent.withValues(alpha: 0.1),
            AppColors.lightGrey.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated map background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: CreativeMapPainter(
                  points: _mapPoints,
                  animValue: _animationController.value,
                  accentColor: AppColors.accent,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // Pulsing radar element
          Positioned(bottom: -50, right: -50, child: _buildRadarEffect()),
          
          // Content Card
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.9, end: 1.0),
              duration: const Duration(seconds: 3),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkGrey.withValues(alpha: 0.1),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon with ripple effect
                        _buildPulsingIcon(),
                        
                        const SizedBox(height: AppSpacing.m),
                        
                        // Header
                        ShaderMask(
                          shaderCallback:
                              (bounds) => LinearGradient(
                                colors: [AppColors.accent, AppColors.accentAlt],
                              ).createShader(
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  bounds.width,
                                  bounds.height,
                                ),
                              ),
                          child: Text(
                            'No Exact Location Found',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.s),
                        
                        // Description
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textGrey),
                            children: [
                              const TextSpan(text: 'We identified this as '),
                              TextSpan(
                                text: widget.locationName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    ', but precise coordinates are unavailable for this location.',
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.m),
                        
                        // Additional context
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.accent.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Try a more recognizable landmark',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: AppColors.accent.withValues(alpha: 0.8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              onEnd: () {
                // Repeat the animation with a slight delay
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) setState(() {});
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPulsingIcon() {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Multiple pulsing circles
          for (int i = 0; i < 3; i++)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(seconds: 2 + i),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: (1 - value).clamp(0.0, 0.7),
                  child: Transform.scale(
                    scale: 0.5 + (value * 0.5),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
              onEnd: () {
                if (mounted) setState(() {});
              },
            ),
          
          // Icon in center
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.location_off,
                size: 30,
                color: AppColors.textGrey.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRadarEffect() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 4),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: 0,
              endAngle: 2 * pi,
              transform: GradientRotation(2 * pi * value),
              colors: [
                AppColors.accent.withValues(alpha: 0.0),
                AppColors.accent.withValues(alpha: 0.1),
                AppColors.accent.withValues(alpha: 0.2),
                AppColors.accent.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }
}

// Creative map painter with floating points
class CreativeMapPainter extends CustomPainter {
  final List<MapPoint> points;
  final double animValue;
  final Color accentColor;
  
  CreativeMapPainter({
    required this.points,
    required this.animValue, 
    required this.accentColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw subtle grid
    _drawGrid(canvas, size);
    
    // Draw connecting lines between some points
    _drawConnections(canvas, size);
    
    // Draw animated points
    _drawPoints(canvas, size);
  }
  
  void _drawGrid(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = accentColor.withValues(alpha: 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
    
    const gridSize = 40.0;
    
    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Draw some larger grid lines
    final accentPaint =
        Paint()
          ..color = accentColor.withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    
    const largeGridSize = gridSize * 4;
    
    // Draw vertical accent lines
    for (double x = 0; x <= size.width; x += largeGridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), accentPaint);
    }
    
    // Draw horizontal accent lines
    for (double y = 0; y <= size.height; y += largeGridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), accentPaint);
    }
  }
  
  void _drawPoints(Canvas canvas, Size size) {
    for (final point in points) {
      // Update point position based on animation value
      final currentX =
          (point.position.dx +
              (animValue * point.speed * cos(point.direction))) *
          size.width;
      final currentY =
          (point.position.dy +
              (animValue * point.speed * sin(point.direction))) *
          size.height;
      
      // Ensure point stays within bounds with wrap-around effect
      final screenX = currentX % size.width;
      final screenY = currentY % size.height;
      
      // Draw the point
      final paint =
          Paint()
            ..color = accentColor.withValues(alpha: point.alpha)
            ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(screenX, screenY), point.size, paint);
      
      // Draw slight glow for larger points
      if (point.size > 4) {
        final glowPaint =
            Paint()
              ..color = accentColor.withValues(alpha: point.alpha * 0.3)
              ..style = PaintingStyle.fill
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        
        canvas.drawCircle(
          Offset(screenX, screenY),
          point.size * 1.5,
          glowPaint,
        );
      }
    }
  }
  
  void _drawConnections(Canvas canvas, Size size) {
    // Only connect points that are close to each other
    const double maxDistance = 100.0;
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
    
    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p1x =
          (p1.position.dx + (animValue * p1.speed * cos(p1.direction))) *
          size.width;
      final p1y =
          (p1.position.dy + (animValue * p1.speed * sin(p1.direction))) *
          size.height;
      final pos1 = Offset(p1x % size.width, p1y % size.height);
      
      for (int j = i + 1; j < points.length; j++) {
        final p2 = points[j];
        final p2x =
            (p2.position.dx + (animValue * p2.speed * cos(p2.direction))) *
            size.width;
        final p2y =
            (p2.position.dy + (animValue * p2.speed * sin(p2.direction))) *
            size.height;
        final pos2 = Offset(p2x % size.width, p2y % size.height);
        
        // Calculate distance
        final dx = pos1.dx - pos2.dx;
        final dy = pos1.dy - pos2.dy;
        final distance = sqrt(dx * dx + dy * dy);
        
        if (distance < maxDistance) {
          // The alpha fades out as the distance increases
          final alpha = 0.15 * (1.0 - distance / maxDistance);
          paint.color = accentColor.withValues(alpha: alpha);
          canvas.drawLine(pos1, pos2, paint);
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(CreativeMapPainter oldDelegate) => 
      oldDelegate.animValue != animValue;
}

// Class to store information about a map point
class MapPoint {
  Offset position; // Position in 0-1 range
  final double size;
  final double alpha;
  final double speed;
  final double direction; // in radians
  
  MapPoint({
    required this.position,
    required this.size,
    required this.alpha,
    required this.speed, 
    required this.direction,
  });
}

// Remove the old MapGridPainter - it's not needed anymore
// class MapGridPainter extends CustomPainter { ... } 