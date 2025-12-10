// Simple Recommendation Model
class Recommendation {
  final int id;
  final String cropName;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double temperature;
  final double humidity;
  final double ph;
  final double rainfall;
  final String district;
  final String season;

  Recommendation({
    required this.id,
    required this.cropName,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.rainfall,
    this.district = '',
    this.season = '',
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    // Get first recommended crop or the recommended_crop field
    String cropName = 'Unknown';
    if (json.containsKey('recommended_crop')) {
      cropName = json['recommended_crop'];
    } else if (json.containsKey('recommended_crops_details')) {
      final crops = json['recommended_crops_details'] as List;
      if (crops.isNotEmpty) {
        cropName = crops[0]['crop_name'] ?? 'Unknown';
      }
    }

    // Extract soil data from soil_data_details
    Map<String, dynamic> soilData = {};
    if (json.containsKey('soil_data_details')) {
      soilData = json['soil_data_details'] as Map<String, dynamic>;
    }

    return Recommendation(
      id: json['id'] ?? 0,
      cropName: cropName,
      nitrogen: (soilData['nitrogen'] ?? 0).toDouble(),
      phosphorus: (soilData['phosphorus'] ?? 0).toDouble(),
      potassium: (soilData['potassium'] ?? 0).toDouble(),
      temperature: (soilData['temperature'] ?? 0).toDouble(),
      humidity: (soilData['humidity'] ?? 0).toDouble(),
      ph: (soilData['ph_level'] ?? 0).toDouble(),
      rainfall: (soilData['rainfall'] ?? 0).toDouble(),
      district: soilData['district'] ?? '',
      season: soilData['season'] ?? '',
    );
  }
}
