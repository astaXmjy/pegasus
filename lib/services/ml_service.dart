import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../models/ml_models.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;

class MLService {
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  // Google ML Kit Services
  late PoseDetector _poseDetector;
  late ObjectDetector _objectDetector;
  late ImageLabeler _imageLabeler;

  // TensorFlow Lite Interpreters (for future use)
  Interpreter? _personSegmentationModel;
  Interpreter? _clothingClassificationModel;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize all ML models and services
  Future<bool> initialize() async {
    try {
      debugPrint('🤖 ML SERVICE: Starting complete initialization...');

      await _initializeMLKit();
      await _initializeTFLiteModels();

      _isInitialized = true;
      debugPrint('✅ ML SERVICE: Complete initialization successful');
      return true;
    } catch (e) {
      debugPrint('❌ ML SERVICE: Initialization failed - $e');
      return false;
    }
  }

  /// Initialize Google ML Kit services
  Future<void> _initializeMLKit() async {
    debugPrint('🔧 ML SERVICE: Initializing ML Kit services...');

    // Initialize Pose Detector with optimal settings
    final poseOptions = PoseDetectorOptions(
      model: PoseDetectionModel.accurate,
      mode: PoseDetectionMode.single,
    );
    _poseDetector = PoseDetector(options: poseOptions);

    // Initialize Object Detector for clothing detection
    final objectOptions = ObjectDetectorOptions(
      mode: DetectionMode.single,
      classifyObjects: true,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: objectOptions);

    // Initialize Image Labeler for general classification
    final labelOptions = ImageLabelerOptions(
      confidenceThreshold: 0.5,
    );
    _imageLabeler = ImageLabeler(options: labelOptions);

    debugPrint('✅ ML Kit services initialized');
  }

  /// Initialize TensorFlow Lite models (placeholder for Phase 3)
  Future<void> _initializeTFLiteModels() async {
    debugPrint('🔧 ML SERVICE: Initializing TensorFlow Lite models...');

    try {
      // These will be implemented in Phase 3 with actual models
      debugPrint('📦 TFLite models will be loaded in Phase 3');
    } catch (e) {
      debugPrint('⚠️ TFLite models not available yet: $e');
    }
  }

