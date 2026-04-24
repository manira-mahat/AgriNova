import '../models/home_stats.dart';
import 'api_service.dart';

class StatsService {
  static Future<HomeStats> getHomeStats() async {
    final response = await ApiService.get('auth/stats/');
    return HomeStats.fromJson(response as Map<String, dynamic>);
  }
}
