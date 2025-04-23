// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetectionResult _$DetectionResultFromJson(Map<String, dynamic> json) =>
    DetectionResult(
      id: json['id'] as String,
      locationName: json['locationName'] as String,
      locationCity: json['locationCity'] as String,
      locationCountry: json['locationCountry'] as String,
      clues: json['clues'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      originalPrompt: json['originalPrompt'] as String?,
      uid: json['uid'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      saved: json['saved'] as bool,
    );

Map<String, dynamic> _$DetectionResultToJson(DetectionResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'locationName': instance.locationName,
      'locationCity': instance.locationCity,
      'locationCountry': instance.locationCountry,
      'clues': instance.clues,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'imageUrl': instance.imageUrl,
      'originalPrompt': instance.originalPrompt,
      'uid': instance.uid,
      'timestamp': instance.timestamp.toIso8601String(),
      'saved': instance.saved,
    };
