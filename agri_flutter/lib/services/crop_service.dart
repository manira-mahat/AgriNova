import '../models/crop.dart';
import '../models/recommendation.dart';
import 'api_service.dart';

// Simple Crop Service
class CropService {
  // Get all crops
  static Future<List<Crop>> getAllCrops() async {
    final response = await ApiService.get("crops/crops/");
    return (response as List).map((json) => Crop.fromJson(json)).toList();
  }

  // Get crop recommendation
  static Future<Recommendation> getRecommendation(
    Map<String, dynamic> data,
  ) async {
    final response = await ApiService.post("crops/recommend/", data);
    return Recommendation.fromJson(response['recommendation']);
  }

  // Get recommendation history
  static Future<List<Recommendation>> getHistory() async {
    final response = await ApiService.get("crops/recommendations/");
    return (response as List)
        .map((json) => Recommendation.fromJson(json))
        .toList();
  }

  // Create crop (Admin)
  static Future<Crop> createCrop(Map<String, dynamic> data) async {
    final response = await ApiService.post("crops/crops/", data);
    return Crop.fromJson(response);
  }

  // Delete crop (Admin)
  static Future<void> deleteCrop(int id) async {
    await ApiService.delete("crops/crops/$id/");
  }
}
