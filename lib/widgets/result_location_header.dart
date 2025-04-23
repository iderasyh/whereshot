import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

import '../models/detection_result.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../router/app_router.dart';

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
                // Timestamp display
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppColors.textGrey,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      // Format the timestamp
                      DateFormat('MMM d, yyyy').format(detection.timestamp),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textGrey,
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
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Conditionally display city/country
                          _buildLocationSubtitle(context, detection),
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
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: AppColors.textGrey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      // Return an empty container if nothing should be displayed
      return const SizedBox.shrink();
    }
  }

  Widget _buildCoordinateChip(BuildContext context, DetectionResult detection) {
    // Ensure coordinates are available
    if (detection.latitude == null || detection.longitude == null) {
      return const SizedBox.shrink(); // Don't show chip if no coordinates
    }

    return GestureDetector(
      onTap:
          () => _launchMaps(context, detection.latitude!, detection.longitude!),
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
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Function to launch Google Maps
  Future<void> _launchMaps(
    BuildContext context,
    double latitude,
    double longitude,
  ) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        // Handle the error if the URL can't be launched
        ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.couldNotOpenMaps),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      // Catch any other exceptions during launch
      ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(AppConstants.couldNotOpenMaps),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }
}
