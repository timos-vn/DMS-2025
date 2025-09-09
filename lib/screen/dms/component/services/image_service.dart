import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Pick image from camera or gallery
  static Future<File?> pickImage({
    required bool isCamera,
    double percentQuantityImage = 0.65, // Default 65% quality
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: (percentQuantityImage * 100).round(),
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  static Future<List<File>> pickMultipleImages({
    double percentQuantityImage = 0.65,
    int maxImages = 10,
  }) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: (percentQuantityImage * 100).round(),
      );

      if (images.isNotEmpty) {
        final List<File> files = images
            .take(maxImages)
            .map((image) => File(image.path))
            .toList();
        return files;
      }
      return [];
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  /// Compress image if needed
  static Future<File?> compressImage(File imageFile) async {
    try {
      // For now, return the original file
      // You can implement image compression logic here
      return imageFile;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  /// Validate image file
  static bool isValidImage(File file) {
    try {
      final String extension = file.path.split('.').last.toLowerCase();
      final List<String> validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      
      if (!validExtensions.contains(extension)) {
        return false;
      }

      // Check file size (max 10MB)
      final int fileSize = file.lengthSync();
      const int maxSize = 10 * 1024 * 1024; // 10MB
      
      if (fileSize > maxSize) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating image: $e');
      return false;
    }
  }

  /// Get image file size in MB
  static double getImageSizeInMB(File file) {
    try {
      final int bytes = file.lengthSync();
      return bytes / (1024 * 1024);
    } catch (e) {
      print('Error getting image size: $e');
      return 0.0;
    }
  }

  /// Get image file size in readable format
  static String getImageSizeReadable(File file) {
    try {
      final int bytes = file.lengthSync();
      if (bytes < 1024) {
        return '${bytes}B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)}KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
      }
    } catch (e) {
      print('Error getting image size: $e');
      return '0B';
    }
  }

  /// Delete image file
  static Future<bool> deleteImage(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Delete multiple image files
  static Future<bool> deleteImages(List<File> files) async {
    try {
      for (final file in files) {
        await deleteImage(file);
      }
      return true;
    } catch (e) {
      print('Error deleting images: $e');
      return false;
    }
  }
}
