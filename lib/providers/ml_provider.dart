import 'package:flutter/material.dart';
import '../services/ml_service.dart';
import '../models/ml_models.dart';
import 'dart:io';

class MLProvider extends ChangeNotifier {
  final MLService _mlService = MLService();

  bool _isInitialized = false;
  bool _isAnalyzing = false;
  bool _isInitializing = false;
  TryOnAnalysis? _lastAnalysis;
  String? _errorMessage;
  double _initializationProgress = 0.0;

  bool get isInitialized => _isInitialized;
  bool get isAnalyzing => _isAnalyzing;
  bool get isInitializing => _isInitializing;
  TryOnAnalysis? get lastAnalysis => _lastAnalysis;
  String? get errorMessage => _errorMessage;
  double get initializationProgress => _initializationProgress;

  /// Initialize ML services with progress tracking
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;

    try {
      debugPrint('🚀 ML PROVIDER: Starting initialization...');
      _isInitializing = true;
      _errorMessage = null;
      _initializationProgress = 0.0;
      notifyListeners();

      // Simulate initialization steps with progress
      _initializationProgress = 0.2;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));

      _initializationProgress = 0.5;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));

      _initializationProgress = 0.8;
      notifyListeners();

      final success = await _mlService.initialize();

      _initializationProgress = 1.0;
      _isInitialized = success;

      if (!success) {
        _errorMessage = 'Failed to initialize ML services';
      }

      debugPrint(
          '🚀 ML PROVIDER: Initialization ${success ? 'successful' : 'failed'}');
    } catch (e) {
      _errorMessage = 'ML initialization error: $e';
      debugPrint('❌ ML PROVIDER: Initialization error - $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Complete try-on analysis
  Future<TryOnAnalysis?> analyzeTryOnCompatibility(
      File userImage, File clothingImage) async {
    if (!_isInitialized) {
      _errorMessage = 'ML services not initialized';
      notifyListeners();
      return null;
    }

    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔍 ML PROVIDER: Starting comprehensive try-on analysis...');

      final analysis =
          await _mlService.analyzeTryOnCompatibility(userImage, clothingImage);
      _lastAnalysis = analysis;

      debugPrint(
          '🔍 ML PROVIDER: Analysis complete - ${analysis.compatibilityStatus}');
      return analysis;
    } catch (e) {
      _errorMessage = 'Try-on analysis failed: $e';
      debugPrint('❌ ML PROVIDER: Analysis error - $e');
      return null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Quick pose detection for camera preview
  Future<bool> quickPoseCheck(File imageFile) async {
    if (!_isInitialized) return false;

    try {
      return await _mlService.quickPoseCheck(imageFile);
    } catch (e) {
      debugPrint('❌ ML PROVIDER: Quick pose check error - $e');
      return false;
    }
  }

  /// Advanced clothing classification
  Future<String?> classifyClothing(File clothingImage) async {
    if (!_isInitialized) return null;

    try {
      return await _mlService.classifyClothingAdvanced(clothingImage);
    } catch (e) {
      debugPrint('❌ ML PROVIDER: Clothing classification error - $e');
      return null;
    }
  }

  /// Detect pose with full analysis
  Future<TryOnPose?> detectPose(File imageFile) async {
    if (!_isInitialized) return null;

    try {
      return await _mlService.detectTryOnPose(imageFile);
    } catch (e) {
      debugPrint('❌ ML PROVIDER: Pose detection error - $e');
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearLastAnalysis() {
    _lastAnalysis = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }
}
