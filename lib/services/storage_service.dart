import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whereshot/constants/app_constants.dart';
import 'package:whereshot/models/detection_result.dart';

class StorageService {
  final SharedPreferences _prefs;
  
  StorageService(this._prefs);

  
  // Get user credits
  int getCredits() {
    return _prefs.getInt(AppConstants.creditsKey) ?? AppConstants.defaultCredits;
  }
  
  // Set user credits
  Future<bool> setCredits(int credits) async {
    return await _prefs.setInt(AppConstants.creditsKey, credits);
  }
  
  // Add credits
  Future<bool> addCredits(int amount) async {
    final currentCredits = getCredits();
    return await setCredits(currentCredits + amount);
  }
  
  // Use credits (returns false if not enough)
  Future<bool> useCredits(int amount) async {
    final currentCredits = getCredits();
    
    if (currentCredits < amount) {
      return false;
    }
    
    return await setCredits(currentCredits - amount);
  }
  
  // Get default storage mode
  bool getDefaultStorageMode() {
    return _prefs.getBool(AppConstants.defaultStorageModeKey) ?? 
      AppConstants.defaultStorageMode;
  }
  
  // Set default storage mode
  Future<bool> setDefaultStorageMode(bool saveMode) async {
    return await _prefs.setBool(AppConstants.defaultStorageModeKey, saveMode);
  }
  
  // Toggle default storage mode
  Future<bool> toggleDefaultStorageMode() async {
    final currentMode = getDefaultStorageMode();
    return await setDefaultStorageMode(!currentMode);
  }
  
  // Save detection result to local history
  Future<bool> saveDetectionResult(DetectionResult result) async {
    final List<String> history = _prefs.getStringList(AppConstants.historyKey) ?? [];
    final resultJson = jsonEncode(result.toJson());
    
    // Add to beginning of list (most recent first)
    history.insert(0, resultJson);
    
    // Limit history size to prevent excessive storage use
    const int maxHistorySize = 100;
    if (history.length > maxHistorySize) {
      history.removeRange(maxHistorySize, history.length);
    }
    
    return await _prefs.setStringList(AppConstants.historyKey, history);
  }
  
  // Get detection history
  List<DetectionResult> getDetectionHistory() {
    final List<String> history = _prefs.getStringList(AppConstants.historyKey) ?? [];
    
    return history.map((jsonString) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return DetectionResult.fromJson(json);
    }).toList();
  }
  
  // Clear all detection history
  Future<bool> clearDetectionHistory() async {
    return await _prefs.remove(AppConstants.historyKey);
  }
  
  // Remove specific detection result from history
  Future<bool> removeDetectionResult(String id) async {
    final List<String> history = _prefs.getStringList(AppConstants.historyKey) ?? [];
    final List<String> updatedHistory = [];
    
    for (final jsonString in history) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      if (json['id'] != id) {
        updatedHistory.add(jsonString);
      }
    }
    
    return await _prefs.setStringList(AppConstants.historyKey, updatedHistory);
  }
} 