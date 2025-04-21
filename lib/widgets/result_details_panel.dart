import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whereshot/models/detection_result.dart';
import 'package:whereshot/theme/app_theme.dart';

class ResultDetailsPanel extends StatelessWidget {
  final DetectionResult detection;
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const ResultDetailsPanel({
    super.key,
    required this.detection,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: isExpanded ? size.height * 0.6 : size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle for sliding
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            child: Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.mediumGrey,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Location Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_more : Icons.expand_less,
                    color: AppColors.accent,
                  ),
                  onPressed: onExpandToggle,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.m + MediaQuery.of(context).viewPadding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clues/reasoning section
                  _buildCluesCard(context, detection),

                  const SizedBox(height: AppSpacing.m),

                  // Coordinates section when available
                  if (detection.hasCoordinates) ...[
                    _buildCoordinatesCard(context, detection),
                  ],

                  const SizedBox(height: AppSpacing.m),

                  // Timestamp
                  _buildTimeCard(context, detection),

                  // Added extra space at the bottom to ensure no overflow
                  const SizedBox(height: AppSpacing.l),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // New method to display coordinates with copy functionality
  Widget _buildCoordinatesCard(
    BuildContext context,
    DetectionResult detection,
  ) {
    final coordString =
        '${detection.latitude!.toStringAsFixed(6)}, ${detection.longitude!.toStringAsFixed(6)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.l),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.gps_fixed,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    'Coordinates',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: AppColors.accent, size: 18),
                onPressed: () {
                  // Copy coordinates to clipboard
                  Clipboard.setData(ClipboardData(text: coordString));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Coordinates copied: $coordString'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(coordString, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildCluesCard(BuildContext context, DetectionResult detection) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.l),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                'Detection Clues',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(detection.clues, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTimeCard(BuildContext context, DetectionResult detection) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.l),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.accent, size: 20),
          const SizedBox(width: AppSpacing.s),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detected on',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                _formatDateTime(detection.timestamp),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final detectionDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String formattedDate;
    if (detectionDate == today) {
      formattedDate = 'Today';
    } else if (detectionDate == yesterday) {
      formattedDate = 'Yesterday';
    } else {
      formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final formattedTime =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$formattedDate at $formattedTime';
  }
}
