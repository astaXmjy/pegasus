import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../services/camera_service.dart';
import '../services/image_service.dart';
import '../core/utils/permissions.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  File? _lastCapturedImage;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get lastCapturedImage => _lastCapturedImage;

  Future<void> initializeCamera() async {
    debugPrint('CameraProvider: Initializing camera...');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check and request camera permission
      final hasPermission = await PermissionManager.hasCameraPermission();
      debugPrint('Camera permission status: $hasPermission');

      if (!hasPermission) {
        debugPrint('Requesting camera permission...');
        final granted = await PermissionManager.requestCameraPermission();
        if (!granted) {
          _errorMessage = 'Camera permission is required to take photos';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Initialize camera service
      final success = await CameraService.initialize();
      if (!success) {
        _errorMessage =
            'Failed to initialize camera. Please check if camera is available.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _controller = CameraService.controller;
      _isInitialized = CameraService.isInitialized;

      if (!_isInitialized) {
        _errorMessage = 'Camera initialization failed';
      } else {
        debugPrint('Camera initialized successfully');
      }
    } catch (e) {
      _errorMessage = 'Camera error: $e';
      debugPrint('Camera initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<File?> takePicture() async {
    debugPrint('CameraProvider: Taking picture...');

    if (!_isInitialized || _controller == null) {
      _errorMessage = 'Camera not initialized';
      notifyListeners();
      return null;
    }

    try {
      final image = await CameraService.takePicture();
      if (image != null) {
        debugPrint('Picture taken successfully: ${image.path}');
        // Save to local storage
        final savedPath = await ImageService.saveImageToLocalStorage(image);
        _lastCapturedImage = File(savedPath);
        debugPrint('Image saved to: $savedPath');
        return _lastCapturedImage;
      } else {
        _errorMessage = 'Failed to capture image';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Failed to take picture: $e';
      debugPrint('Take picture error: $e');
      notifyListeners();
      return null;
    }
  }

  Future<File?> pickFromGallery() async {
    debugPrint('CameraProvider: Picking from gallery...');

    try {
      // Check and request storage permission
      final hasPermission = await PermissionManager.hasStoragePermission();
      debugPrint('Storage permission status: $hasPermission');

      if (!hasPermission) {
        debugPrint('Requesting storage permission...');
        final granted = await PermissionManager.requestStoragePermission();
        if (!granted) {
          _errorMessage = 'Storage permission is required to access photos';
          notifyListeners();
          return null;
        }
      }

      final image = await CameraService.pickFromGallery();
      if (image != null) {
        debugPrint('Image picked from gallery: ${image.path}');
        // Save to local storage
        final savedPath = await ImageService.saveImageToLocalStorage(image);
        _lastCapturedImage = File(savedPath);
        debugPrint('Gallery image saved to: $savedPath');
        return _lastCapturedImage;
      } else {
        debugPrint('No image selected from gallery');
        return null;
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      debugPrint('Gallery pick error: $e');
      notifyListeners();
      return null;
    }
  }

  Future<void> switchCamera() async {
    debugPrint('CameraProvider: Switching camera...');

    try {
      final success = await CameraService.switchCamera();
      if (success) {
        _controller = CameraService.controller;
        _isInitialized = CameraService.isInitialized;
        debugPrint('Camera switched successfully');
        notifyListeners();
      } else {
        _errorMessage = 'Failed to switch camera';
        debugPrint('Camera switch failed');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Camera switch error: $e';
      debugPrint('Camera switch error: $e');
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    CameraService.dispose();
    super.dispose();
  }
}
