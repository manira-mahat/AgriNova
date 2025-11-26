import '../models/market.dart';
import 'api_service.dart';

// Simple Market Service
class MarketService {
  // Get all markets
  static Future<List<Market>> getAllMarkets() async {
    final response = await ApiService.get("markets/markets/");
    return (response as List).map((json) => Market.fromJson(json)).toList();
  }

  // Find nearest markets
  static Future<List<Market>> findNearest(Map<String, dynamic> data) async {
    final response = await ApiService.post("markets/find-nearest/", data);
    return (response['markets'] as List)
        .map((json) => Market.fromJson(json))
        .toList();
  }

  // Get markets by district
  static Future<List<Market>> getByDistrict(String district) async {
    final response = await ApiService.get(
      "markets/by-district/?district=$district",
    );
    return (response as List).map((json) => Market.fromJson(json)).toList();
  }

  // Create market (Admin)
  static Future<Market> createMarket(Map<String, dynamic> data) async {
    final response = await ApiService.post("markets/markets/", data);
    return Market.fromJson(response);
  }

  // Delete market (Admin)
  static Future<void> deleteMarket(int id) async {
    await ApiService.delete("markets/markets/$id/");
  }
}
