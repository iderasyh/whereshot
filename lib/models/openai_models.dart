import 'package:json_annotation/json_annotation.dart';

part 'openai_models.g.dart';

// --- Request Models ---

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenAIRequest {
  final String model;
  final List<OpenAIMessage> input;

  // For structured output (JSON schema)
  final OpenAIStructuredText? text;

  // Removed temperature and maxTokens, control via model/prompt or potentially other params if needed

  OpenAIRequest({required this.model, required this.input, this.text});

  factory OpenAIRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAIRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIRequestToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenAIMessage {
  final String role;

  // Content can be a simple string or a list of content blocks (text/image)
  final dynamic content; // String or List<OpenAIMessageContent>

  OpenAIMessage({required this.role, required this.content});

  factory OpenAIMessage.fromJson(Map<String, dynamic> json) {
    // Handle dynamic content type during deserialization
    var content = json['content'];
    if (content is String) {
      // Keep it as String
    } else if (content is List) {
      content =
          content
              .map(
                (item) =>
                    OpenAIMessageContent.fromJson(item as Map<String, dynamic>),
              )
              .toList();
    }
    // Override the content field in the map before passing to generated factory
    json['content'] = content;
    return _$OpenAIMessageFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OpenAIMessageToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenAIMessageContent {
  final String type; // "input_text" or "input_image"
  final String? text;

  @JsonKey(name: 'image_url')
  final String? imageUrl; // Direct URL string

  OpenAIMessageContent({required this.type, this.text, this.imageUrl})
    : assert(
        (type == 'input_text' && text != null && imageUrl == null) ||
            (type == 'input_image' && imageUrl != null && text == null),
        'Either text or imageUrl must be provided based on type.',
      );

  factory OpenAIMessageContent.fromJson(Map<String, dynamic> json) =>
      _$OpenAIMessageContentFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIMessageContentToJson(this);
}

// --- Structured Output Models ---

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenAIStructuredText {
  final OpenAIFormat format;

  OpenAIStructuredText({required this.format});

  factory OpenAIStructuredText.fromJson(Map<String, dynamic> json) =>
      _$OpenAIStructuredTextFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIStructuredTextToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenAIFormat {
  final String type; // "json_schema"
  final String name;
  final String description;
  final Map<String, dynamic> schema; // JSON schema definition
  final bool? strict;

  OpenAIFormat({
    required this.type,
    required this.name,
    required this.description,
    required this.schema,
    this.strict,
  });

  factory OpenAIFormat.fromJson(Map<String, dynamic> json) =>
      _$OpenAIFormatFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIFormatToJson(this);
}

// --- Updated Response Models ---

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenAIResponse {
  final String id;
  final String model;
  @JsonKey(name: 'created_at') // Updated field name
  final int createdAt;
  final String status;
  final List<OpenAIOutputItem> output; // Changed type
  final OpenAIUsage? usage;
  // Add other fields from example if needed (error, etc.)

  OpenAIResponse({
    required this.id,
    required this.model,
    required this.createdAt,
    required this.status,
    required this.output,
    this.usage,
  });

  factory OpenAIResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenAIResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIResponseToJson(this);
}

// New model for items within the 'output' array
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenAIOutputItem {
  final String type; // e.g., "message"
  final String id;
  final String? status; // Made nullable
  final String? role; // Made nullable
  final List<OpenAIOutputContent>? content; // Made nullable

  OpenAIOutputItem({
    required this.type,
    required this.id,
    this.status, // Updated constructor
    this.role, // Updated constructor
    this.content, // Updated constructor
  });

  factory OpenAIOutputItem.fromJson(Map<String, dynamic> json) =>
      _$OpenAIOutputItemFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIOutputItemToJson(this);
}

// New model for items within the 'content' array inside 'output'
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenAIOutputContent {
  final String type; // e.g., "output_text"
  final String text;
  final List<dynamic>? annotations; // Optional annotations

  OpenAIOutputContent({
    required this.type,
    required this.text,
    this.annotations,
  });

  factory OpenAIOutputContent.fromJson(Map<String, dynamic> json) =>
      _$OpenAIOutputContentFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIOutputContentToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OpenAIUsage {
  @JsonKey(name: 'input_tokens')
  final int? inputTokens;
  @JsonKey(name: 'output_tokens')
  final int? outputTokens;
  @JsonKey(name: 'total_tokens')
  final int totalTokens;
  // Add usage details if needed

  OpenAIUsage({this.inputTokens, this.outputTokens, required this.totalTokens});

  factory OpenAIUsage.fromJson(Map<String, dynamic> json) =>
      _$OpenAIUsageFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIUsageToJson(this);
}

// --- Location Info Model (Helper) ---
// Model to represent the parsed JSON data from the AI response
class LocationInfo {
  final String locationName;
  final String locationCity;
  final String locationCountry;
  final double confidence;
  final String clues;
  final double? latitude;
  final double? longitude;
  final String rawContent; // Keep the original string response

  LocationInfo({
    required this.locationName,
    required this.locationCity,
    required this.locationCountry,
    required this.confidence,
    required this.clues,
    this.latitude,
    this.longitude,
    required this.rawContent,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json, String rawContent) {
    return LocationInfo(
      locationName: json['locationName'] as String? ?? 'Unknown location',
      locationCity: json['locationCity'] as String? ?? 'Unknown city',
      locationCountry: json['locationCountry'] as String? ?? 'Unknown country',
      confidence:
          json['confidence'] is double
              ? json['confidence'] as double
              : double.parse(json['confidence'].toString()),
      clues: json['clues'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rawContent: rawContent,
    );
  }

  factory LocationInfo.error(String message, String rawContent) {
    return LocationInfo(
      locationName: message,
      locationCity: 'Error',
      locationCountry: 'Error',
      confidence: 0,
      clues: 'Error',
      latitude: null,
      longitude: null,
      rawContent: rawContent,
    );
  }
}
