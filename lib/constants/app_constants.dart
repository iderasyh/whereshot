class AppConstants {
  // App metadata
  static const String appName = 'WhereShot';
  static const String appVersion = '1.0.0';
  
  // Storage keys
  static const String deviceIdKey = 'device_id';
  static const String creditsKey = 'credits';
  static const String defaultStorageModeKey = 'default_storage_mode';
  static const String historyKey = 'history';
  
  // Default values
  static const int defaultCredits = 0;
  static const bool defaultStorageMode = true; // true = save, false = temporary
  
  // Firebase collections
  static const String usersCollection = 'users';
  static const String detectionResultsCollection = 'detection_results';
  static const String photoStorage = 'photos';
  
  // API endpoints
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String openAIVisionEndpoint = '$openAIBaseUrl/chat/completions';
  
  // OpenAI model
  static const String openAIModelId = 'o3-2025-04-16';
  
  // RevenueCat product IDs
  static const String fiveCreditsId = 'whereshot_5_credits';
  static const String fifteenCreditsId = 'whereshot_15_credits';
  static const String fiftyCreditsId = 'whereshot_50_credits';
  
  // Credit values
  static const int fiveCreditsValue = 5;
  static const int fifteenCreditsValue = 15;
  static const int fiftyCreditsValue = 50;
  
  // Price per detection in dollars (for display purposes)
  static const double costPerImage = 0.02;
  
  // Credit pack prices (for display purposes)
  static const double fiveCreditsPrice = 1.99;
  static const double fifteenCreditsPrice = 4.49;
  static const double fiftyCreditsPrice = 11.99;
  
  // Image settings
  static const double maxImageWidth = 1024.0;
  static const double maxImageHeight = 1024.0;
  static const double imageQuality = 80.0;
  
  // Request settings
  static const int requestTimeout = 30000; // 30 seconds
  
  // Error messages
  static const String noCreditsError = 'No credits available. Please purchase credits to continue.';
  static const String locationDetectionError = 'Failed to detect location. Please try again.';
  static const String imageUploadError = 'Failed to upload image. Please try again.';
  static const String networkError = 'Network error. Please check your connection and try again.';
  static const String purchaseError = 'Failed to complete purchase. Please try again.';
  
  // Success messages
  static const String purchaseSuccess = 'Purchase completed successfully!';
  static const String locationDetectionSuccess = 'Location detected successfully!';
} 