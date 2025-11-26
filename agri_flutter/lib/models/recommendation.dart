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

    return Recommendation(
      id: json['id'] ?? 0,
      cropName: cropName,
      nitrogen: (json['nitrogen'] ?? 0).toDouble(),
      phosphorus: (json['phosphorus'] ?? 0).toDouble(),
      potassium: (json['potassium'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      ph: (json['ph'] ?? 0).toDouble(),
      rainfall: (json['rainfall'] ?? 0).toDouble(),
    );
  }
}
