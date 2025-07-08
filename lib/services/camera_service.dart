import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraService {
  static CameraController? _controller;
  static List<CameraDescription>? _cameras;

  static Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        // Use front camera for try-on feature
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _controller = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  static CameraController? get controller => _controller;

  static bool get isInitialized =>
      _controller != null && _controller!.value.isInitialized;

  static Future<File?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final XFile picture = await _controller!.takePicture();
      return File(picture.path);
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  static Future<File?> pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      return null;
    }
  }

  static Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    try {
      final currentDirection = _controller?.description.lensDirection;
      final newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection != currentDirection,
      );

      await _controller?.dispose();
      _controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
    } catch (e) {
      debugPrint('Error switching camera: $e');
    }
  }

  static void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
