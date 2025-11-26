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
    return Crop(
      id: json['id'],
      name: json['name'],
      nitrogenMin: (json['nitrogen_min'] ?? 0).toDouble(),
      nitrogenMax: (json['nitrogen_max'] ?? 0).toDouble(),
      phosphorusMin: (json['phosphorus_min'] ?? 0).toDouble(),
      phosphorusMax: (json['phosphorus_max'] ?? 0).toDouble(),
      potassiumMin: (json['potassium_min'] ?? 0).toDouble(),
      potassiumMax: (json['potassium_max'] ?? 0).toDouble(),
      phMin: (json['ph_min'] ?? 0).toDouble(),
      phMax: (json['ph_max'] ?? 0).toDouble(),
    );
  }
}
