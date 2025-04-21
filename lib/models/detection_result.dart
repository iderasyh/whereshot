import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'detection_result.g.dart';

@JsonSerializable(explicitToJson: true)
class DetectionResult {
  final String id;
  final String locationName;
  final String locationCity;
  final String locationCountry;
  final double confidence;
  final String clues;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final String? originalPrompt;
  final String deviceId;
  final DateTime timestamp;
  final bool saved;

  DetectionResult({
    required this.id,
    required this.locationName,
    required this.locationCity,
    required this.locationCountry,
    required this.confidence,
    required this.clues,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.originalPrompt,
    required this.deviceId,
    required this.timestamp,
    required this.saved,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) => 
      _$DetectionResultFromJson(json);

  Map<String, dynamic> toJson() => _$DetectionResultToJson(this);

  // Convert Firestore timestamp to DateTime
  factory DetectionResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DetectionResult(
      id: doc.id,
      locationName: data['locationName'] as String,
      locationCity: data['locationCity'] as String,
      locationCountry: data['locationCountry'] as String,
      confidence: data['confidence'] is double
          ? data['confidence'] as double
          : double.parse(data['confidence'].toString()),
      clues: data['clues'] as String,
      latitude: data['latitude'] as double?,
      longitude: data['longitude'] as double?,
      imageUrl: data['imageUrl'] as String?,
      originalPrompt: data['originalPrompt'] as String?,
      deviceId: data['deviceId'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      saved: data['saved'] as bool,
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'locationName': locationName,
      'locationCity': locationCity,
      'locationCountry': locationCountry,
      'confidence': confidence,
      'clues': clues,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'originalPrompt': originalPrompt,
      'deviceId': deviceId,
      'timestamp': Timestamp.fromDate(timestamp),
      'saved': saved,
    };
  }

  // Check if has coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  // Create a copy with updated fields
  DetectionResult copyWith({
    String? id,
    String? locationName,
    String? locationCity,
    String? locationCountry,
    double? confidence,
    String? clues,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? originalPrompt,
    String? deviceId,
    DateTime? timestamp,
    bool? saved,
  }) {
    return DetectionResult(
      id: id ?? this.id,
      locationName: locationName ?? this.locationName,
      locationCity: locationCity ?? this.locationCity,
      locationCountry: locationCountry ?? this.locationCountry,
      confidence: confidence ?? this.confidence,
      clues: clues ?? this.clues,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      originalPrompt: originalPrompt ?? this.originalPrompt,
      deviceId: deviceId ?? this.deviceId,
      timestamp: timestamp ?? this.timestamp,
      saved: saved ?? this.saved,
    );
  }
} 