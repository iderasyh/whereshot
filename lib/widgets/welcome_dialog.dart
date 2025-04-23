import 'package:flutter/material.dart';
import 'package:whereshot/theme/app_theme.dart';
import 'package:confetti/confetti.dart';

import '../router/app_router.dart';

class WelcomeDialog extends StatefulWidget {
  const WelcomeDialog({super.key});

  @override
  State<WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;
  late ConfettiController _buttonConfettiController;
  bool _showButtonAnimation = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, // Bouncy effect
    );
    
    // Initialize confetti controllers
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    
    _buttonConfettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    
    // Start animations
    _controller.forward();
    // Play confetti on initial display
    Future.delayed(const Duration(milliseconds: 300), () {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    _buttonConfettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Initial confetti animation positioned at the top
        Positioned(
          top: 0,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14 / 2, // Straight down
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 20,
            minBlastForce: 10,
            gravity: 0.2,
            colors: const [
              AppColors.accent,
              AppColors.accentAlt,
              Colors.green,
              Colors.yellow,
              Colors.purple,
            ],
          ),
        ),
        
        // Button press confetti animations - multiple positions for better effect
        Positioned(
          bottom: 40,
          child: ConfettiWidget(
            confettiController: _buttonConfettiController,
            blastDirection: -3.14 / 2, // Straight up
            emissionFrequency: 0.07,
            numberOfParticles: 30,
            maxBlastForce: 25,
            minBlastForce: 15,
            gravity: 0.1,
            particleDrag: 0.05,
            colors: const [
              AppColors.accent,
              AppColors.accentAlt,
              Colors.green,
              Colors.yellow,
              Colors.pink,
              Colors.purple,
              Colors.orange,
            ],
          ),
        ),
        
        // Left side confetti
        Positioned(
          bottom: 40,
          left: 40,
          child: ConfettiWidget(
            confettiController: _buttonConfettiController,
            blastDirection: -3.14 / 3, // Up and right
            emissionFrequency: 0.08,
            numberOfParticles: 15,
            maxBlastForce: 20,
            minBlastForce: 10,
            gravity: 0.1,
            particleDrag: 0.05,
            colors: const [
              AppColors.accent,
              AppColors.accentAlt,
              Colors.yellow,
              Colors.pink,
            ],
          ),
        ),
        
        // Right side confetti
        Positioned(
          bottom: 40,
          right: 40,
          child: ConfettiWidget(
            confettiController: _buttonConfettiController,
            blastDirection: -2 * 3.14 / 3, // Up and left
            emissionFrequency: 0.08,
            numberOfParticles: 15,
            maxBlastForce: 20,
            minBlastForce: 10,
            gravity: 0.1,
            particleDrag: 0.05,
            colors: const [
              AppColors.accent,
              AppColors.accentAlt,
              Colors.green,
              Colors.purple,
            ],
          ),
        ),
        
        // The dialog itself
        ScaleTransition(
          scale: _scaleAnimation,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.l),
            ),
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: AppColors.accent,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  'Welcome Aboard!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'We\'ve added 1 free credit to your account to get you started exploring WhereShot!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
                ),
                const SizedBox(height: AppSpacing.l),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  transform: _showButtonAnimation 
                    ? (Matrix4.identity()..scale(1.2))
                    : Matrix4.identity(),
                  transformAlignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl, vertical: AppSpacing.m),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.m),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.accent.withValues(alpha: 0.3),
                    ),
                    onPressed: () {
                      // Play celebration animation when button is pressed
                      setState(() {
                        _showButtonAnimation = true;
                      });
                      _buttonConfettiController.play();
                      
                      // Add a small delay before closing the dialog
                      Future.delayed(const Duration(milliseconds: 1500), () {
                        Navigator.of(rootNavigatorKey.currentContext!).pop();
                      });
                    },
                    child: const Text(
                      'Awesome!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            contentPadding: const EdgeInsets.fromLTRB(
              AppSpacing.l, AppSpacing.s, AppSpacing.l, AppSpacing.l),
            actionsPadding: EdgeInsets.zero,
            actionsAlignment: MainAxisAlignment.center,
            actions: const [], // Using content for button instead
          ),
        ),
      ],
    );
  }
} 