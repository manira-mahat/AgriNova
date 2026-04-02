// Simple Crop Model
class Crop {
  final int id;
  final String name;
  final double nitrogenMin;
  final double nitrogenMax;
  final double phosphorusMin;
  final double phosphorusMax;
  final double potassiumMin;
  final double potassiumMax;
  final double phMin;
  final double phMax;

  Crop({
    required this.id,
    required this.name,
    required this.nitrogenMin,
    required this.nitrogenMax,
    required this.phosphorusMin,
    required this.phosphorusMax,
    required this.potassiumMin,
    required this.potassiumMax,
    required this.phMin,
    required this.phMax,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return Crop(
      id: json['id'],
      name: json['name'],
      nitrogenMin: asDouble(json['min_nitrogen'] ?? json['nitrogen_min']),
      nitrogenMax: asDouble(json['max_nitrogen'] ?? json['nitrogen_max']),
      phosphorusMin: asDouble(
        json['min_phosphorus'] ?? json['phosphorus_min'],
      ),
      phosphorusMax: asDouble(
        json['max_phosphorus'] ?? json['phosphorus_max'],
      ),
      potassiumMin: asDouble(json['min_potassium'] ?? json['potassium_min']),
      potassiumMax: asDouble(json['max_potassium'] ?? json['potassium_max']),
      phMin: asDouble(json['min_ph'] ?? json['ph_min']),
      phMax: asDouble(json['max_ph'] ?? json['ph_max']),
    );
  }
}
