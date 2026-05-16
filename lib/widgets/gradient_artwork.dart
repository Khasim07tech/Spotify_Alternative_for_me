import 'package:flutter/material.dart';

class GradientArtwork extends StatelessWidget {
  const GradientArtwork({
    super.key,
    required this.color,
    this.icon = Icons.graphic_eq,
    this.size,
  });

  final Color color;
  final IconData icon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? double.infinity;

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            Color.alphaBlend(Colors.black.withValues(alpha: 0.35), color),
          ],
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white.withValues(alpha: 0.9),
        size: size == null ? 42 : (size! * 0.42).clamp(18, 42).toDouble(),
      ),
    );
  }
}
