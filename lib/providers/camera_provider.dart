import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../services/camera_service.dart';
import '../core/utils/permissions.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initializeCamera() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasPermission = await PermissionManager.requestCameraPermission();
      if (!hasPermission) {
        _errorMessage = 'Camera permission denied';
        return;
      }

      await CameraService.initialize();
      _controller = CameraService.controller;
      _isInitialized = _controller?.value.isInitialized ?? false;

      if (!_isInitialized) {
        _errorMessage = 'Failed to initialize camera';
      }
    } catch (e) {
      _errorMessage = 'Camera initialization error: $e';
      debugPrint('Camera error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<File?> takePicture() async {
    if (!_isInitialized || _controller == null) {
      _errorMessage = 'Camera not initialized';
      notifyListeners();
      return null;
    }

    try {
      return await CameraService.takePicture();
    } catch (e) {
      _errorMessage = 'Failed to take picture: $e';
      notifyListeners();
      return null;
    }
  }

  Future<File?> pickFromGallery() async {
    try {
      final hasPermission = await PermissionManager.requestStoragePermission();
      if (!hasPermission) {
        _errorMessage = 'Storage permission denied';
        notifyListeners();
        return null;
      }

      return await CameraService.pickFromGallery();
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
