import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whereshot/services/firebase_service.dart';
import 'package:whereshot/services/openai_service.dart';
import 'package:whereshot/services/purchase_service.dart';
import 'package:whereshot/services/storage_service.dart';

import '../env.dart';

part 'service_providers.g.dart';

// Config providers
@riverpod
String revenueCatApiKey(Ref ref) {
  // In production, this should come from a secure source
  // For development purposes only
  const apiKey = String.fromEnvironment('REVENUECAT_API_KEY', defaultValue: '');
  return apiKey;
}

// Shared Preferences provider
// This provider must be overridden in the ProviderScope initialization
@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError('Shared preferences must be initialized before use');
}

// Service providers
@riverpod
StorageService storageService(Ref ref) {
  // Watch the generated provider
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return StorageService(sharedPreferences);
}

@riverpod
FirebaseService firebaseService(Ref ref) {
  return FirebaseService();
}

@riverpod
OpenAIService openAIService(Ref ref) {
  // Watch the generated provider
  return OpenAIService(apiKey: Env.openAIApiKey);
}

@riverpod
PurchaseService purchaseService(Ref ref) {
  // Watch the generated provider
  final apiKey = ref.watch(revenueCatApiKeyProvider);
  return PurchaseService(apiKey: apiKey);
}
