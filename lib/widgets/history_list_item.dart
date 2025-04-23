import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:whereshot/models/detection_result.dart';
import 'package:whereshot/theme/app_theme.dart';

class HistoryListItem extends StatelessWidget {
  final DetectionResult detection;
  final VoidCallback onTap;
  final Future<bool?> Function() onConfirmDelete;
  final VoidCallback onDeleted;

  const HistoryListItem({
    super.key,
    required this.detection,
    required this.onTap,
    required this.onConfirmDelete,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgoString = timeago.format(detection.timestamp);

    return Dismissible(
      key: Key(detection.id), // Unique key for Dismissible
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.errorRed.withValues(alpha: 0.9),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_sweep, color: AppColors.white),
            SizedBox(width: AppSpacing.s),
            Text('Delete', style: TextStyle(color: AppColors.white)),
          ],
        ),
      ),
      confirmDismiss: (direction) => onConfirmDelete(),
      onDismissed: (direction) => onDeleted(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.l),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.l),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkGrey.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail
              _buildThumbnail(context),
              
              const SizedBox(width: AppSpacing.m),
              
              // Text details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detection.locationName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Conditionally display city/country
                    _buildLocationSubtitle(context, detection),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      timeAgoString,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textGrey.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
              
              // Trailing arrow
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.mediumGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build the location subtitle conditionally
  Widget _buildLocationSubtitle(
    BuildContext context,
    DetectionResult detection,
  ) {
    final city = detection.locationCity;
    final country = detection.locationCountry;
    final bool cityUnknown = city.toLowerCase() == 'unknown';
    final bool countryUnknown = country.toLowerCase() == 'unknown';

    String displayText = '';

    if (!cityUnknown && !countryUnknown) {
      displayText = '$city, $country';
    } else if (!cityUnknown && countryUnknown) {
      displayText = city;
    } else if (cityUnknown && !countryUnknown) {
      displayText = country;
    } // If both are unknown, displayText remains empty

    // Only render the Text widget if there's something to display
    if (displayText.isNotEmpty) {
      return Text(
        displayText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textGrey,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      // Return an empty container if nothing should be displayed
      return const SizedBox.shrink();
    }
  }

  Widget _buildThumbnail(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.m),
        child: detection.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: detection.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: Icon(
                    Icons.image,
                    color: AppColors.mediumGrey,
                    size: 24,
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: AppColors.mediumGrey,
                    size: 24,
                  ),
                ),
              )
            : const Center(
                child: Icon(
                  Icons.public, // Placeholder for no image
                  color: AppColors.mediumGrey,
                  size: 24,
                ),
              ),
      ),
    );
  }
} 