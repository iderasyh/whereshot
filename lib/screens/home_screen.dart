import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_constants.dart';
import '../providers/location_detection_provider.dart';
import '../providers/ui_providers.dart';
import '../providers/user_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/async_value_widget.dart';
import '../models/user.dart';
import '../models/detection_result.dart';
import '../widgets/processing_animation_overlay.dart';
import '../widgets/welcome_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  bool _saveImage = true;
  bool _isProcessing = false;
  File? _currentlyProcessingImageFile;
  bool _isPickingPhoto = false;
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDefaultStorageMode();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
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

  void _checkAndShowWelcomeMessage(bool showWelcomeMessage) {
    if (showWelcomeMessage == true) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => const WelcomeDialog(),
        );
      }
      ref.read(showWelcomeMessageProvider.notifier).consumed();
    }
  }

  Future<void> _pickPhoto() async {
    setState(() {
      _isPickingPhoto = true;
    });

    try {
      final status = await Permission.photos.status;
      PermissionStatus requestedStatus;

      if (status.isGranted || status.isLimited) {
        await _openImagePicker();
      } else if (status.isDenied) {
        requestedStatus = await Permission.photos.request();
        if (requestedStatus.isGranted || requestedStatus.isLimited) {
          await _openImagePicker();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Photo library access is needed to select a photo.',
                ),
                backgroundColor: AppColors.textGrey,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Permission Required'),
                  content: const Text(
                    'Photo library access is permanently denied. Please enable it in app settings to select photos.',
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text('Open Settings'),
                      onPressed: () {
                        openAppSettings();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingPhoto = false;
        });
      }
    }
  }

  Future<void> _openImagePicker() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: AppConstants.maxImageWidth,
      maxHeight: AppConstants.maxImageHeight,
      imageQuality: AppConstants.imageQuality.toInt(),
    );

    if (pickedImage != null) {
      await _processImage(File(pickedImage.path));
    }
  }

  Future<void> _processImage(File imageFile) async {
    _currentlyProcessingImageFile = imageFile;
    setState(() {
      _isProcessing = true;
    });

    bool navigateToResult = false;

    try {
      final hasError = await ref
          .read(locationDetectionNotifierProvider.notifier)
          .detectLocationFromFile(imageFile, saveImage: _saveImage);

      if (!hasError) {
        navigateToResult = true;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _currentlyProcessingImageFile = null;
        });
        if (navigateToResult) {
          context.goNamed(AppRoute.result.name);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(showWelcomeMessageProvider, (_, next) {
      _checkAndShowWelcomeMessage(next);
    });

    ref.listen<AsyncValue<DetectionResult?>>(
      locationDetectionNotifierProvider,
      (_, next) {
        if (next is AsyncError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.error.toString()),
                backgroundColor: AppColors.errorRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );

    final userAsync = ref.watch(userNotifierProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HomeAppBar(userAsync: userAsync),
                  const SizedBox(height: AppSpacing.l),
                  Expanded(
                    child: _AnimatedUploadButton(
                      isPickingPhoto: _isPickingPhoto,
                      isProcessing: _isProcessing,
                      onTap: _pickPhoto,
                      rotateController: _rotateController,
                      pulseAnimation: _pulseAnimation,
                      rotateAnimation: _rotateAnimation,
                      size: size,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  _HomeBottomControls(
                    saveImage: _saveImage,
                    onSaveImageChanged: (value) {
                      setState(() {
                        _saveImage = value;
                      });
                      ref
                          .read(userNotifierProvider.notifier)
                          .toggleDefaultSaveMode();
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_isProcessing && _currentlyProcessingImageFile != null)
            Positioned.fill(
              child: ProcessingAnimationOverlay(
                imageFile: _currentlyProcessingImageFile!,
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  final AsyncValue<User?> userAsync;

  const _HomeAppBar({required this.userAsync});

  @override
  Widget build(BuildContext context) {
    final creditsLoadingWidget = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(AppRadius.l),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGrey.withValues(alpha: 0.1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SizedBox(
        width: 18,
        height: 18,
        child: AppTheme.adaptiveWidget(
          context: context,
          material: const CircularProgressIndicator(strokeWidth: 2),
          cupertino: const CupertinoActivityIndicator(),
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AsyncValueWidget<User?>(
          value: userAsync,
          loading: creditsLoadingWidget,
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
                    color: AppColors.darkGrey.withValues(alpha: 0.1),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => context.goNamed(AppRoute.store.name),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
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
              ),
            );
          },
          error:
              (e, st) =>
                  const Icon(Icons.error_outline, color: AppColors.errorRed),
        ),

        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),

        IconButton(
          icon: const Icon(Icons.history_rounded, color: AppColors.darkGrey),
          tooltip: 'View History',
          onPressed: () => context.goNamed(AppRoute.history.name),
        ),
      ],
    );
  }
}

class _AnimatedUploadButton extends StatelessWidget {
  final bool isPickingPhoto;
  final bool isProcessing;
  final VoidCallback onTap;
  final AnimationController rotateController;
  final Animation<double> pulseAnimation;
  final Animation<double> rotateAnimation;
  final Size size;

  const _AnimatedUploadButton({
    required this.isPickingPhoto,
    required this.isProcessing,
    required this.onTap,
    required this.rotateController,
    required this.pulseAnimation,
    required this.rotateAnimation,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final showFullButton = !isProcessing;

    return Center(
      child: GestureDetector(
        onTap: isPickingPhoto || isProcessing ? null : onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([rotateController, pulseAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: showFullButton ? pulseAnimation.value : 1.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: rotateAnimation.value,
                    child: Container(
                      width: size.width * 0.65,
                      height: size.width * 0.65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.1),
                            AppColors.accent.withValues(alpha: 0.5),
                            AppColors.accentAlt.withValues(alpha: 0.5),
                            AppColors.accentAlt.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (showFullButton)
                    Container(
                      width: size.width * 0.45,
                      height: size.width * 0.45,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkGrey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child:
                          isPickingPhoto
                              ? Center(
                                child: AppTheme.adaptiveWidget(
                                  context: context,
                                  material: const CircularProgressIndicator(),
                                  cupertino: const CupertinoActivityIndicator(),
                                ),
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.upload_rounded,
                                    size: 48,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(height: AppSpacing.s),
                                  Text(
                                    'Choose a photo',
                                    style: TextStyle(
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Discover exact location',
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
    );
  }
}

class _HomeBottomControls extends StatelessWidget {
  final bool saveImage;
  final ValueChanged<bool> onSaveImageChanged;

  const _HomeBottomControls({
    required this.saveImage,
    required this.onSaveImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.l),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  saveImage ? 'Save result' : 'Quick check',
                  style: const TextStyle(
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              AppTheme.adaptiveWidget(
                context: context,
                material: Switch(
                  value: saveImage,
                  activeColor: AppColors.accent,
                  onChanged: onSaveImageChanged,
                ),
                cupertino: CupertinoSwitch(
                  value: saveImage,
                  activeTrackColor: AppColors.accent,
                  onChanged: onSaveImageChanged,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        TextButton(
          onPressed: () => context.goNamed(AppRoute.store.name),
          style: TextButton.styleFrom(foregroundColor: AppColors.textGrey),
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(
                    color: AppColors.textGrey, // Default color for the span
                  ),
              children: const <TextSpan>[
                TextSpan(text: 'Need More Location Finds? '),
                TextSpan(
                  text: 'Get Credits',
                  style: TextStyle(
                    color: AppColors.accent, // Accent color for this part
                    fontWeight: FontWeight.w500, // Keep consistent weight if needed
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}