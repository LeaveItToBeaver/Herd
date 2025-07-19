import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserCoverImage extends ConsumerWidget {
  final String? coverImageUrl;
  final File? coverFile;
  final bool isSelected;
  final double height; // Add height parameter

  const UserCoverImage({
    super.key,
    this.coverImageUrl,
    this.coverFile,
    this.isSelected = false,
    this.height = 150.0, // Default height
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: height, // Set explicit height
      width: double.infinity, // Ensure width is set
      decoration: BoxDecoration(
        color: Colors.grey[300], // Fallback background
        image: coverFile != null
            ? DecorationImage(
                image: FileImage(coverFile!),
                fit: BoxFit.cover,
              )
            : (coverImageUrl != null && coverImageUrl!.isNotEmpty)
                ? DecorationImage(
                    image: CachedNetworkImageProvider(coverImageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
      ),
      child: isSelected
          ? Stack(
              fit: StackFit.expand, // Make stack fill container
              children: [
                if (coverFile == null && (coverImageUrl?.isEmpty ?? true))
                  Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey[500],
                      size: 40,
                    ),
                  ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child:
                          Icon(Icons.camera_alt, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ],
            )
          : (coverFile == null && (coverImageUrl?.isEmpty ?? true))
              ? const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey,
                  ),
                )
              : null,
    );
  }
}
