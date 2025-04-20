// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAIRequest _$OpenAIRequestFromJson(Map<String, dynamic> json) =>
    OpenAIRequest(
      model: json['model'] as String,
      messages:
          (json['messages'] as List<dynamic>)
              .map((e) => OpenAIMessage.fromJson(e as Map<String, dynamic>))
              .toList(),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: (json['maxTokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OpenAIRequestToJson(OpenAIRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'temperature': instance.temperature,
      'maxTokens': instance.maxTokens,
    };

OpenAIMessage _$OpenAIMessageFromJson(Map<String, dynamic> json) =>
    OpenAIMessage(role: json['role'] as String, content: json['content']);

Map<String, dynamic> _$OpenAIMessageToJson(OpenAIMessage instance) =>
    <String, dynamic>{'role': instance.role, 'content': instance.content};

OpenAIMessageContent _$OpenAIMessageContentFromJson(
  Map<String, dynamic> json,
) => OpenAIMessageContent(
  type: json['type'] as String,
  text: json['text'] as String?,
  imageUrl:
      json['image_url'] == null
          ? null
          : OpenAIImageUrl.fromJson(json['image_url'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OpenAIMessageContentToJson(
  OpenAIMessageContent instance,
) => <String, dynamic>{
  'type': instance.type,
  'text': instance.text,
  'image_url': instance.imageUrl?.toJson(),
};

OpenAIImageUrl _$OpenAIImageUrlFromJson(Map<String, dynamic> json) =>
    OpenAIImageUrl(url: json['url'] as String);

Map<String, dynamic> _$OpenAIImageUrlToJson(OpenAIImageUrl instance) =>
    <String, dynamic>{'url': instance.url};

OpenAIResponse _$OpenAIResponseFromJson(Map<String, dynamic> json) =>
    OpenAIResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: (json['created'] as num).toInt(),
      model: json['model'] as String,
      choices:
          (json['choices'] as List<dynamic>)
              .map((e) => OpenAIChoice.fromJson(e as Map<String, dynamic>))
              .toList(),
      usage: OpenAIUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenAIResponseToJson(OpenAIResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created': instance.created,
      'model': instance.model,
      'choices': instance.choices.map((e) => e.toJson()).toList(),
      'usage': instance.usage.toJson(),
    };

OpenAIChoice _$OpenAIChoiceFromJson(Map<String, dynamic> json) => OpenAIChoice(
  index: (json['index'] as num).toInt(),
  message: OpenAIMessage.fromJson(json['message'] as Map<String, dynamic>),
  finishReason: json['finish_reason'] as String,
);

Map<String, dynamic> _$OpenAIChoiceToJson(OpenAIChoice instance) =>
    <String, dynamic>{
      'index': instance.index,
      'message': instance.message.toJson(),
      'finish_reason': instance.finishReason,
    };

OpenAIUsage _$OpenAIUsageFromJson(Map<String, dynamic> json) => OpenAIUsage(
  promptTokens: (json['prompt_tokens'] as num).toInt(),
  completionTokens: (json['completion_tokens'] as num).toInt(),
  totalTokens: (json['total_tokens'] as num).toInt(),
);

Map<String, dynamic> _$OpenAIUsageToJson(OpenAIUsage instance) =>
    <String, dynamic>{
      'prompt_tokens': instance.promptTokens,
      'completion_tokens': instance.completionTokens,
      'total_tokens': instance.totalTokens,
    };
