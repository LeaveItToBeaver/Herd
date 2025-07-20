import 'package:flutter/material.dart';

class NSFWHiddenMessageWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final BorderRadius? borderRadius;

  const NSFWHiddenMessageWidget({
    super.key,
    this.height = 150,
    this.width = double.infinity,
    this.title = 'NSFW Content Hidden',
    this.subtitle = 'Adjust your settings to view',
    this.icon = Icons.block,
    this.backgroundColor = const Color(0xFFEEEEEE), // Colors.grey.shade200
    this.iconColor = Colors.grey,
    this.titleColor = Colors.black54,
    this.subtitleColor = const Color(0xFF757575), // Colors.grey.shade600
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
