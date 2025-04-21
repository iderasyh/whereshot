import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:whereshot/models/detection_result.dart';
import 'package:whereshot/theme/app_theme.dart';

class ResultLocationHeader extends StatelessWidget {
  final DetectionResult detection;

  const ResultLocationHeader({super.key, required this.detection});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.l),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.l),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Confidence indicator
                Row(
                  children: [
                    _buildConfidenceIndicator(detection.confidence),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      '${(detection.confidence * 100).toInt()}% confidence',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: _getConfidenceColor(detection.confidence),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    if (detection.hasCoordinates)
                      _buildCoordinateChip(context, detection),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                
                // Location name
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.m),
                      ),
                      child: const Icon(
                        Icons.place_rounded,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detection.locationName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${detection.locationCity}, ${detection.locationCountry}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator(double confidence) {
    final color = _getConfidenceColor(confidence);
    final segments = 5;
    final filledSegments = (confidence * segments).round();

    return Row(
      children: List.generate(
        segments,
        (index) => Container(
          margin: const EdgeInsets.only(right: 2),
          width: 8,
          height: 16,
          decoration: BoxDecoration(
            color: index < filledSegments ? color : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.successGreen;
    if (confidence >= 0.5) return const Color(0xFFFFA000); // Amber
    return AppColors.accentAlt; // Lower confidence
  }

  Widget _buildCoordinateChip(BuildContext context, DetectionResult detection) {
    return GestureDetector(
      onTap: () {
        final coordText =
            '${detection.latitude!.toStringAsFixed(6)}, ${detection.longitude!.toStringAsFixed(6)}';
        // Actually copy to clipboard
        Clipboard.setData(ClipboardData(text: coordText)); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coordinates copied: $coordText'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.gps_fixed, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              'GPS',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
} 