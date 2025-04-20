// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetectionResult _$DetectionResultFromJson(Map<String, dynamic> json) =>
    DetectionResult(
      id: json['id'] as String,
      locationName: json['locationName'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      originalPrompt: json['originalPrompt'] as String?,
      deviceId: json['deviceId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      saved: json['saved'] as bool,
    );

Map<String, dynamic> _$DetectionResultToJson(DetectionResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'locationName': instance.locationName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'imageUrl': instance.imageUrl,
      'originalPrompt': instance.originalPrompt,
      'deviceId': instance.deviceId,
      'timestamp': instance.timestamp.toIso8601String(),
      'saved': instance.saved,
    };
