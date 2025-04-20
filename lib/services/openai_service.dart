import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:whereshot/constants/app_constants.dart';
import 'package:whereshot/models/openai_models.dart';

class OpenAIService {
  final Dio _dio;
  final String _apiKey;
  
  OpenAIService({
    required String apiKey,
    Dio? dio,
  }) : 
    _apiKey = apiKey,
    _dio = dio ?? Dio(BaseOptions(
      baseUrl: AppConstants.openAIBaseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.requestTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.requestTimeout),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  
  // Initialize headers with API key
  Map<String, dynamic> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  };
  
  // Analyze image location using OpenAI API
  Future<OpenAIResponse> analyzeImageLocation({
    required File imageFile,
    String? prompt,
  }) async {
    try {
      // Resize and compress image to reduce payload size
      final compressedImageBytes = await _resizeAndCompressImage(imageFile);
      final base64Image = base64Encode(compressedImageBytes);
      
      // Create request
      final request = OpenAIRequest.forImageAnalysis(
        model: AppConstants.openAIModelId,
        base64Image: base64Image,
        prompt: prompt ?? "Analyze this image and tell me where it was taken. If you can identify the location, provide both a name and coordinates if possible. If you cannot determine the location, say so clearly.",
        temperature: 0.7,
      );
      
      // Send request to OpenAI API
      final response = await _dio.post(
        AppConstants.openAIVisionEndpoint,
        data: request.toJson(),
        options: Options(headers: _headers),
      );
      
      // Parse response
      return OpenAIResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('OpenAI API error: ${e.message}');
    } catch (e) {
      throw Exception('Error analyzing image: $e');
    }
  }
  
  // Analyze image location using a Uint8List
  Future<OpenAIResponse> analyzeImageLocationFromBytes({
    required Uint8List imageBytes,
    String? prompt,
  }) async {
    try {
      // Save bytes to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image.jpg');
      await tempFile.writeAsBytes(imageBytes);
      
      // Analyze using file
      return await analyzeImageLocation(
        imageFile: tempFile,
        prompt: prompt,
      );
    } catch (e) {
      throw Exception('Error analyzing image bytes: $e');
    }
  }
  
  // Extract location information from OpenAI response
  Map<String, dynamic> extractLocationInfo(OpenAIResponse response) {
    try {
      final content = response.choices.first.message.content as String;
      
      // Default values
      String locationName = "Unknown location";
      double? latitude;
      double? longitude;
      
      // Extract location name - usually the first sentence or part
      final nameParts = content.split('.');
      if (nameParts.isNotEmpty) {
        locationName = nameParts.first.trim();
      }
      
      // Look for coordinates in the format "latitude, longitude" or "lat: X, long: Y"
      final regex = RegExp(r'(\-?\d+\.?\d*),\s*(\-?\d+\.?\d*)');
      final matches = regex.allMatches(content);
      
      if (matches.isNotEmpty) {
        final match = matches.first;
        latitude = double.tryParse(match.group(1) ?? "");
        longitude = double.tryParse(match.group(2) ?? "");
      }
      
      // Return extracted information
      return {
        'locationName': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'rawContent': content,
      };
    } catch (e) {
      return {
        'locationName': 'Error extracting location',
        'rawContent': response.choices.first.message.content,
      };
    }
  }
  
  // Helper method to resize and compress image
  Future<Uint8List> _resizeAndCompressImage(File imageFile) async {
    try {
      // Decode image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Get target dimensions while maintaining aspect ratio
      int targetWidth = AppConstants.maxImageWidth.toInt();
      int targetHeight = AppConstants.maxImageHeight.toInt();
      
      double ratio = image.width / image.height;
      
      if (ratio > 1) {
        // Landscape
        targetHeight = (targetWidth / ratio).round();
      } else {
        // Portrait
        targetWidth = (targetHeight * ratio).round();
      }
      
      // Resize image
      final resized = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
      );
      
      // Encode as JPEG with quality
      return Uint8List.fromList(img.encodeJpg(
        resized,
        quality: AppConstants.imageQuality.toInt(),
      ));
    } catch (e) {
      // If resizing fails, just read and return the original image bytes
      return await imageFile.readAsBytes();
    }
  }
} 