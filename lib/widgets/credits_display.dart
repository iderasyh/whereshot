import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whereshot/providers/user_provider.dart';
import 'package:whereshot/theme/app_theme.dart';

class CreditsDisplay extends ConsumerWidget {
  const CreditsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userNotifierProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m, 
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: userAsync.when(
        data: (user) {
          final credits = user?.credits ?? 0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: AppColors.accent,
                  ),
                  SizedBox(width: AppSpacing.s),
                  Text(
                    'Credits',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                '$credits',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        error: (error, stack) => const Text(
          'Error loading credits',
          style: TextStyle(color: AppColors.errorRed),
        ),
      ),
    );
  }
} 