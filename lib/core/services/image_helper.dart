import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static Future<File?> pickImageFromGallery({
    required BuildContext context,
    required CropStyle cropStyle,
    required String title,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
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
              )
            ],
            compressQuality: 70,
          );

          if (croppedFile != null) {
            return File(croppedFile.path);
          }
        } catch (e) {
          debugPrint('Error cropping image: $e');
          // Show error dialog
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to crop image: $e'),
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
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      // Show error dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to pick image: $e'),
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
    return null;
  }
}