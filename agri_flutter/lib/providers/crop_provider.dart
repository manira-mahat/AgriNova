import 'package:flutter/foundation.dart';
import '../models/crop.dart';
import '../models/recommendation.dart';
import '../services/crop_service.dart';

// Simple Crop Provider
class CropProvider with ChangeNotifier {
  List<Crop> _crops = [];
  List<Recommendation> _history = [];
  Recommendation? _currentRecommendation;
  bool _isLoading = false;
  String? _error;

  List<Crop> get crops => _crops;
  List<Recommendation> get history => _history;
  Recommendation? get currentRecommendation => _currentRecommendation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all crops
  Future<void> loadCrops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _crops = await CropService.getAllCrops();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get recommendation
  Future<bool> getRecommendation(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentRecommendation = await CropService.getRecommendation(data);
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

  // Load recommendation history
  Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _history = await CropService.getHistory();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create crop (Admin)
  Future<bool> createCrop(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCrop = await CropService.createCrop(data);
      _crops.add(newCrop);
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

  // Delete crop (Admin)
  Future<bool> deleteCrop(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await CropService.deleteCrop(id);
      _crops.removeWhere((crop) => crop.id == id);
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
