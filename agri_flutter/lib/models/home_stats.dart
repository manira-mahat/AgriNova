class HomeStats {
  final int cropTypes;
  final int markets;
  final int farmers;

  const HomeStats({
    required this.cropTypes,
    required this.markets,
    required this.farmers,
  });

  factory HomeStats.fromJson(Map<String, dynamic> json) {
    return HomeStats(
      cropTypes: json['crop_types'] as int? ?? 0,
      markets: json['markets'] as int? ?? 0,
      farmers: json['farmers'] as int? ?? 0,
    );
  }
}
