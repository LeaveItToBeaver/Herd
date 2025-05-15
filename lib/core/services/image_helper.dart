import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
//import 'package:permission_handler/permission_handler.dart';
//import 'package:video_thumbnail/video_thumbnail.dart';

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

  static Future<List<File>?> pickMultipleMediaFiles({
    required BuildContext context,
    int maxFiles = 10,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        // Convert XFile to File
        final files = pickedFiles.map((xFile) => File(xFile.path)).toList();

        if (files.length > maxFiles && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Maximum of $maxFiles files allowed. Only the first $maxFiles will be used.'),
            ),
          );
          return files.sublist(0, maxFiles);
        }

        return files;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking multiple media: $e');
      rethrow;
    }
  }

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

  static Future<File?> cropImage({
    required File imageFile,
    required BuildContext context,
    required CropStyle cropStyle,
    required String title,
  }) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: title,
            toolbarColor: Colors.greenAccent,
            toolbarWidgetColor: Colors.black,
            statusBarColor: Colors.greenAccent,
            backgroundColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
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
        return File(croppedFile.path);
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to crop image: $e');
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
        allowedExtensions: allowedExtensions
            .map((e) => e.substring(1))
            .toList(), // Remove the dot just for FilePicker
        compressionQuality: 85,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // Validate file size
        final size = await file.length();
        if (size > maxFileSize) {
          if (context.mounted) {
            _showErrorDialog(
                context, 'File size must be less than 20MB, sorry. :(');
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
      final targetPath =
          '${dir.path}/${path.basenameWithoutExtension(file.path)}_compressed$extension';

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
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
        .contains(extension);
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

  // The method below is currently commented out because its functionality has not been verified.
  // It is retained for potential future use in generating video thumbnails. To use this method:
  // 1. Verify that the `video_thumbnail` package is properly integrated and functional.
  // 2. Ensure that the required permissions (e.g., storage access) are handled correctly.
  // 3. Test the method thoroughly to confirm it works as expected.
  // If this method is no longer needed, consider removing it to reduce clutter.
  // static Future<File?> generateVideoThumbnailFile(File videoFile) async {
  //   try {
  //     Map<Permission, PermissionStatus> statuses = await [
  //       Permission.storage,
  //     ].request();
  //     final thumbnailBytes = await VideoThumbnail.thumbnailData(
  //       video: videoFile.path,
  //       imageFormat: ImageFormat.JPEG,
  //       maxWidth: 512,
  //       quality: 75,
  //     );

  //     if (thumbnailBytes == null) return null;

  //     // Create a file for the thumbnail
  //     final tempDir = await getTemporaryDirectory();
  //     final thumbnailFile = File(
  //         '${tempDir.path}/${path.basenameWithoutExtension(videoFile.path)}_thumb.jpg');
  //     await thumbnailFile.writeAsBytes(thumbnailBytes);

  //     return thumbnailFile;
  //   } catch (e) {
  //     debugPrint('Error generating video thumbnail: $e');
  //     return null;
  //   }
  // }

  static Future<List<File>?> pickMediaFilesWithVideo({
    required BuildContext context,
    int maxFiles = 10,
  }) async {
    try {
      // Ask user which type of media they want to select
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select media'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Image(s)'),
                onTap: () => Navigator.pop(context, 'image'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Video'),
                onTap: () => Navigator.pop(context, 'video'),
              ),
            ],
          ),
        ),
      );

      if (choice == null) return null;

      if (choice == 'image') {
        final picker = ImagePicker();
        final pickedFiles = await picker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          return pickedFiles.map((xFile) => File(xFile.path)).toList();
        }
      } else if (choice == 'video') {
        final picker = ImagePicker();
        final pickedVideo = await picker.pickVideo(source: ImageSource.gallery);
        if (pickedVideo != null) {
          return [File(pickedVideo.path)];
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error picking media: $e');
      return null;
    }
  }

  static Future<List<File>?> pickMultipleMediaFilesWithVideos({
    required BuildContext context,
    int maxFiles = 10,
  }) async {
    try {
      // Use FilePicker for both images and videos
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: allowedExtensions
            .map((e) => e.substring(1))
            .toList(), // Remove the dot for FilePicker
      );

      if (result != null && result.files.isNotEmpty) {
        // Convert to File objects
        final files = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();

        // Validate each file
        List<File> validFiles = [];
        for (var file in files) {
          // Check file size
          final size = await file.length();
          if (size > maxFileSize) {
            if (context.mounted) {
              _showErrorDialog(context,
                  'File ${path.basename(file.path)} exceeds 20MB limit');
            }
            continue;
          }

          // Check extension
          final extension = file.path.toLowerCase().substring(
                file.path.lastIndexOf('.'),
              );
          if (!allowedExtensions.contains(extension)) {
            if (context.mounted) {
              _showErrorDialog(context,
                  'File ${path.basename(file.path)} has unsupported format');
            }
            continue;
          }

          validFiles.add(file);
        }

        if (validFiles.isEmpty) {
          return null;
        }

        if (validFiles.length > maxFiles && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Maximum of $maxFiles files allowed. Only the first $maxFiles will be used.'),
            ),
          );
          return validFiles.sublist(0, maxFiles);
        }

        return validFiles;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking multiple media: $e');
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to pick media: $e');
      }
      return null;
    }
  }
}
