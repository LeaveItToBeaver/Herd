import 'dart:io';

import 'package:flutter/material.dart';
import 'package:herdapp/core/services/image_helper.dart';
import 'package:image_cropper/image_cropper.dart';

/// Mixin that provides image handling functionality for herd creation
mixin HerdImageHandlingMixin<T extends StatefulWidget> on State<T> {
  File? profileImage;
  File? coverImage;

  Future<void> selectProfileImage() async {
    final image = await ImageHelper.pickImageFromGallery(
      context: context,
      cropStyle: CropStyle.circle,
      title: 'Herd Profile Image',
    );

    if (image != null) {
      setState(() {
        profileImage = image;
      });
    }
  }

  Future<void> selectCoverImage() async {
    final image = await ImageHelper.pickImageFromGallery(
      context: context,
      cropStyle: CropStyle.rectangle,
      title: 'Herd Cover Image',
    );

    if (image != null) {
      setState(() {
        coverImage = image;
      });
    }
  }

  /// Build cover image picker widget
  Widget buildCoverImagePicker() {
    return GestureDetector(
      onTap: selectCoverImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          image: coverImage != null
              ? DecorationImage(
                  image: FileImage(coverImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: coverImage == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 40),
                    SizedBox(height: 8),
                    Text('Add Cover Image'),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  /// Build profile image picker widget
  Widget buildProfileImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: selectProfileImage,
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage:
              profileImage != null ? FileImage(profileImage!) : null,
          child: profileImage == null
              ? const Icon(Icons.add_a_photo, size: 30)
              : null,
        ),
      ),
    );
  }
}
