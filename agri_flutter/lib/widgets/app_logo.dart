import 'package:flutter/material.dart';

/// A reusable app logo widget with glow effect
class AppLogo extends StatelessWidget {
  final double size;
  final Color color;
  final bool showGlow;
  final double padding;

  const AppLogo({
    super.key,
    this.size = 50,
    this.color = Colors.white,
    this.showGlow = true,
    this.padding = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: showGlow ? color.withOpacity(0.15) : Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: Icon(Icons.agriculture_rounded, size: size, color: color),
    );
  }
}
