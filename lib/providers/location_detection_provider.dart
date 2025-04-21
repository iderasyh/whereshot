import 'dart:io';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:whereshot/constants/app_constants.dart';
import 'package:whereshot/models/detection_result.dart';
import 'package:whereshot/providers/service_providers.dart';
import 'package:whereshot/providers/user_provider.dart';

part 'location_detection_provider.g.dart';

@riverpod
class LocationDetectionNotifier extends _$LocationDetectionNotifier {
  @override
  Future<DetectionResult?> build() async {
    // Initialize with null - this provider will be populated when a detection is performed
    return null;
  }

  // Detect location from File
  Future<bool> detectLocationFromFile(
    File imageFile, {
    bool saveImage = true,
  }) async {
    state = const AsyncValue.loading();

    try {
      final openAIService = ref.read(openAIServiceProvider);
      final firebaseService = ref.read(firebaseServiceProvider);
      final storageService = ref.read(storageServiceProvider);
      final userNotifier = ref.read(userNotifierProvider.notifier);

      // Check if user has enough credits
      final hasCredits = await userNotifier.useCredits(1);
      if (!hasCredits) {
        state = AsyncValue.error(
          AppConstants.noCreditsError,
          StackTrace.current,
        );
        return state.hasError;
      }

      // Generate a unique ID for this detection
      final id = const Uuid().v4();
      final deviceId = await storageService.getDeviceId();

      // Call OpenAI API to analyze image
      final locationInfo = await openAIService.analyzeImageLocation(
        imageFile: imageFile,
      );

      String? imageUrl;
      // Upload image if saving is enabled
      if (saveImage) {
        imageUrl = await firebaseService.uploadImageFile(
          imageFile,
          deviceId,
          id,
        );
      }

      // Create detection result
      final result = DetectionResult(
        id: id,
        locationName: locationInfo.locationName,
        locationCity: locationInfo.locationCity,
        locationCountry: locationInfo.locationCountry,
        confidence: locationInfo.confidence,
        clues: locationInfo.clues,
        latitude: locationInfo.latitude,
        longitude: locationInfo.longitude,
        imageUrl: imageUrl,
        originalPrompt: locationInfo.rawContent,
        deviceId: deviceId,
        timestamp: DateTime.now(),
        saved: saveImage,
      );

      // Save result to Firestore if saving is enabled
      if (saveImage) {
        await firebaseService.saveDetectionResult(result);
      }

      // Save to local storage for history
      await storageService.saveDetectionResult(result);

      state = AsyncValue.data(result);
      return state.hasError;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return state.hasError;
    }
  }

  // Detect location from Uint8List
  Future<void> detectLocationFromBytes(
    Uint8List imageBytes, {
    bool saveImage = true,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Save bytes to temporary file
      final tempDir = await Directory.systemTemp.createTemp();
      final tempFile = File('${tempDir.path}/temp_image.jpg');
      await tempFile.writeAsBytes(imageBytes);

      // Use file-based detection
      await detectLocationFromFile(tempFile, saveImage: saveImage);

      // Clean up temp file
      await tempFile.delete();
      await tempDir.delete();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Save current detection result (convert temporary to saved)
  Future<void> saveCurrentResult() async {
    final currentResult = state.valueOrNull;
    if (currentResult == null || currentResult.saved) {
      return; // Already saved or no result
    }

    try {
      state = const AsyncValue.loading();

      final firebaseService = ref.read(firebaseServiceProvider);
      final storageService = ref.read(storageServiceProvider);
      final deviceId = await storageService.getDeviceId();

      // Get image bytes from wherever they're stored temporarily
      // This part depends on how you're handling temporary images

      // Upload to Firebase Storage
      final imageFile = File(currentResult.imageUrl ?? '');
      if (!await imageFile.exists()) {
        throw Exception('Temporary image no longer exists');
      }

      final imageUrl = await firebaseService.uploadImageFile(
        imageFile,
        deviceId,
        currentResult.id,
      );

      // Update result with saved status and image URL
      final updatedResult = currentResult.copyWith(
        saved: true,
        imageUrl: imageUrl,
      );

      // Save to Firestore
      await firebaseService.saveDetectionResult(updatedResult);

      // Update local storage
      await storageService.saveDetectionResult(updatedResult);

      state = AsyncValue.data(updatedResult);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Clear current result
  void clearResult() {
    state = const AsyncValue.data(null);
  }

  // Set a detection result (used when loading from history)
  void setDetectionResult(DetectionResult result) {
    state = AsyncValue.data(result);
  }
}
