import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

// Simple Auth Provider
class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAuthenticated => _user != null;

  // Check if user is already authenticated
  Future<void> checkAuthStatus() async {
    try {
      final token = await ApiService.getToken();
      if (token != null && token.isNotEmpty) {
        // Try to load user profile
        _user = await AuthService.getProfile();
      }
    } catch (e) {
      // Token is invalid or expired
      _user = null;
      await ApiService.removeToken();
    }
  }

  // Register new user
  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.register(data);

      // Check if response has required fields
      if (response['token'] == null || response['user'] == null) {
        _error =
            response['error']?.toString() ??
            'Registration failed - Invalid response from server';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final token = response['token'] as String;
      _user = User.fromJson(response['user'] as Map<String, dynamic>);
      await ApiService.saveToken(token);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Parse error message from JSON or string
  String _parseErrorMessage(String errorMsg) {
    // Remove Exception wrapper if present
    errorMsg = errorMsg.replaceFirst('Exception: ', '');
    if (errorMsg.startsWith('Error: Exception:')) {
      errorMsg = errorMsg.replaceFirst('Error: Exception: ', '');
    }

    final lower = errorMsg.toLowerCase();
    if (lower.contains('<!doctype html') ||
        lower.contains('<html') ||
        lower.contains('<title>not found</title>')) {
      return 'Connected to a non-API server. Please ensure AgriNova backend is running on port 8000.';
    }

    // Try to parse as JSON
    try {
      final jsonData = jsonDecode(errorMsg);
      if (jsonData is Map<String, dynamic>) {
        // Extract error messages from field errors
        List<String> errors = [];
        jsonData.forEach((key, value) {
          if (value is List) {
            for (var msg in value) {
              errors.add(msg.toString());
            }
          } else if (value is String) {
            errors.add(value);
          } else if (value is Map) {
            value.forEach((k, v) {
              if (v is List) {
                for (var msg in v) {
                  errors.add(msg.toString());
                }
              } else {
                errors.add(v.toString());
              }
            });
          }
        });
        return errors.isNotEmpty ? errors.join(', ') : 'Login failed';
      }
    } catch (_) {
      // JSON parse failed; show cleaner message for common transport failures.
    }

    if (lower.contains('socketexception') ||
        lower.contains('connection refused') ||
        lower.contains('connection timeout') ||
        lower.contains('cannot connect')) {
      return 'Cannot connect to AgriNova backend. Check server status and network.';
    }

    return errorMsg;
  }

  // Login user
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.login(username, password);

      // Check if response has required fields
      if (response['token'] == null || response['user'] == null) {
        _error =
            response['error']?.toString() ??
            'Login failed - Invalid response from server';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final token = response['token'] as String;
      _user = User.fromJson(response['user'] as Map<String, dynamic>);
      await ApiService.saveToken(token);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.logout();
      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user profile
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.getProfile();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.updateProfile(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