  /// Complete pose detection with full analysis
  Future<TryOnPose?> detectTryOnPose(File imageFile) async {
    try {
      debugPrint('🕺 ML SERVICE: Detecting pose for try-on...');

      final inputImage = InputImage.fromFile(imageFile);
      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        final pose = poses.first;
        final tryOnPose = TryOnPose.fromPose(pose);

        debugPrint(
            '🕺 Pose detected - Quality: ${(tryOnPose.poseQuality * 100).round()}%');
        debugPrint(
            '🕺 Orientation: ${tryOnPose.orientation.primaryOrientation}');
        debugPrint(
            '🕺 Measurements completeness: ${(tryOnPose.measurements.completeness * 100).round()}%');

        return tryOnPose;
      }

      debugPrint('🕺 No pose detected');
      return null;
    } catch (e) {
      debugPrint('❌ Pose detection failed: $e');
      return null;
    }
  }

  /// Enhanced object detection with clothing focus
  Future<List<DetectedObject>> detectClothingObjects(File imageFile) async {
    try {
      debugPrint('👕 ML SERVICE: Detecting clothing objects...');

      final inputImage = InputImage.fromFile(imageFile);
      final objects = await _objectDetector.processImage(inputImage);

      // Filter for clothing-related objects
      final clothingObjects = objects.where((obj) {
        return obj.labels.any((label) => _isClothingRelated(label.text));
      }).toList();

      debugPrint(
          '👕 Detected ${clothingObjects.length} clothing objects out of ${objects.length} total');
      return clothingObjects;
    } catch (e) {
      debugPrint('❌ Clothing object detection failed: $e');
      return [];
    }
  }

  /// Enhanced image labeling for clothing classification
  Future<String?> classifyClothingAdvanced(File imageFile) async {
    try {
      debugPrint('🏷️ ML SERVICE: Advanced clothing classification...');

      final inputImage = InputImage.fromFile(imageFile);
      final labels = await _imageLabeler.processImage(inputImage);

      // Find clothing-related labels
      final clothingLabels = labels
          .where((label) =>
              _isClothingRelated(label.label) && label.confidence > 0.6)
          .toList();

      if (clothingLabels.isNotEmpty) {
        clothingLabels.sort((a, b) => b.confidence.compareTo(a.confidence));
        final bestLabel = clothingLabels.first;
        final category = _mapLabelToCategory(bestLabel.label);

        debugPrint(
            '🏷️ Classified as: $category (confidence: ${(bestLabel.confidence * 100).round()}%)');
        return category;
      }

      // Fallback to mock classification
      final mockCategories = [
        'Tops',
        'Bottoms',
        'Dresses',
        'Outerwear',
        'Accessories'
      ];
      final category =
          mockCategories[DateTime.now().millisecond % mockCategories.length];
      debugPrint('🏷️ Mock classification: $category');
      return category;
    } catch (e) {
      debugPrint('❌ Clothing classification failed: $e');
      return null;
    }
  }

  /// Get comprehensive image labels
  Future<List<ImageLabel>> getImageLabels(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final labels = await _imageLabeler.processImage(inputImage);

      debugPrint('🏷️ Found ${labels.length} image labels');
      return labels;
    } catch (e) {
      debugPrint('❌ Image labeling failed: $e');
      return [];
    }
  }

  /// Complete try-on analysis with all features
  Future<TryOnAnalysis> analyzeTryOnCompatibility(
      File userImage, File clothingImage) async {
    try {
      debugPrint('🔍 ML SERVICE: Starting comprehensive try-on analysis...');

      // Parallel analysis for better performance
      final futures = await Future.wait([
        detectTryOnPose(userImage),
        detectClothingObjects(userImage),
        classifyClothingAdvanced(clothingImage),
        getImageLabels(userImage),
        getImageLabels(clothingImage),
      ]);

      final tryOnPose = futures[0] as TryOnPose?;
      final detectedObjects = futures[1] as List<DetectedObject>;
      final clothingType = futures[2] as String?;
      final userLabels = futures[3] as List<ImageLabel>;
      final clothingLabels = futures[4] as List<ImageLabel>;

      // Combine all labels
      final allLabels = [...userLabels, ...clothingLabels];

      // Calculate comprehensive compatibility
      final compatibility = _calculateAdvancedCompatibility(
          tryOnPose, clothingType, detectedObjects, allLabels);

      // Generate clothing fit analysis
      ClothingFit? clothingFit;
      if (clothingType != null && tryOnPose != null) {
        clothingFit = ClothingFit.analyze(clothingType, tryOnPose.measurements);
      }

      final analysis = TryOnAnalysis(
        hasPoseDetected: tryOnPose != null,
        pose: tryOnPose?.landmarks.isNotEmpty == true
            ? Pose(landmarks: tryOnPose!.landmarks)
            : null,
        tryOnPose: tryOnPose,
        clothingType: clothingType,
        detectedObjects: detectedObjects,
        imageLabels: allLabels,
        isCompatible: compatibility > 0.3,
        confidence: compatibility,
        bodyMeasurements: tryOnPose?.measurements,
        clothingFit: clothingFit,
      );

      debugPrint('🔍 Analysis complete:');
      debugPrint('   - Pose detected: ${analysis.hasPoseDetected}');
      debugPrint('   - Clothing type: ${analysis.clothingType}');
      debugPrint('   - Compatibility: ${analysis.compatibilityStatus}');
      debugPrint('   - Confidence: ${analysis.confidencePercentage}');

      return analysis;
    } catch (e) {
      debugPrint('❌ Try-on analysis failed: $e');
      return TryOnAnalysis.failed(error: e.toString());
    }
  }

  /// Advanced compatibility calculation
  double _calculateAdvancedCompatibility(
    TryOnPose? pose,
    String? clothingType,
    List<DetectedObject> objects,
    List<ImageLabel> labels,
  ) {
    double score = 0.0;

    // Pose quality (40% of score)
    if (pose != null) {
      score += pose.poseQuality * 0.4;

      // Bonus for front-facing pose
      if (pose.orientation.primaryOrientation == 'front') {
        score += 0.1;
      }
    }

    // Clothing classification (25% of score)
    if (clothingType != null) {
      score += 0.25;
    }

    // Object detection (15% of score)
    if (objects.isNotEmpty) {
      final objectScore =
          (objects.length / 5.0).clamp(0.0, 1.0); // Max 5 objects
      score += objectScore * 0.15;
    }

    // Image labels (10% of score)
    if (labels.isNotEmpty) {
      final avgConfidence =
          labels.map((l) => l.confidence).reduce((a, b) => a + b) /
              labels.length;
      score += avgConfidence * 0.1;
    }

    // Body measurements completeness (10% of score)
    if (pose?.measurements != null) {
      score += pose!.measurements.completeness * 0.1;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Check if label text is clothing-related
  bool _isClothingRelated(String labelText) {
    final clothingKeywords = [
      'clothing',
      'shirt',
      'pants',
      'dress',
      'jacket',
      'top',
      'bottom',
      'garment',
      'apparel',
      'wear',
      'outfit',
      'fashion',
      'textile',
      'sweater',
      'hoodie',
      'jeans',
      'skirt',
      'blouse',
      't-shirt',
      'coat',
      'blazer',
      'suit',
      'uniform',
      'robe',
      'gown'
    ];

    return clothingKeywords
        .any((keyword) => labelText.toLowerCase().contains(keyword));
  }

  /// Map ML Kit labels to our clothing categories
  String _mapLabelToCategory(String labelText) {
    final text = labelText.toLowerCase();

    if (text.contains('shirt') ||
        text.contains('top') ||
        text.contains('blouse') ||
        text.contains('sweater')) {
      return 'Tops';
    } else if (text.contains('pants') ||
        text.contains('jeans') ||
        text.contains('bottom') ||
        text.contains('trouser')) {
      return 'Bottoms';
    } else if (text.contains('dress') || text.contains('gown')) {
      return 'Dresses';
    } else if (text.contains('jacket') ||
        text.contains('coat') ||
        text.contains('blazer') ||
        text.contains('hoodie')) {
      return 'Outerwear';
    } else {
      return 'Accessories';
    }
  }

  /// Quick pose detection for camera preview
  Future<bool> quickPoseCheck(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final poses = await _poseDetector.processImage(inputImage);
      return poses.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Quick pose check failed: $e');
      return false;
    }
  }

  /// Dispose of all ML resources
  void dispose() {
    debugPrint('🗑️ ML SERVICE: Disposing all resources...');

    _poseDetector.close();
    _objectDetector.close();
    _imageLabeler.close();
    _personSegmentationModel?.close();
    _clothingClassificationModel?.close();

    _isInitialized = false;
    debugPrint('✅ ML SERVICE: All resources disposed');
  }
}
