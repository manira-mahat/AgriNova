// Simple Market Model
class Market {
  final int id;
  final String name;
  final String district;
  final String? address;
  final String marketType;
  final double latitude;
  final double longitude;
  final double? distanceKm;

  Market({
    required this.id,
    required this.name,
    required this.district,
    this.address,
    required this.marketType,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'],
      name: json['name'],
      district: json['district'],
      address: json['address'],
      marketType: json['market_type'] ?? 'retail',
      latitude: (json['latitude']).toDouble(),
      longitude: (json['longitude']).toDouble(),
      distanceKm: json['distance_km']?.toDouble(),
    );
  }
}
