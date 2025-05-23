import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:whereshot/constants/app_constants.dart';
import 'package:whereshot/models/openai_models.dart';

class OpenAIService {
  final Dio _dio;
  final String _apiKey;

  // Define the JSON schema for the location response
  static final Map<String, dynamic> _locationSchema = {
    "type": "object",
    "properties": {
      "locationName": {
        "type": "string",
        "description":
            "A descriptive name of the location (e.g., Eiffel Tower, or unknown if not identifiable).",
      },
      "locationCity": {
        "type": "string",
        "description": "The city of the location (e.g., Paris, or unknown if not identifiable).",
      },
      "locationCountry": {
        "type": "string",
        "description":
            "The country of the location (e.g., France, or unknown if not identifiable).",
      },
      "latitude": {
        "type": "number",
        "description": "The latitude of the location. If unknown, return 0.",
      },
      "longitude": {
        "type": "number",
        "description": "The longitude of the location. If unknown, return 0.",
      },
      "clues": {
        "type": "string",
        "description":
            "Explanation of the clues or reasoning that led to this location.",
      },
    },
    "required": [
      "locationName",
      "locationCity",
      "locationCountry",
      "latitude",
      "longitude",
      "clues",
    ],
    "additionalProperties": false,
  };

  OpenAIService({required String apiKey, Dio? dio})
    : _apiKey = apiKey,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.openAIBaseUrl,
              headers: {'Content-Type': 'application/json'},
            ),
          );

  // Initialize headers with API key
  Map<String, dynamic> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  };

  // Analyze image location using OpenAI API (using /v1/responses)
  Future<LocationInfo> analyzeImageLocation({
    required File imageFile,
    String? customPrompt, // Optional custom instructions for analysis
  }) async {
    try {
      final compressedImageBytes = await _resizeAndCompressImage(imageFile);
      final base64Image = base64Encode(compressedImageBytes);

      // Use the helper method to create the request
      final request = _createImageAnalysisRequest(base64Image, customPrompt);

      final response = await _sendRequest(request);

      // Use the helper method to extract structured info
      return extractLocationInfo(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error analyzing image: ${e.toString()}');
    }
  }

  // Analyze image location using a Uint8List (using /v1/responses)
  Future<LocationInfo> analyzeImageLocationFromBytes({
    required Uint8List imageBytes,
    String? customPrompt, // Optional custom instructions for analysis
  }) async {
    try {
      // No need to resize/compress if bytes are provided directly
      final base64Image = base64Encode(imageBytes);

      // Use the helper method to create the request
      final request = _createImageAnalysisRequest(base64Image, customPrompt);

      final response = await _sendRequest(request);

      // Use the helper method to extract structured info
      return extractLocationInfo(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error analyzing image bytes: ${e.toString()}');
    }
  }

  // Helper to create the image analysis request object
  OpenAIRequest _createImageAnalysisRequest(
    String base64Image,
    String? customPrompt,
  ) {
    final userPrompt =
        customPrompt ??
        "Analyze the provided image with maximum effort, using all your world knowledge, visual recognition, and reasoning skills. Identify the most likely real-world geographical location (city, landmark, country, or coordinates) depicted in the photo. Consider architectural styles, natural features, signage, language, climate, vegetation, and any other visual clues. If possible, provide the most precise location. Respond strictly according to the requested JSON schema.";

    return OpenAIRequest(
      model: AppConstants.openAIModelId,
      input: [
        OpenAIMessage(
          role: "system",
          content:
              "You are a world-class AI geolocation expert. Use all your advanced knowledge, reasoning, and visual analysis skills to identify the real-world location depicted in the user's photo. Leverage your understanding of geography, architecture, natural features, languages, signage, climate, and any other visual or contextual clues. Always provide the most precise and confident answer possible, and strictly respond using the requested JSON schema only.",
        ),
        OpenAIMessage(
          role: "user",
          content: [
            OpenAIMessageContent(type: "input_text", text: userPrompt),
            OpenAIMessageContent(
              type: "input_image",
              imageUrl: "data:image/jpeg;base64,$base64Image",
            ),
          ],
        ),
      ],
      // Request structured JSON output
      text: OpenAIStructuredText(
        format: OpenAIFormat(
          type: "json_schema",
          name: "location_info",
          description: "Geographical location identified from the image.",
          schema: _locationSchema,
          strict: true, // Enforce schema adherence
        ),
      ),
    );
  }

  // Helper to send the request to the API
  Future<OpenAIResponse> _sendRequest(OpenAIRequest request) async {
    final response = await _dio.post(
      // Use the /v1/responses endpoint
      AppConstants.openAIResponsesEndpoint,
      data: request.toJson(),
      options: Options(headers: _headers),
    );

    return OpenAIResponse.fromJson(response.data);
  }

  // Updated function to extract LocationInfo, finding the first 'message' output
  LocationInfo extractLocationInfo(OpenAIResponse response) {
    String rawJsonString = 'Error: Could not extract JSON content';
    try {
      // Find the first output item of type 'message'
      final messageOutput = response.output.firstWhere(
        (item) => item.type == 'message',
        orElse:
            () =>
                throw Exception('No output item with type \'message\' found.'),
      );

      // Check if the found message has content and if it's not empty
      if (messageOutput.content == null || messageOutput.content!.isEmpty) {
        throw Exception(
          ''
          'Found \'message\' output item, but its content is null or empty.',
        );
      }

      // Access the text from the first content item within the message
      // Assuming the first content item is the one holding the JSON string
      rawJsonString = messageOutput.content![0].text;

      // Attempt to parse the assumed JSON string
      Map<String, dynamic> jsonResponse = jsonDecode(rawJsonString);

      // Use the updated LocationInfo factory for parsing
      return LocationInfo.fromJson(jsonResponse, rawJsonString);
    } on FormatException catch (_) {
      return LocationInfo.error('Failed to parse location data', rawJsonString);
    } catch (e) {
      return LocationInfo.error(
        'Error processing OpenAI response: ${e.toString()}',
        rawJsonString,
      );
    }
  }

  // Helper method to handle Dio errors
  Exception _handleDioError(DioException e) {
    String errorMessage = 'OpenAI API error';
    if (e.response != null) {
      errorMessage += ': Status ${e.response?.statusCode}';
      final responseData = e.response?.data;
      if (responseData is Map && responseData.containsKey('error')) {
        errorMessage += ' - ${responseData['error']?['message']}';
      } else if (responseData is String && responseData.isNotEmpty) {
        errorMessage += ' - $responseData';
      }
    } else {
      errorMessage += ': ${e.message}';
    }

    if (e.response?.statusCode == 401) {
      return Exception('Invalid OpenAI API key.');
    }
    if (e.response?.statusCode == 429) {
      return Exception(
        'Rate limit exceeded or credits depleted. Please check your OpenAI account.',
      );
    }
    if (e.response?.statusCode == 400) {
      // Bad requests might include schema validation errors
      return Exception(
        'Invalid request to OpenAI (check parameters or schema): $errorMessage',
      );
    }

    return Exception(errorMessage); // General exception for other errors
  }

  // Helper method to resize and compress image (remains the same)
  Future<Uint8List> _resizeAndCompressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      int targetWidth = AppConstants.maxImageWidth.toInt();
      int targetHeight = AppConstants.maxImageHeight.toInt();
      double ratio = image.width / image.height;

      if (ratio > 1) {
        targetHeight = (targetWidth / ratio).round();
      } else {
        targetWidth = (targetHeight * ratio).round();
      }

      final resized = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
      );
      return Uint8List.fromList(
        img.encodeJpg(resized, quality: AppConstants.imageQuality.toInt()),
      );
    } catch (e) {
      return await imageFile.readAsBytes();
    }
  }
}
