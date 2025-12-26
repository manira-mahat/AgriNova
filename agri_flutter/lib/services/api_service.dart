import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Simple API Service
class ApiService {
  // Android emulator uses 10.0.2.2 to access host machine
  static const String baseUrl = "http://10.0.2.2:8000/api/";

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
    try {
      final token = await getToken();
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Token $token",
      };

      final response = await http.post(
        Uri.parse(baseUrl + endpoint),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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
      throw Exception("Error: $e");
    }
  }

  // GET request
  static Future<dynamic> get(String endpoint) async {
    try {
      final token = await getToken();
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Token $token",
      };

      final response = await http
          .get(Uri.parse(baseUrl + endpoint), headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check if the backend server is running.',
              );
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
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
    try {
      final token = await getToken();
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Token $token",
      };

      final response = await http.put(
        Uri.parse(baseUrl + endpoint),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // DELETE request
  static Future<dynamic> delete(String endpoint) async {
    try {
      final token = await getToken();
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Token $token",
      };

      final response = await http.delete(
        Uri.parse(baseUrl + endpoint),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
