import 'package:flutter/material.dart';

class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderSize;
  final double glowSize;
  final List<Color> gradientColors;
  final BorderRadius borderRadius;
  final Duration animationDuration;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.borderSize = 2.0,
    this.glowSize = 8.0,
    required this.gradientColors,
    this.borderRadius = BorderRadius.zero,
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(); // Repeat the animation indefinitely

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _GradientBorderPainter(
            borderSize: widget.borderSize,
            glowSize: widget.glowSize,
            gradientColors: widget.gradientColors,
            borderRadius: widget.borderRadius,
            animationValue: _animation.value,
          ),
          child: Padding(
            // Add padding to prevent child overlapping the border/glow
            padding: EdgeInsets.all(widget.borderSize + widget.glowSize / 4),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double borderSize;
  final double glowSize;
  final List<Color> gradientColors;
  final BorderRadius borderRadius;
  final double animationValue; // Value from 0.0 to 1.0

  _GradientBorderPainter({
    required this.borderSize,
    required this.glowSize,
    required this.gradientColors,
    required this.borderRadius,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);

    // Calculate gradient rotation based on animation
    final angle = animationValue * 2 * 3.14159; // Full rotation

    // Create the sweep gradient
    final gradient = SweepGradient(
      colors: gradientColors,
      startAngle: 0.0,
      endAngle: 2 * 3.14159,
      transform: GradientRotation(angle), // Apply rotation
      tileMode: TileMode.repeated,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = borderSize
      ..style = PaintingStyle.stroke;

    // Draw the main border
    canvas.drawRRect(rrect.deflate(borderSize / 2), paint);

    // Draw the glow effect (optional)
    if (glowSize > 0) {
      final glowPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..strokeWidth = borderSize // Base the glow width on the border
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSize);
      canvas.drawRRect(rrect.deflate(borderSize / 2), glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    // Repaint whenever the animation value changes
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.borderSize != borderSize ||
           oldDelegate.glowSize != glowSize ||
           oldDelegate.gradientColors != gradientColors ||
           oldDelegate.borderRadius != borderRadius;
  }
} 