import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:whereshot/theme/app_theme.dart';

class ProcessingAnimationOverlay extends StatefulWidget {
  final File imageFile;

  const ProcessingAnimationOverlay({super.key, required this.imageFile});

  @override
  State<ProcessingAnimationOverlay> createState() =>
      _ProcessingAnimationOverlayState();
}

class _ProcessingAnimationOverlayState extends State<ProcessingAnimationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> _statusMessages = [
    'Analyzing image features...',
    'Scanning geographical databases...',
    'Cross-referencing visual clues...',
    'Calculating coordinates...',
    'Pinpointing location...',
  ];
  int _statusIndex = 0;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();

    // Scanning line animation
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();
    _scanAnimation = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    // Pulsing radar background animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.linear));

    // Fade in animation for the whole overlay
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Timer to cycle through status messages
    _statusTimer = Timer.periodic(const Duration(milliseconds: 2200), (timer) {
      if (mounted) {
        setState(() {
          _statusIndex = (_statusIndex + 1) % _statusMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(color: AppColors.darkGrey.withValues(alpha: 0.7)),
          ),

          // Pulsing radar background painter
          CustomPaint(
            painter: _RadarPulsePainter(
              animation: _pulseAnimation,
              color: AppColors.accent.withValues(alpha: 0.1),
            ),
            child: Container(),
          ),

          // Content (Image, Scan line, Text)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image Container with Scan Line
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.m),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AspectRatio(
                      aspectRatio:
                          1.0, // Force square aspect ratio for simplicity, adjust if needed
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Display the image
                          Image.file(widget.imageFile, fit: BoxFit.cover),
                          // Scanning Line Overlay
                          AnimatedBuilder(
                            animation: _scanAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: _ScanLinePainter(
                                  position: _scanAnimation.value,
                                  color: AppColors.accentAlt.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Animated Status Text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      _statusMessages[_statusIndex],
                      key: ValueKey<int>(
                        _statusIndex,
                      ), // Important for AnimatedSwitcher
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.lightGrey.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the scanning line
class _ScanLinePainter extends CustomPainter {
  final double position; // 0.0 to 1.0
  final Color color;

  _ScanLinePainter({required this.position, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2.0
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.1),
              color,
              color.withValues(alpha: 0.1),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final y = size.height * position;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    // Add a subtle glow
    final glowPaint =
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..strokeWidth = 4.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), glowPaint);
  }

  @override
  bool shouldRepaint(_ScanLinePainter oldDelegate) =>
      oldDelegate.position != position;
}

// Custom Painter for the pulsing radar background
class _RadarPulsePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _RadarPulsePainter({required this.animation, required this.color})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.max(size.width, size.height) * 0.8;

    for (int i = 1; i <= 3; i++) {
      final double radius = maxRadius * ((animation.value + (i * 0.33)) % 1.0);
      // Calculate opacity (0.0 to 0.5)
      final double opacity = (1.0 - (radius / maxRadius)) * 0.5;

      final paint =
          Paint()
            // Use the calculated opacity double directly (clamped between 0.0 and 1.0)
            ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RadarPulsePainter oldDelegate) => false; // Handled by animation listener
}
