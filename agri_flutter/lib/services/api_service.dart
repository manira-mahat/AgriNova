import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Simple API Service
class ApiService {
  // Android emulator uses 10.0.2.2 to access host machine
  static const String baseUrl = "http://10.0.2.2:8000/api/";

  static void _logRequest(
    String method,
    Uri url,
    Map<String, String> headers,
    dynamic body,
  ) {
    if (!kDebugMode) return;
    debugPrint('[API] Request: $method $url');
    debugPrint('[API] Headers: $headers');
    if (body != null) {
      try {
        debugPrint('[API] Body: ${const JsonEncoder.withIndent('  ').convert(body)}');
      } catch (_) {
        debugPrint('[API] Body: $body');
      }
    }
  }

  static void _logResponse(
    String method,
    Uri url,
    http.Response response,
    int elapsedMs,
    bool isSuccess,
  ) {
    if (!kDebugMode) return;
    final statusLabel = isSuccess ? 'OK' : 'FAIL';
    debugPrint(
      '[API] Response[$statusLabel]: $method $url | Status: ${response.statusCode} | Time: ${elapsedMs}ms',
    );
    try {
      final decoded = jsonDecode(response.body);
      debugPrint(
        '[API] Response Body: ${const JsonEncoder.withIndent('  ').convert(decoded)}',
      );
    } catch (_) {
      debugPrint('[API] Response Body: ${response.body}');
    }
  }

  static void _logError(String method, Uri url, Object error, int elapsedMs) {
    if (!kDebugMode) return;
    debugPrint('[API] Error: $method $url | Time: ${elapsedMs}ms | $error');
  }

  // Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Remove token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // POST request
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final token = await getToken();
      final url = Uri.parse(baseUrl + endpoint);
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Token $token",
      };

      _logRequest('POST', url, headers, data);

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      stopwatch.stop();
      final isSuccess = response.statusCode == 200 || response.statusCode == 201;

      _logResponse(
        'POST',
        url,
        response,
        stopwatch.elapsedMilliseconds,
        isSuccess,
      );

      if (isSuccess) {
        return jsonDecode(response.body);
      } else {
        // Try to parse error response as JSON
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(jsonEncode(errorData));
        } catch (_) {
          throw Exception(response.body);
        }
      }
    } catch (e) {
      if (stopwatch.isRunning) stopwatch.stop();
      _logError(
        'POST',
        Uri.parse(baseUrl + endpoint),
        e,
        stopwatch.elapsedMilliseconds,
      );
      throw Exception("Error: $e");
    }
  }

  // GET request
  static Future<dynamic> get(String endpoint) async {
    final stopwatch = Stopwatch()..start();
    try {
      final token = await getToken();
      final url = Uri.parse(baseUrl + endpoint);
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Token $token",
      };

      _logRequest('GET', url, headers, null);

      final response = await http
          .get(url, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check if the backend server is running.',
              );
            },
          );
      stopwatch.stop();
      final isSuccess = response.statusCode == 200;

      _logResponse(
        'GET',
        url,
        response,
        stopwatch.elapsedMilliseconds,
        isSuccess,
      );

      if (isSuccess) {
        return jsonDecode(response.body);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (stopwatch.isRunning) stopwatch.stop();
      _logError(
        'GET',
        Uri.parse(baseUrl + endpoint),
        e,
        stopwatch.elapsedMilliseconds,
      );
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
          "Cannot connect to server. Please ensure Django backend is running.",
        );
      }
      throw Exception("Error: $e");
    }
  } // PUT request

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final stopwatch = Stopwatch()..start();
    try {
      final token = await getToken();
      final url = Uri.parse(baseUrl + endpoint);
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Token $token",
      };

      _logRequest('PUT', url, headers, data);

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      stopwatch.stop();
      final isSuccess = response.statusCode == 200;

      _logResponse(
        'PUT',
        url,
        response,
        stopwatch.elapsedMilliseconds,
        isSuccess,
      );

      if (isSuccess) {
        return jsonDecode(response.body);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (stopwatch.isRunning) stopwatch.stop();
      _logError(
        'PUT',
        Uri.parse(baseUrl + endpoint),
        e,
        stopwatch.elapsedMilliseconds,
      );
      throw Exception("Error: $e");
    }
  }

  // DELETE request
  static Future<dynamic> delete(String endpoint) async {
    final stopwatch = Stopwatch()..start();
    try {
      final token = await getToken();
      final url = Uri.parse(baseUrl + endpoint);
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Token $token",
      };

      _logRequest('DELETE', url, headers, null);

      final response = await http.delete(
        url,
        headers: headers,
      );
      stopwatch.stop();
      final isSuccess = response.statusCode == 200 || response.statusCode == 204;

      _logResponse(
        'DELETE',
        url,
        response,
        stopwatch.elapsedMilliseconds,
        isSuccess,
      );

      if (isSuccess) {
        return true;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (stopwatch.isRunning) stopwatch.stop();
      _logError(
        'DELETE',
        Uri.parse(baseUrl + endpoint),
        e,
        stopwatch.elapsedMilliseconds,
      );
      throw Exception("Error: $e");
    }
  }
}
