import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whereshot/theme/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(
              color: AppColors.darkGrey.withValues(alpha: 0.5),
            ),
          ),
        ),
        // Centered content
        Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppRadius.m),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTheme.adaptiveWidget(
                  context: context,
                  material: const CircularProgressIndicator(),
                  cupertino: const CupertinoActivityIndicator(),
                ),
                if (message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.m),
                    child: Text(
                      message!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.darkGrey,
                          ),
                      textAlign: TextAlign.center,
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