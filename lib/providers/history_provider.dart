import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:whereshot/models/detection_result.dart';
import 'package:whereshot/providers/service_providers.dart';

part 'history_provider.g.dart';

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  @override
  Future<List<DetectionResult>> build() async {
    final storageService = ref.watch(storageServiceProvider);
    final firebaseService = ref.watch(firebaseServiceProvider);
    
    try {
      // Get device ID
      final deviceId = await storageService.getDeviceId();
      
      // Try to get history from Firebase first
      final firebaseResults = await firebaseService.getUserDetectionResults(deviceId);
      
      if (firebaseResults.isNotEmpty) {
        // Merge with local history - give priority to Firebase results
        final localResults = storageService.getDetectionHistory();
        
        // Create a map for easy lookup of Firebase results by ID
        final firebaseResultsMap = {
          for (var result in firebaseResults) result.id: result
        };
        
        // Add local results that don't exist in Firebase
        for (var localResult in localResults) {
          if (!firebaseResultsMap.containsKey(localResult.id)) {
            firebaseResults.add(localResult);
          }
        }
        
        // Sort by timestamp (newest first)
        firebaseResults.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        return firebaseResults;
      }
      
      // Fallback to local history if Firebase is empty
      return storageService.getDetectionHistory();
    } catch (e) {
      // Fallback to local history if Firebase fails
      return storageService.getDetectionHistory();
    }
  }
  
  // Delete a detection result
  Future<void> deleteResult(DetectionResult result) async {
    state = const AsyncValue.loading();
    
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final storageService = ref.read(storageServiceProvider);
      
      // Delete from Firestore if saved
      if (result.saved) {
        await firebaseService.deleteDetectionResult(result.id);
        
        // Delete image if exists
        if (result.imageUrl != null) {
          await firebaseService.deleteImage(
            result.deviceId,
            result.id,
          );
        }
      }
      
      // Delete from local storage
      await storageService.removeDetectionResult(result.id);
      
      // Refresh the history
      state = await AsyncValue.guard(() async {
        return build();
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  // Clear all history
  Future<void> clearHistory() async {
    state = const AsyncValue.loading();
    
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final storageService = ref.read(storageServiceProvider);
      final deviceId = await storageService.getDeviceId();
      
      // Get all saved results
      final results = await firebaseService.getUserDetectionResults(deviceId);
      
      // Delete each result from Firestore and Storage
      for (final result in results) {
        await firebaseService.deleteDetectionResult(result.id);
        
        if (result.imageUrl != null) {
          await firebaseService.deleteImage(
            result.deviceId,
            result.id,
          );
        }
      }
      
      // Clear local storage
      await storageService.clearDetectionHistory();
      
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  // Add a result to history
  Future<void> addResult(DetectionResult result) async {
    try {
      final currentResults = state.valueOrNull ?? [];
      final updatedResults = [result, ...currentResults];
      
      // Sort by timestamp (newest first)
      updatedResults.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      state = AsyncValue.data(updatedResults);
      
      final storageService = ref.read(storageServiceProvider);
      await storageService.saveDetectionResult(result);
      
      if (result.saved) {
        final firebaseService = ref.read(firebaseServiceProvider);
        await firebaseService.saveDetectionResult(result);
      }
    } catch (e, stack) {
      // Do not update state on error to preserve existing history
      // Just log the error
      print('Error adding result to history: $e');
    }
  }
} 