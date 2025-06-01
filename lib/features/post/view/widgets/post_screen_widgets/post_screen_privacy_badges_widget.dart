import 'package:flutter/material.dart';

class PostPrivacyBadges extends StatelessWidget {
  final bool isAlt;
  final bool isNSFW;

  const PostPrivacyBadges({
    super.key,
    required this.isAlt,
    required this.isNSFW,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isAlt)
          Container(
            //color: Colors.blue.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.public_rounded,
                  size: 16,
                  // color: Colors.blue
                ),
                const SizedBox(width: 8),
                const Text(
                  'Alt Post',
                  style: TextStyle(
                    //color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        if (isNSFW)
          Container(
            color: Colors.red.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 16, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'NSFW Content',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'This post contains sensitive content',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
