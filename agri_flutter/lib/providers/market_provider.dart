import 'package:flutter/foundation.dart';
import '../models/market.dart';
import '../services/market_service.dart';

// Simple Market Provider
class MarketProvider with ChangeNotifier {
  List<Market> _markets = [];
  List<Market> _nearestMarkets = [];
  bool _isLoading = false;
  String? _error;

  List<Market> get markets => _markets;
  List<Market> get nearestMarkets => _nearestMarkets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all markets
  Future<void> loadMarkets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _markets = await MarketService.getAllMarkets();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Find nearest markets
  Future<bool> findNearest(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _nearestMarkets = await MarketService.findNearest(data);
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

  // Get markets by district
  Future<void> loadByDistrict(String district) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _markets = await MarketService.getByDistrict(district);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create market (Admin)
  Future<bool> createMarket(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMarket = await MarketService.createMarket(data);
      _markets.add(newMarket);
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

  // Delete market (Admin)
  Future<bool> deleteMarket(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await MarketService.deleteMarket(id);
      _markets.removeWhere((market) => market.id == id);
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
