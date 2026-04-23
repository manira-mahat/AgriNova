import 'package:flutter/foundation.dart';
import '../models/home_stats.dart';
import '../services/stats_service.dart';

class StatsProvider with ChangeNotifier {
  HomeStats? _stats;
  bool _isLoading = false;
  String? _error;

  HomeStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHomeStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await StatsService.getHomeStats();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
