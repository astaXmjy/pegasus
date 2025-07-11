import 'package:flutter/material.dart';
import 'dart:io';

class DebugHelper {
  static void logCameraState(String context, dynamic state) {
    debugPrint('=== CAMERA DEBUG [$context] ===');
    debugPrint('State: $state');
    debugPrint('Timestamp: ${DateTime.now()}');
    debugPrint('===============================');
  }

  static void logImageInfo(String context, File? imageFile) {
    debugPrint('=== IMAGE DEBUG [$context] ===');
    if (imageFile != null) {
      debugPrint('Path: ${imageFile.path}');
      debugPrint('Exists: ${imageFile.existsSync()}');
      if (imageFile.existsSync()) {
        debugPrint('Size: ${imageFile.lengthSync()} bytes');
      }
    } else {
      debugPrint('Image is null');
    }
    debugPrint('=============================');
  }

  static void logPermissionState(String permission, bool granted) {
    debugPrint('=== PERMISSION DEBUG ===');
    debugPrint('$permission: ${granted ? "GRANTED" : "DENIED"}');
    debugPrint('======================');
  }
}
