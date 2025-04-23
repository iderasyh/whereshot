import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whereshot/providers/ui_providers.dart';
import 'package:whereshot/theme/app_theme.dart';
import 'package:whereshot/widgets/animated_gradient_border.dart';

import '../constants/app_constants.dart';

class BoardingScreen extends ConsumerStatefulWidget {
  const BoardingScreen({super.key});

  @override
  ConsumerState<BoardingScreen> createState() => _BoardingScreenState();
}

class _BoardingScreenState extends ConsumerState<BoardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // Start slightly below
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_isSigningIn) return;

    setState(() {
      _isSigningIn = true;
    });

    try {
      await ref.read(showWelcomeMessageProvider.notifier).signInAnonymously();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppConstants.anErrorOccurred}: $e'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          _buildBackgroundGradient(size),

          // Main Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // App Icon / Logo Placeholder (Futuristic Style)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildAppIcon(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'Find Any Photo\'s Location Instantly',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight:
                                FontWeight.w300, // Lighter for futuristic feel
                            letterSpacing: 1.1,
                            shadows: [
                              Shadow(
                                color: AppColors.accent.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Description
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'WhereShot uses advanced AI to detect the exact place where any photo was taken. Upload an image and reveal its real-world location in seconds.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.lightGrey.withValues(alpha: 0.8),
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Get Started Button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildGetStartedButton(context),
                      ),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppIcon() {
    // Futuristic Icon Placeholder - shimmering effect
    return AnimatedGradientBorder(
      borderSize: 2,
      glowSize: 8,
      gradientColors: [
        AppColors.accent.withValues(alpha: 0.6),
        AppColors.accentAlt.withValues(alpha: 0.6),
        AppColors.accent.withValues(alpha: 0.6),
      ],
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.darkGrey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(
            28,
          ), // Slightly smaller inner radius
        ),
        child: Icon(
          Icons.location_searching_rounded,
          size: 60,
          color: AppColors.accent.withValues(alpha: 0.9),
          shadows: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isSigningIn ? null : _handleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.m + AppSpacing.xs,
          horizontal: AppSpacing.xxl, // Make wider
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl), // More rounded
        ),
        elevation: 8,
        shadowColor: AppColors.accent.withValues(alpha: 0.4),
      ),
      child:
          _isSigningIn
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Text(
                'GET STARTED',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
    );
  }

  Widget _buildBackgroundGradient(Size size) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkGrey, // Start dark
            AppColors.darkGrey.withValues(alpha: 0.9), // Slightly lighter dark
            const Color(0xFF1A233A), // Deep blue/purple hint
            AppColors.darkGrey.withValues(alpha: 0.9),
            AppColors.darkGrey,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
      // Optional: Add a subtle pattern or blur effect
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
        child: Container(
          color: Colors.black.withValues(alpha: 0.1), // Subtle overlay
        ),
      ),
    );
  }
}
