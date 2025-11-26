import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/user_service.dart';

// Simple User Provider (for admin)
class UserProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all users (Admin)
  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await UserService.getAllUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete user (Admin)
  Future<bool> deleteUser(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await UserService.deleteUser(id);
      _users.removeWhere((user) => user.id == id);
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
