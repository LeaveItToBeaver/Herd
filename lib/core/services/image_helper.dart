import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageHelper {
  // Maximum file size in bytes (20MB - increased from 10MB)
  static const int maxFileSize = 20 * 1024 * 1024;

  // Expanded list of allowed extensions
  static final List<String> allowedExtensions = [
    // Images
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp',
    // Videos
    '.mp4', '.mov', '.avi', '.mkv', '.webm',
    // Animated images
    '.gif', '.webp'
  ];

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
            _showErrorDialog(context, 'File size must be less than 20MB');
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

        // Skip cropping for gif files since cropping can break animation
        if (extension == '.gif') {
          return file;
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
                  'Cropped file size must be less than 20MB',
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

  // New method for picking any media file (image, video, etc)
  static Future<File?> pickMediaFile({
    required BuildContext context,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions.map((e) => e.substring(1)).toList(), // Remove the dot
        allowCompression: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // Validate file size
        final size = await file.length();
        if (size > maxFileSize) {
          if (context.mounted) {
            _showErrorDialog(context, 'File size must be less than 20MB');
          }
          return null;
        }

        // Validate file extension
        final extension = result.files.single.path!.toLowerCase().substring(
          result.files.single.path!.lastIndexOf('.'),
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

        return file;
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to pick media file: $e');
      }
    }
    return null;
  }

  // New method to compress an image file
  static Future<File?> compressImage(File file, {int quality = 75}) async {
    try {
      // Skip compression for GIFs
      final extension = path.extension(file.path).toLowerCase();
      if (extension == '.gif') {
        return file; // Return the original file for GIFs
      }

      // Get the temporary directory path
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${path.basenameWithoutExtension(file.path)}_compressed$extension';

      // Compression parameters based on extension
      var result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: quality,
        // Set a reasonable minWidth and minHeight to avoid images being too small
        minWidth: 640, // Decent width for feed display
        minHeight: 640, // Keep it square by default
        format: _getCompressFormat(extension),
      );

      if (result == null) {
        debugPrint('Compression failed');
        return file; // Return original if compression fails
      }

      return File(result.path);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return file; // Return original if there's an error
    }
  }

  // Helper to determine compress format based on file extension
  static CompressFormat _getCompressFormat(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return CompressFormat.jpeg;
      case '.png':
        return CompressFormat.png;
      case '.webp':
        return CompressFormat.webp;
      default:
        return CompressFormat.jpeg; // Default to JPEG for other formats
    }
  }

  // Method to check if a file is an image
  static bool isImage(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension);
  }

  // Method to check if a file is a video
  static bool isVideo(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(extension);
  }

  // Method to check if the file is a GIF
  static bool isGif(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return extension == '.gif';
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