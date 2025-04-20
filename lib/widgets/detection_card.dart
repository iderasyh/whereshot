import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:whereshot/models/detection_result.dart';
import 'package:whereshot/theme/app_theme.dart';

class DetectionCard extends StatelessWidget {
  final DetectionResult detection;
  final bool showActions;
  final VoidCallback? onDelete;
  final VoidCallback? onSave;
  
  const DetectionCard({
    super.key,
    required this.detection,
    this.showActions = false,
    this.onDelete,
    this.onSave,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.l),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo display
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: AppRadius.radiusL,
              topRight: AppRadius.radiusL,
            ),
            child: _buildImage(),
          ),
          
          // Location name
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location name
                Text(
                  detection.locationName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.s),
                
                // Coordinates if available
                if (detection.hasCoordinates)
                  Text(
                    'Coordinates: ${detection.latitude!.toStringAsFixed(4)}, ${detection.longitude!.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                
                // Time detected
                Text(
                  'Detected: ${_formatTimestamp(detection.timestamp)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                
                // Action buttons if enabled
                if (showActions && (onDelete != null || onSave != null))
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.m),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: onDelete,
                            color: AppColors.errorRed,
                          ),
                        if (onSave != null)
                          IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: onSave,
                            color: AppColors.accent,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImage() {
    // If we have a URL, use CachedNetworkImage
    if (detection.imageUrl != null && detection.imageUrl!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: detection.imageUrl!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.error),
        ),
      );
    }
    
    // If it's a local file path
    if (detection.imageUrl != null && File(detection.imageUrl!).existsSync()) {
      return Image.file(
        File(detection.imageUrl!),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    
    // Fallback if no image
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.lightGrey,
      child: const Center(
        child: Icon(
          Icons.photo,
          size: 48,
          color: AppColors.mediumGrey,
        ),
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
} 