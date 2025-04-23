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

  // Detect location from File - Updated with refund logic
  Future<bool> detectLocationFromFile(
    File imageFile, {
    bool saveImage = true,
  }) async {
    state = const AsyncValue.loading();
    final userNotifier = ref.read(userNotifierProvider.notifier);
    bool creditUsed = false; // Flag to track if credit was deducted

    try {
      // --- Step 1: Check and Use Credit ---
      final hasCredits = await userNotifier.useCredits(1);
      if (!hasCredits) {
        // If no credits, set error state and exit immediately
        state = AsyncValue.error(
          AppConstants.noCreditsError,
          StackTrace.current,
        );
        return state.hasError; // Exit early
      }
      creditUsed = true; // Mark credit as used

      // --- Step 2: Perform Detection & Saving (potential refund needed on error) ---
      try {
        final openAIService = ref.read(openAIServiceProvider);
        final firebaseService = ref.read(firebaseServiceProvider);
        final storageService = ref.read(storageServiceProvider);
        final authService = ref.read(authServiceProvider);

        final id = const Uuid().v4();
        final uid = authService.currentUser?.uid;
        if (uid == null) {
          // Should ideally not happen if credit check passed, but check anyway
          throw Exception(AppConstants.noUserError);
        }

        // Call OpenAI API
        final locationInfo = await openAIService.analyzeImageLocation(
          imageFile: imageFile,
        );

        // --- Step 3: Check for 'Unknown Location' ---
        if (locationInfo.locationName.toLowerCase() == 'unknown' ||
            locationInfo.locationName.toLowerCase() == 'unknown location') {
          // Refund credit
          await userNotifier.addCredits(1);
          creditUsed = false; // Mark credit as refunded
          // Set specific error state and exit
          state = AsyncValue.error(
            AppConstants.locationNotFoundRefund,
            StackTrace.current,
          );
          return state.hasError; // Exit, do not save
        }

        // --- Step 4: Save Result (if location found) ---
        String? imageUrl;
        if (saveImage) {
          imageUrl = await firebaseService.uploadImageFile(imageFile, uid, id);
        }

        final result = DetectionResult(
          id: id,
          locationName: locationInfo.locationName,
          locationCity: locationInfo.locationCity,
          locationCountry: locationInfo.locationCountry,
          clues: locationInfo.clues,
          latitude: locationInfo.latitude,
          longitude: locationInfo.longitude,
          imageUrl: imageUrl,
          originalPrompt: locationInfo.rawContent,
          uid: uid,
          timestamp: DateTime.now(),
          saved: saveImage,
        );

        // Save result to Firestore if saving is enabled
        if (saveImage) {
          await firebaseService.saveDetectionResult(result);
        }

        // Save to local storage for history
        await storageService.saveDetectionResult(result);

        state = AsyncValue.data(result); // Set success state

        return state.hasError;
      } catch (e, stack) {
        // --- Catch errors during detection/saving (after credit used) ---
        if (creditUsed) {
          await userNotifier.addCredits(1); // Refund credit
        }
        // Append refund suffix to the error message
        final errorMessage = e.toString() + AppConstants.creditRefundSuffix;
        state = AsyncValue.error(
          errorMessage,
          stack,
        ); // Set error state with refund info
        return state.hasError;
      }
    } catch (e, stack) {
      // --- Catch initial errors (e.g., credit check itself failed) ---
      // No refund needed here as credit wasn't successfully deducted
      state = AsyncValue.error(e, stack); // Set error state
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

      // Use file-based detection (now handles refund logic internally)
      await detectLocationFromFile(tempFile, saveImage: saveImage);

      // Clean up temp file
      await tempFile.delete();
      await tempDir.delete();
    } catch (e, stack) {
      // If detectLocationFromFile throws an error *before* setting state
      // (e.g., during initial credit check), catch it here.
      if (state is! AsyncError) {
        // Only set state if not already set by internal catch
        state = AsyncValue.error(e, stack);
      }
    } finally {
      // Ensure loading state is cleared if an error occurs *before* state is set
      if (state is AsyncLoading) {
        state = AsyncValue.error(
          'Detection process failed unexpectedly.',
          StackTrace.current,
        );
      }
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
      final authService = ref.read(authServiceProvider);
      final uid = authService.currentUser?.uid;
      if (uid == null) {
        state = AsyncValue.error(AppConstants.noUserError, StackTrace.current);
        throw Exception(AppConstants.noUserError);
      }
      // Get image bytes from wherever they're stored temporarily
      // This part depends on how you're handling temporary images

      // Upload to Firebase Storage
      final imageFile = File(currentResult.imageUrl ?? '');
      if (!await imageFile.exists()) {
        throw Exception('Temporary image no longer exists');
      }

      final imageUrl = await firebaseService.uploadImageFile(
        imageFile,
        uid,
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
