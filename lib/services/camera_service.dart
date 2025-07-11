import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraService {
  static CameraController? _controller;
  static List<CameraDescription>? _cameras;
  static int _currentCameraIndex = 0;
  static bool _isInitialized = false;

  static Future<bool> initialize() async {
    try {
      _cameras = await availableCameras();
      debugPrint('Available cameras: ${_cameras?.length}');

      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('No cameras available');
        return false;
      }

      // Start with back camera for better photos
      _currentCameraIndex = 0;
      return await _initializeController();
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
      return false;
    }
  }

  static Future<bool> _initializeController() async {
    try {
      await _controller?.dispose();

      _controller = CameraController(
        _cameras![_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
      debugPrint('Camera controller initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
      _isInitialized = false;
      return false;
    }
  }

  static CameraController? get controller => _controller;
  static bool get isInitialized =>
      _isInitialized && _controller != null && _controller!.value.isInitialized;
  static List<CameraDescription>? get cameras => _cameras;

  static Future<File?> takePicture() async {
    if (!isInitialized) {
      debugPrint('Camera not initialized');
      return null;
    }

    try {
      final XFile picture = await _controller!.takePicture();
      debugPrint('Picture taken: ${picture.path}');
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
        debugPrint('Image picked from gallery: ${image.path}');
        return File(image.path);
      } else {
        debugPrint('No image selected from gallery');
        return null;
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      return null;
    }
  }

  static Future<bool> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      debugPrint('Cannot switch camera: not enough cameras');
      return false;
    }

    try {
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
      debugPrint('Switching to camera $_currentCameraIndex');

      final success = await _initializeController();
      if (success) {
        debugPrint('Camera switched successfully');
      } else {
        debugPrint('Failed to switch camera');
      }
      return success;
    } catch (e) {
      debugPrint('Error switching camera: $e');
      return false;
    }
  }

  static void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
