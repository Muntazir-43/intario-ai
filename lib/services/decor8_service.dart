import 'package:dio/dio.dart';
import 'package:intario_ai/config/api_config.dart';

class Decor8Service {
  final Dio dio;

  Decor8Service(this.dio);

  Future<String> generateImage({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl$endpoint',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type':  'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 401) {
        throw const Decor8Exception(
          code:    401,
          message: 'Service authentication failed.',
        );
      }

      if (response.statusCode == 400) {
        throw const Decor8Exception(
          code:    400,
          message: 'Please review your selected options and try again.',
        );
      }

      if (response.statusCode == 422) {
        throw const Decor8Exception(
          code:    422,
          message: 'Some inputs are invalid. Please check your image or selections.',
        );
      }

      if (response.statusCode != 200) {
        throw Decor8Exception(
          code:    response.statusCode ?? 0,
          message: 'An unexpected error occurred. Please try again.',
        );
      }

      final data = response.data;

      if (data == null) {
        throw const Decor8Exception(
          code: 0,
          message: 'No response data received. Please try again.',
        );
      }

      // Check for inline error message from the API
      final apiError = data['error']?.toString();
      final apiMessage = data['message']?.toString();

      // Extract image URL from multiple possible structures:
      String? url;

      if (data['info'] != null) {
        final info = data['info'];
        // 1. Direct url in info: info['url']
        if (info['url'] is String && (info['url'] as String).isNotEmpty) {
          url = info['url'] as String;
        }
        // 2. Direct image_url in info: info['image_url']
        else if (info['image_url'] is String && (info['image_url'] as String).isNotEmpty) {
          url = info['image_url'] as String;
        }
        // 3. Nested images array: info['images'][0]['url']
        else if (info['images'] is List && (info['images'] as List).isNotEmpty) {
          final firstImage = info['images'][0];
          if (firstImage is Map && firstImage['url'] is String && (firstImage['url'] as String).isNotEmpty) {
            url = firstImage['url'] as String;
          }
        }
      }

      // 4. Root level fallbacks
      if (url == null || url.isEmpty) {
        if (data['output_image_url'] is String && (data['output_image_url'] as String).isNotEmpty) {
          url = data['output_image_url'] as String;
        } else if (data['url'] is String && (data['url'] as String).isNotEmpty) {
          url = data['url'] as String;
        }
      }

      if (url == null || url.isEmpty) {
        // If an API-level error or message was returned, surface it
        if (apiError != null && apiError.trim().isNotEmpty) {
          throw Decor8Exception(
            code: 0,
            message: apiError.trim(),
          );
        }
        if (apiMessage != null &&
            apiMessage.trim().isNotEmpty &&
            !apiMessage.toLowerCase().contains('success')) {
          throw Decor8Exception(
            code: 0,
            message: apiMessage.trim(),
          );
        }
        throw const Decor8Exception(
          code: 0,
          message: 'No image was returned. Please try again.',
        );
      }

      return url;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const Decor8Exception(
          code:    -1,
          message: 'Connection timed out. Please check your internet and try again.',
          isTimeout: true,
        );
      }

      if (e.type == DioExceptionType.receiveTimeout) {
        throw const Decor8Exception(
          code:    -2,
          message: 'Generation is taking longer than usual. Please try again.',
          isTimeout: true,
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const Decor8Exception(
          code:    -3,
          message: 'No internet connection. Please check your network.',
          isNetworkError: true,
        );
      }

      throw const Decor8Exception(
        code:    -4,
        message: 'Something went wrong. Please try again.',
      );
    } on Decor8Exception {
      rethrow;
    } catch (e) {
      throw const Decor8Exception(
        code:    -5,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }
}

class Decor8Exception implements Exception {
  final int    code;
  final String message;
  final bool   isTimeout;
  final bool   isNetworkError;

  const Decor8Exception({
    required this.code,
    required this.message,
    this.isTimeout      = false,
    this.isNetworkError = false,
  });

  @override
  String toString() => 'Decor8Exception($code): $message';
}