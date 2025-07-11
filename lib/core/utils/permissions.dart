import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PermissionManager {
  static Future<bool> requestCameraPermission() async {
    try {
      debugPrint('Requesting camera permission...');
      final status = await Permission.camera.request();
      debugPrint('Camera permission status: $status');

      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        debugPrint('Camera permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        debugPrint('Camera permission permanently denied');
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      return false;
    }
  }

  static Future<bool> requestStoragePermission() async {
    try {
      debugPrint('Requesting storage permission...');

      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), use photos permission
        final photos = await Permission.photos.request();
        debugPrint('Photos permission status: $photos');

        if (photos.isGranted) {
          return true;
        }

        // Fallback to storage permission for older Android versions
        final storage = await Permission.storage.request();
        debugPrint('Storage permission status: $storage');
        return storage.isGranted;
      } else {
        // For iOS, photos permission is sufficient
        final photos = await Permission.photos.request();
        debugPrint('iOS Photos permission status: $photos');
        return photos.isGranted;
      }
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final photos = await Permission.photos.status;
      if (photos.isGranted) return true;

      final storage = await Permission.storage.status;
      return storage.isGranted;
    } else {
      final photos = await Permission.photos.status;
      return photos.isGranted;
    }
  }

  static Future<bool> requestAllPermissions() async {
    final cameraGranted = await requestCameraPermission();
    final storageGranted = await requestStoragePermission();
    debugPrint('Camera: $cameraGranted, Storage: $storageGranted');
    return cameraGranted && storageGranted;
  }

  static void showPermissionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}
