import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whereshot/models/detection_result.dart';
import 'package:whereshot/theme/app_theme.dart';

class ResultDetails extends StatelessWidget {
  final DetectionResult detection;
  
  const ResultDetails({
    super.key,
    required this.detection,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result title
          Text(
            'Location Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppSpacing.m),
          
          // Location name
          _buildDetailRow(
            context,
            'Name',
            detection.locationName,
            Icons.place,
          ),
          
          const SizedBox(height: AppSpacing.s),
          
          // Coordinates if available
          if (detection.hasCoordinates) ...[
            _buildDetailRow(
              context,
              'Coordinates',
              '${detection.latitude!.toStringAsFixed(6)}, ${detection.longitude!.toStringAsFixed(6)}',
              Icons.explore,
              canCopy: true,
            ),
            
            const SizedBox(height: AppSpacing.s),
          ],
          
          // Original prompt if available
          if (detection.originalPrompt != null) ...[
            Text(
              'AI Analysis',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              detection.originalPrompt!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool canCopy = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.accent,
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        if (canCopy)
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 18,
          ),
      ],
    );
  }
} 