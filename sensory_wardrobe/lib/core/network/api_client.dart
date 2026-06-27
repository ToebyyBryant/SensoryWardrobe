import 'dart:convert';
import 'package:http/http.dart' as http;

import '../error/app_exception.dart';

/// Base HTTP client wrapper.
/// All API calls (e.g., OpenWeatherMap) go through here.
class ApiClient {
  final http.Client _client;
  final String _baseUrl;

  ApiClient({required String baseUrl, http.Client? client})
      : _baseUrl = baseUrl,
        _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      uri,
      headers: {'Content-Type': 'application/json', ...?headers},
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json', ...?headers},
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException(decoded['message'] ?? 'Unauthorized');
      case 404:
        throw NotFoundException(decoded['message'] ?? 'Not found');
      default:
        throw ServerException(
          'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }

  void dispose() => _client.close();
}
