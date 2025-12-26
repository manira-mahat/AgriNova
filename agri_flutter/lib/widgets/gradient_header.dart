import 'package:flutter/material.dart';

/// A reusable gradient header widget with customizable content
class GradientHeader extends StatelessWidget {
  final List<Color> gradientColors;
  final Widget child;
  final double? height;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const GradientHeader({
    super.key,
    required this.gradientColors,
    required this.child,
    this.height,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            borderRadius ??
            const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: gradientColors.first.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
      ),
      child: SafeArea(bottom: false, child: child),
    );
  }
}
