import 'package:flutter/material.dart';

/// Application-wide constants
class AppConstants {
  // Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF66BB6A);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color accentGreen = Color(0xFF43A047);
  static const Color warningOrange = Color(0xFFFF8F00);
  static const Color infoBlue = Color(0xFF1E88E5);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2E7D32),
    Color(0xFF66BB6A),
  ];

  static const List<Color> splashGradient = [
    Color(0xFF1B5E20),
    Color(0xFF2E7D32),
    Color(0xFF43A047),
  ];

  // Border Radius
  static const double defaultBorderRadius = 12.0;
  static const double cardBorderRadius = 24.0;
  static const double buttonBorderRadius = 12.0;

  // Spacing
  static const double defaultSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;

  // Padding
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(24.0);
  static const EdgeInsets screenPadding = EdgeInsets.all(20.0);

  // Font Sizes
  static const double headingFontSize = 24.0;
  static const double subheadingFontSize = 18.0;
  static const double bodyFontSize = 14.0;
  static const double smallFontSize = 12.0;

  // App Info
  static const String appName = 'AgriNova';
  static const String appTagline = 'Your Smart Farming Assistant';

  // Feature Names
  static const String cropRecommendation = 'Crop Recommendation';
  static const String marketFinder = 'Market Finder';
  static const String history = 'History';
  static const String profile = 'Profile';
}

/// Reusable box shadows
class AppShadows {
  static List<BoxShadow> get defaultShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 25,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
}

/// Reusable text styles
class AppTextStyles {
  static TextStyle heading(BuildContext context) => TextStyle(
    fontSize: AppConstants.headingFontSize,
    fontWeight: FontWeight.bold,
    color: Colors.grey[800],
  );

  static TextStyle subheading(BuildContext context) => TextStyle(
    fontSize: AppConstants.subheadingFontSize,
    fontWeight: FontWeight.w600,
    color: Colors.grey[800],
  );

  static TextStyle body(BuildContext context) =>
      TextStyle(fontSize: AppConstants.bodyFontSize, color: Colors.grey[700]);

  static TextStyle caption(BuildContext context) =>
      TextStyle(fontSize: AppConstants.smallFontSize, color: Colors.grey[600]);
}
