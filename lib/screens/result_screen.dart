import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:whereshot/providers/history_provider.dart';
import 'package:whereshot/providers/location_detection_provider.dart';
import 'package:whereshot/router/app_router.dart';
import 'package:whereshot/theme/app_theme.dart';
import 'package:whereshot/widgets/custom_app_bar.dart';
import 'package:whereshot/widgets/detection_card.dart';
import 'package:whereshot/widgets/result_details.dart';
import 'package:whereshot/widgets/history_list.dart';
import 'package:whereshot/widgets/map_view.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh history when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(historyNotifierProvider);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final detectionAsync = ref.watch(locationDetectionNotifierProvider);
    final historyAsync = ref.watch(historyNotifierProvider);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Results',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(AppRoute.home.name),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront),
            onPressed: () => context.goNamed(AppRoute.store.name),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current detection result
              detectionAsync.when(
                data: (detection) {
                  if (detection == null) {
                    return const Center(
                      child: Text('No detection result available'),
                    );
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Detection card with image
                      DetectionCard(
                        detection: detection,
                        showActions: !detection.saved,
                      ),
                      
                      const SizedBox(height: AppSpacing.m),
                      
                      // Result details
                      ResultDetails(detection: detection),
                      
                      const SizedBox(height: AppSpacing.m),
                      
                      // Map view if coordinates available
                      // if (detection.hasCoordinates) 
                      //   SizedBox(
                      //     height: 200,
                      //     child: MapView(
                      //       initialPosition: LatLng(
                      //         detection.latitude!,
                      //         detection.longitude!,
                      //       ),
                      //       markers: {
                      //         Marker(
                      //           markerId: MarkerId(detection.id),
                      //           position: LatLng(
                      //             detection.latitude!,
                      //             detection.longitude!,
                      //           ),
                      //           infoWindow: InfoWindow(
                      //             title: detection.locationName,
                      //           ),
                      //         ),
                      //       },
                      //     ),
                      //   ),
                      
                      const SizedBox(height: AppSpacing.l),
                      
                      // Save/discard actions if temporary
                      if (!detection.saved)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ref.read(locationDetectionNotifierProvider.notifier)
                                    .clearResult();
                                  context.goNamed(AppRoute.home.name);
                                },
                                icon: const Icon(Icons.delete),
                                label: const Text('Discard'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await ref.read(locationDetectionNotifierProvider.notifier)
                                    .saveCurrentResult();
                                  ref.invalidate(historyNotifierProvider);
                                },
                                icon: const Icon(Icons.save),
                                label: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: AppSpacing.l),
                      const Divider(),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Center(
                  child: Text(
                    'Error: ${error.toString()}',
                    style: TextStyle(color: AppColors.errorRed),
                  ),
                ),
              ),
              
              // History heading
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                child: Text(
                  'Detection History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              
              // History list
              Expanded(
                child: historyAsync.when(
                  data: (history) {
                    if (history.isEmpty) {
                      return const Center(
                        child: Text('No detection history yet'),
                      );
                    }
                    
                    return HistoryList(
                      history: history,
                      onDelete: (item) async {
                        await ref.read(historyNotifierProvider.notifier)
                          .deleteResult(item);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Error loading history: ${error.toString()}',
                      style: TextStyle(color: AppColors.errorRed),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 