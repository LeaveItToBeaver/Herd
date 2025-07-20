import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/image_loading_provider.dart';

class UserProfileImage extends ConsumerWidget {
  final double radius;
  final String? profileImageUrl;
  final File? profileImage;

  const UserProfileImage({
    super.key,
    required this.radius,
    this.profileImageUrl,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(imageLoadingProvider);

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: _buildImageProvider(),
      child: isLoading
          ? const CircularProgressIndicator()
          : (profileImage == null &&
                  (profileImageUrl == null || profileImageUrl!.isEmpty))
              ? Icon(
                  Icons.account_circle_outlined,
                  color: Colors.grey[400],
                  size: radius * 2,
                )
              : null,
    );
  }

  ImageProvider? _buildImageProvider() {
    if (profileImage != null) {
      return FileImage(profileImage!);
    } else if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      if (profileImageUrl!.toLowerCase().endsWith('.gif')) {
        return NetworkImage(profileImageUrl!);
      }
      return CachedNetworkImageProvider(profileImageUrl!);
    }
    return null;
  }
}
