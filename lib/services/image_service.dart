import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

      await imageFile.copy(localPath);
      return localPath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      rethrow;
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
}
