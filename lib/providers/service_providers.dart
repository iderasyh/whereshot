import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whereshot/services/firebase_service.dart';
import 'package:whereshot/services/openai_service.dart';
import 'package:whereshot/services/purchase_service.dart';
import 'package:whereshot/services/storage_service.dart';

// Config providers
final openAIApiKeyProvider = Provider<String>((ref) {
  // In production, this should come from a secure source
  // For development purposes only
  const apiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  return apiKey;
});

final revenueCatApiKeyProvider = Provider<String>((ref) {
  // In production, this should come from a secure source
  // For development purposes only
  const apiKey = String.fromEnvironment('REVENUECAT_API_KEY', defaultValue: '');
  return apiKey;
});

// Shared Preferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Shared preferences must be initialized before use');
});

// Service providers
final storageServiceProvider = Provider<StorageService>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return StorageService(sharedPreferences);
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  final apiKey = ref.watch(openAIApiKeyProvider);
  return OpenAIService(apiKey: apiKey);
});

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final apiKey = ref.watch(revenueCatApiKeyProvider);
  return PurchaseService(apiKey: apiKey);
}); 