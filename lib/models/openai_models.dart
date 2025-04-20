import 'package:json_annotation/json_annotation.dart';

part 'openai_models.g.dart';

@JsonSerializable(explicitToJson: true)
class OpenAIRequest {
  final String model;
  final List<OpenAIMessage> messages;
  final double? temperature;
  final int? maxTokens;

  OpenAIRequest({
    required this.model,
    required this.messages,
    this.temperature = 0.7,
    this.maxTokens,
  });

  factory OpenAIRequest.fromJson(Map<String, dynamic> json) => 
      _$OpenAIRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIRequestToJson(this);

  // Create a request for image analysis
  factory OpenAIRequest.forImageAnalysis({
    required String model,
    required String base64Image,
    String prompt = "Analyze this image and tell me where it was taken. If you can identify the location, provide both a name and coordinates if possible. If you cannot determine the location, say so clearly.",
    double? temperature,
    int? maxTokens,
  }) {
    return OpenAIRequest(
      model: model,
      messages: [
        OpenAIMessage(
          role: "system",
          content: "You are a helpful AI assistant specialized in identifying locations from photos. When analyzing an image, try to identify specific locations if possible. If coordinates are identifiable, include them in the format 'latitude, longitude'. If a location cannot be identified, clearly state that.",
        ),
        OpenAIMessage(
          role: "user",
          content: [
            OpenAIMessageContent(
              type: "text",
              text: prompt,
            ),
            OpenAIMessageContent(
              type: "image_url",
              imageUrl: OpenAIImageUrl(
                url: "data:image/jpeg;base64,$base64Image",
              ),
            ),
          ],
        ),
      ],
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class OpenAIMessage {
  final String role;
  final dynamic content;

  OpenAIMessage({
    required this.role,
    required this.content,
  });

  factory OpenAIMessage.fromJson(Map<String, dynamic> json) => 
      _$OpenAIMessageFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIMessageToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OpenAIMessageContent {
  final String type;
  final String? text;
  
  @JsonKey(name: 'image_url')
  final OpenAIImageUrl? imageUrl;

  OpenAIMessageContent({
    required this.type,
    this.text,
    this.imageUrl,
  });

  factory OpenAIMessageContent.fromJson(Map<String, dynamic> json) => 
      _$OpenAIMessageContentFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIMessageContentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OpenAIImageUrl {
  final String url;

  OpenAIImageUrl({
    required this.url,
  });

  factory OpenAIImageUrl.fromJson(Map<String, dynamic> json) => 
      _$OpenAIImageUrlFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIImageUrlToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OpenAIResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<OpenAIChoice> choices;
  final OpenAIUsage usage;

  OpenAIResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory OpenAIResponse.fromJson(Map<String, dynamic> json) => 
      _$OpenAIResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OpenAIChoice {
  final int index;
  final OpenAIMessage message;
  
  @JsonKey(name: 'finish_reason')
  final String finishReason;

  OpenAIChoice({
    required this.index,
    required this.message,
    required this.finishReason,
  });

  factory OpenAIChoice.fromJson(Map<String, dynamic> json) => 
      _$OpenAIChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIChoiceToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OpenAIUsage {
  @JsonKey(name: 'prompt_tokens')
  final int promptTokens;
  
  @JsonKey(name: 'completion_tokens')
  final int completionTokens;
  
  @JsonKey(name: 'total_tokens')
  final int totalTokens;

  OpenAIUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory OpenAIUsage.fromJson(Map<String, dynamic> json) => 
      _$OpenAIUsageFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIUsageToJson(this);
} 