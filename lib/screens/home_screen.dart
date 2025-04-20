import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whereshot/constants/app_constants.dart';
import 'package:whereshot/providers/user_provider.dart';
import 'package:whereshot/providers/location_detection_provider.dart';
import 'package:whereshot/router/app_router.dart';
import 'package:whereshot/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  bool _saveImage = true;
  bool _isProcessing = false;
  late final AnimationController _animationController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );
    
    // Load user's default storage preference
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDefaultStorageMode();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultStorageMode() async {
    final userAsync = ref.read(userNotifierProvider);
    userAsync.whenData((user) {
      if (user != null) {
        setState(() {
          _saveImage = user.defaultSaveMode;
        });
      }
    });
  }

  Future<void> _pickPhoto() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: AppConstants.maxImageWidth,
      maxHeight: AppConstants.maxImageHeight,
      imageQuality: AppConstants.imageQuality.toInt(),
    );

    if (pickedImage != null) {
      _processImage(File(pickedImage.path));
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Call the location detection service
      await ref
          .read(locationDetectionNotifierProvider.notifier)
          .detectLocationFromFile(imageFile, saveImage: _saveImage);

      // Navigate to the result screen
      if (mounted) {
        context.goNamed(AppRoute.result.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userNotifierProvider);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Background subtle pattern
          Positioned.fill(
            child: CustomPaint(
              painter: PatternPainter(
                color: AppColors.lightGrey.withValues(alpha: 0.3),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                  
                  // Expanded area with centered upload zone
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _isProcessing ? null : _pickPhoto,
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Rotating gradient ring
                                  Transform.rotate(
                                    angle: _rotateAnimation.value,
                                    child: Container(
                                      width: size.width * 0.65,
                                      height: size.width * 0.65,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: SweepGradient(
                                          colors: [
                                            AppColors.accent.withOpacity(0.1),
                                            AppColors.accent.withOpacity(0.5),
                                            AppColors.accentAlt.withOpacity(0.5),
                                            AppColors.accentAlt.withOpacity(0.1),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Inner circle
                                  Container(
                                    width: size.width * 0.45,
                                    height: size.width * 0.45,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.darkGrey.withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: _isProcessing
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.upload_rounded,
                                                size: 48,
                                                color: AppColors.accent,
                                              ),
                                              const SizedBox(height: AppSpacing.s),
                                              Text(
                                                'Share a moment',
                                                style: TextStyle(
                                                  color: AppColors.darkGrey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                'Discover its place',
                                                style: TextStyle(
                                                  color: AppColors.textGrey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // Bottom area with toggle and store link
                  Column(
                    children: [
                      // Storage toggle with elegant styling
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.m,
                          vertical: AppSpacing.s,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppRadius.l),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _saveImage
                                    ? 'Keep memories'
                                    : 'Temporary exploration',
                                style: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Switch(
                              value: _saveImage,
                              activeColor: AppColors.accent,
                              onChanged: (bool value) {
                                setState(() {
                                  _saveImage = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.m),
                      
                      // Store link
                      TextButton(
                        onPressed: () => context.goNamed(AppRoute.store.name),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textGrey,
                        ),
                        child: const Text('Need inspiration? Get more credits'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Credits display as a floating badge
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.m,
            right: AppSpacing.m,
            child: userAsync.when(
              data: (user) {
                final credits = user?.credits ?? 0;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkGrey.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$credits',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGrey.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for subtle background pattern
class PatternPainter extends CustomPainter {
  final Color color;
  
  PatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    final double spacing = 40.0;
    final double dotSize = 2.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 