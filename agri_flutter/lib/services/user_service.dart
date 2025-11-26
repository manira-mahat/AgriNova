import '../models/user.dart';
import 'api_service.dart';

// Simple User Service (for admin)
class UserService {
  // Get all users (Admin)
  static Future<List<User>> getAllUsers() async {
    final response = await ApiService.get("auth/users/");
    return (response as List).map((json) => User.fromJson(json)).toList();
  }

  // Delete user (Admin)
  static Future<void> deleteUser(int id) async {
    await ApiService.delete("auth/users/$id/");
  }
}
