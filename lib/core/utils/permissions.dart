import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionManager {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  static Future<bool> hasStoragePermission() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  static Future<bool> requestAllPermissions() async {
    final cameraGranted = await requestCameraPermission();
    final storageGranted = await requestStoragePermission();
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
