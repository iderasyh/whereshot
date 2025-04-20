import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whereshot/constants/app_constants.dart';
import 'package:whereshot/models/detection_result.dart';
import 'package:whereshot/models/user.dart' as app_user;

class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  
  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _storage = storage ?? FirebaseStorage.instance;
  
  // User Operations
  
  // Get user document
  Future<app_user.User?> getUser(String deviceId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(deviceId)
          .get();
      
      if (docSnapshot.exists) {
        return app_user.User.fromFirestore(docSnapshot);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Create or update user
  Future<bool> saveUser(app_user.User user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.deviceId)
          .set(user.toFirestore());
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Create user if not exists
  Future<app_user.User> createUserIfNotExists(String deviceId) async {
    try {
      final user = await getUser(deviceId);
      
      if (user != null) {
        return user;
      }
      
      // Create new user
      final newUser = app_user.User(
        deviceId: deviceId,
        credits: AppConstants.defaultCredits,
        defaultSaveMode: AppConstants.defaultStorageMode,
        lastUpdated: DateTime.now(),
      );
      
      await saveUser(newUser);
      
      return newUser;
    } catch (e) {
      // Return default user if Firebase fails
      return app_user.User(
        deviceId: deviceId,
        credits: AppConstants.defaultCredits,
        defaultSaveMode: AppConstants.defaultStorageMode,
        lastUpdated: DateTime.now(),
      );
    }
  }
  
  // Update user credits
  Future<bool> updateUserCredits(String deviceId, int credits) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(deviceId)
          .update({
        'credits': credits,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Detection Results Operations
  
  // Save detection result
  Future<bool> saveDetectionResult(DetectionResult result) async {
    try {
      await _firestore
          .collection(AppConstants.detectionResultsCollection)
          .doc(result.id)
          .set(result.toFirestore());
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Get user's detection results
  Future<List<DetectionResult>> getUserDetectionResults(String deviceId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.detectionResultsCollection)
          .where('deviceId', isEqualTo: deviceId)
          .where('saved', isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => DetectionResult.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Delete detection result
  Future<bool> deleteDetectionResult(String resultId) async {
    try {
      await _firestore
          .collection(AppConstants.detectionResultsCollection)
          .doc(resultId)
          .delete();
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Storage Operations
  
  // Upload image file
  Future<String?> uploadImageFile(File file, String deviceId, String imageName) async {
    try {
      final storageRef = _storage
          .ref()
          .child(AppConstants.photoStorage)
          .child(deviceId)
          .child('$imageName.jpg');
      
      final uploadTask = await storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
  
  // Upload image bytes
  Future<String?> uploadImageBytes(Uint8List bytes, String deviceId, String imageName) async {
    try {
      final storageRef = _storage
          .ref()
          .child(AppConstants.photoStorage)
          .child(deviceId)
          .child('$imageName.jpg');
      
      final uploadTask = await storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
  
  // Delete image
  Future<bool> deleteImage(String deviceId, String imageName) async {
    try {
      await _storage
          .ref()
          .child(AppConstants.photoStorage)
          .child(deviceId)
          .child('$imageName.jpg')
          .delete();
      
      return true;
    } catch (e) {
      return false;
    }
  }
} 