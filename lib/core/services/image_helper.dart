import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  // Maximum file size in bytes (10MB)
  static const int maxFileSize = 10 * 1024 * 1024;

  // Allowed image extensions
  static final List<String> allowedExtensions = ['.jpg', '.jpeg', '.png'];

  static Future<File?> pickImageFromGallery({
    required BuildContext context,
    required CropStyle cropStyle,
    required String title,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048, // Limit max width
        maxHeight: 2048, // Limit max height
        imageQuality: 85, // Slightly compress the image
      );

      if (pickedFile != null) {
        // Validate file size
        final file = File(pickedFile.path);
        final size = await file.length();
        if (size > maxFileSize) {
          if (context.mounted) {
            _showErrorDialog(context, 'Image size must be less than 10MB');
          }
          return null;
        }

        // Validate file extension
        final extension = pickedFile.path.toLowerCase().substring(
          pickedFile.path.lastIndexOf('.'),
        );
        if (!allowedExtensions.contains(extension)) {
          if (context.mounted) {
            _showErrorDialog(
              context,
              'Only ${allowedExtensions.join(", ")} files are allowed',
            );
          }
          return null;
        }

        try {
          final CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: pickedFile.path,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: title,
                toolbarColor: Colors.greenAccent,
                toolbarWidgetColor: Colors.black,
                statusBarColor: Colors.greenAccent,
                backgroundColor: Colors.black,
                initAspectRatio: CropAspectRatioPreset.ratio16x9,
                lockAspectRatio: false,
                aspectRatioPresets: [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ],
                cropStyle: cropStyle,
              ),
              IOSUiSettings(
                title: title,
                aspectRatioLockEnabled: false,
                resetAspectRatioEnabled: true,
                aspectRatioPickerButtonHidden: false,
              ),
            ],
            compressQuality: 70,
          );

          if (croppedFile != null) {
            final croppedImage = File(croppedFile.path);
            final croppedSize = await croppedImage.length();

            // Validate cropped file size
            if (croppedSize > maxFileSize) {
              if (context.mounted) {
                _showErrorDialog(
                  context,
                  'Cropped image size must be less than 10MB',
                );
              }
              return null;
            }

            return croppedImage;
          }
        } catch (e) {
          debugPrint('Error cropping image: $e');
          if (context.mounted) {
            _showErrorDialog(context, 'Failed to crop image: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to pick image: $e');
      }
    }
    return null;
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}