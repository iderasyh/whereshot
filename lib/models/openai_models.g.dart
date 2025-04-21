// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAIRequest _$OpenAIRequestFromJson(Map<String, dynamic> json) =>
    OpenAIRequest(
      model: json['model'] as String,
      input:
          (json['input'] as List<dynamic>)
              .map((e) => OpenAIMessage.fromJson(e as Map<String, dynamic>))
              .toList(),
      text:
          json['text'] == null
              ? null
              : OpenAIStructuredText.fromJson(
                json['text'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$OpenAIRequestToJson(OpenAIRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'input': instance.input.map((e) => e.toJson()).toList(),
      if (instance.text?.toJson() case final value?) 'text': value,
    };

OpenAIMessage _$OpenAIMessageFromJson(Map<String, dynamic> json) =>
    OpenAIMessage(role: json['role'] as String, content: json['content']);

Map<String, dynamic> _$OpenAIMessageToJson(OpenAIMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      if (instance.content case final value?) 'content': value,
    };

OpenAIMessageContent _$OpenAIMessageContentFromJson(
  Map<String, dynamic> json,
) => OpenAIMessageContent(
  type: json['type'] as String,
  text: json['text'] as String?,
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$OpenAIMessageContentToJson(
  OpenAIMessageContent instance,
) => <String, dynamic>{
  'type': instance.type,
  if (instance.text case final value?) 'text': value,
  if (instance.imageUrl case final value?) 'image_url': value,
};

OpenAIStructuredText _$OpenAIStructuredTextFromJson(
  Map<String, dynamic> json,
) => OpenAIStructuredText(
  format: OpenAIFormat.fromJson(json['format'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OpenAIStructuredTextToJson(
  OpenAIStructuredText instance,
) => <String, dynamic>{'format': instance.format.toJson()};

OpenAIFormat _$OpenAIFormatFromJson(Map<String, dynamic> json) => OpenAIFormat(
  type: json['type'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  schema: json['schema'] as Map<String, dynamic>,
  strict: json['strict'] as bool?,
);

Map<String, dynamic> _$OpenAIFormatToJson(OpenAIFormat instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'description': instance.description,
      'schema': instance.schema,
      if (instance.strict case final value?) 'strict': value,
    };

OpenAIResponse _$OpenAIResponseFromJson(Map<String, dynamic> json) =>
    OpenAIResponse(
      id: json['id'] as String,
      model: json['model'] as String,
      createdAt: (json['created_at'] as num).toInt(),
      status: json['status'] as String,
      output:
          (json['output'] as List<dynamic>)
              .map((e) => OpenAIOutputItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      usage:
          json['usage'] == null
              ? null
              : OpenAIUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenAIResponseToJson(OpenAIResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'model': instance.model,
      'created_at': instance.createdAt,
      'status': instance.status,
      'output': instance.output.map((e) => e.toJson()).toList(),
      if (instance.usage?.toJson() case final value?) 'usage': value,
    };

OpenAIOutputItem _$OpenAIOutputItemFromJson(Map<String, dynamic> json) =>
    OpenAIOutputItem(
      type: json['type'] as String,
      id: json['id'] as String,
      status: json['status'] as String?,
      role: json['role'] as String?,
      content:
          (json['content'] as List<dynamic>?)
              ?.map(
                (e) => OpenAIOutputContent.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$OpenAIOutputItemToJson(OpenAIOutputItem instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      if (instance.status case final value?) 'status': value,
      if (instance.role case final value?) 'role': value,
      if (instance.content?.map((e) => e.toJson()).toList() case final value?)
        'content': value,
    };

OpenAIOutputContent _$OpenAIOutputContentFromJson(Map<String, dynamic> json) =>
    OpenAIOutputContent(
      type: json['type'] as String,
      text: json['text'] as String,
      annotations: json['annotations'] as List<dynamic>?,
    );

Map<String, dynamic> _$OpenAIOutputContentToJson(
  OpenAIOutputContent instance,
) => <String, dynamic>{
  'type': instance.type,
  'text': instance.text,
  if (instance.annotations case final value?) 'annotations': value,
};

OpenAIUsage _$OpenAIUsageFromJson(Map<String, dynamic> json) => OpenAIUsage(
  inputTokens: (json['input_tokens'] as num?)?.toInt(),
  outputTokens: (json['output_tokens'] as num?)?.toInt(),
  totalTokens: (json['total_tokens'] as num).toInt(),
);

Map<String, dynamic> _$OpenAIUsageToJson(OpenAIUsage instance) =>
    <String, dynamic>{
      if (instance.inputTokens case final value?) 'input_tokens': value,
      if (instance.outputTokens case final value?) 'output_tokens': value,
      'total_tokens': instance.totalTokens,
    };
