import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whereshot/services/auth_service.dart';
import 'package:whereshot/services/firebase_service.dart';
import 'package:whereshot/services/openai_service.dart';
import 'package:whereshot/services/storage_service.dart';

import '../env.dart';

part 'service_providers.g.dart';

// Shared Preferences provider
// This provider must be overridden in the ProviderScope initialization
@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError('Shared preferences must be initialized before use');
}

// Service providers
@riverpod
AuthService authService(Ref ref) {
  return AuthService();
}

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