import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;

class ImageService {
  static Future<String> saveImageToLocalStorage(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${const Uuid().v4()}.jpg';
      final localPath = '${imagesDir.path}/$fileName';

      // Compress and resize image for better performance
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        // Resize if too large (max 1024x1024)
        final resized = img.copyResize(
          image,
          width: image.width > 1024 ? 1024 : null,
          height: image.height > 1024 ? 1024 : null,
        );

        // Compress and save
        final compressedBytes = img.encodeJpg(resized, quality: 85);
        await File(localPath).writeAsBytes(compressedBytes);
      } else {
        // Fallback: just copy the file
        await imageFile.copy(localPath);
      }

      return localPath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      // Fallback: save original file
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      final fileName = '${const Uuid().v4()}.jpg';
      final localPath = '${imagesDir.path}/$fileName';
      await imageFile.copy(localPath);
      return localPath;
    }
  }

  static Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  static Future<List<String>> getAllLocalImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');

      if (!await imagesDir.exists()) {
        return [];
      }

      final files = await imagesDir.list().toList();
      return files
          .where((file) => file is File && file.path.endsWith('.jpg'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      debugPrint('Error getting local images: $e');
      return [];
    }
  }

  static Future<File?> createThumbnail(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      // Create thumbnail (200x200)
      final thumbnail = img.copyResize(image, width: 200, height: 200);
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 80);

      final directory = await getApplicationDocumentsDirectory();
      final thumbnailsDir = Directory('${directory.path}/thumbnails');
      if (!await thumbnailsDir.exists()) {
        await thumbnailsDir.create(recursive: true);
      }

      final thumbnailPath =
          '${thumbnailsDir.path}/${const Uuid().v4()}_thumb.jpg';
      final thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(thumbnailBytes);

      return thumbnailFile;
    } catch (e) {
      debugPrint('Error creating thumbnail: $e');
      return null;
    }
  }
}
