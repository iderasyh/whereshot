import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String deviceId;
  final int credits;
  final bool defaultSaveMode;
  final DateTime lastUpdated;

  User({
    required this.deviceId,
    required this.credits,
    required this.defaultSaveMode,
    required this.lastUpdated,
  });

  // Create from Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      deviceId: doc.id,
      credits: data['credits'] as int,
      defaultSaveMode: data['defaultSaveMode'] as bool,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'credits': credits,
      'defaultSaveMode': defaultSaveMode,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  // Create copy with updated fields
  User copyWith({
    String? deviceId,
    int? credits,
    bool? defaultSaveMode,
    DateTime? lastUpdated,
  }) {
    return User(
      deviceId: deviceId ?? this.deviceId,
      credits: credits ?? this.credits,
      defaultSaveMode: defaultSaveMode ?? this.defaultSaveMode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Add credits
  User addCredits(int amount) {
    return copyWith(
      credits: credits + amount,
      lastUpdated: DateTime.now(),
    );
  }

  // Use credits (returns null if not enough credits)
  User? useCredits(int amount) {
    if (credits < amount) {
      return null;
    }
    return copyWith(
      credits: credits - amount,
      lastUpdated: DateTime.now(),
    );
  }

  // Toggle default save mode
  User toggleDefaultSaveMode() {
    return copyWith(
      defaultSaveMode: !defaultSaveMode,
      lastUpdated: DateTime.now(),
    );
  }
} 