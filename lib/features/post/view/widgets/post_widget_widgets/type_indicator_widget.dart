import 'package:flutter/material.dart';

class TypeIndicatorWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;

  const TypeIndicatorWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.width = double.infinity,
    this.padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    this.iconSize = 14,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
