import '../models/user.dart';
import 'api_service.dart';

// Simple Auth Service
class AuthService {
  // Register new user
  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiService.post("auth/register/", data);
    return response;
  }

  // Login user
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final data = {"username": username, "password": password};
    final response = await ApiService.post("auth/login/", data);
    return response;
  }

  // Logout user
  static Future<void> logout() async {
    await ApiService.post("auth/logout/", {});
    await ApiService.removeToken();
  }

  // Get user profile
  static Future<User> getProfile() async {
    final response = await ApiService.get("auth/profile/");
    return User.fromJson(response);
  }

  // Update user profile
  static Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await ApiService.put("auth/profile/", data);
    return User.fromJson(response);
  }
}
