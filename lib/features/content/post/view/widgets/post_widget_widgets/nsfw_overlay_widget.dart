import 'package:flutter/material.dart';

class NSFWOverlayWidget extends StatelessWidget {
  final VoidCallback onTap;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color overlayColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;

  const NSFWOverlayWidget({
    super.key,
    required this.onTap,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius,
    this.title = 'NSFW Content',
    this.subtitle = 'Tap to view',
    this.icon = Icons.visibility_off,
    this.overlayColor =
        const Color(0xD9616161), // Colors.grey.shade700.withOpacity(0.85)
    this.iconColor = Colors.white70,
    this.titleColor = Colors.white,
    this.subtitleColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: overlayColor,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: subtitleColor),
            ),
          ],
        ),
      ),
    );
  }
}
