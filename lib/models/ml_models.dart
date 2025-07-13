import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'dart:math';

/// Complete analysis result for virtual try-on
class TryOnAnalysis {
  final bool hasPoseDetected;
  final Pose? pose;
  final TryOnPose? tryOnPose;
  final String? clothingType;
  final List<DetectedObject> detectedObjects;
  final List<ImageLabel> imageLabels;
  final bool isCompatible;
  final double confidence;
  final String? errorMessage;
  final BodyMeasurements? bodyMeasurements;
  final ClothingFit? clothingFit;

  TryOnAnalysis({
    required this.hasPoseDetected,
    this.pose,
    this.tryOnPose,
    this.clothingType,
    required this.detectedObjects,
    required this.imageLabels,
    required this.isCompatible,
    required this.confidence,
    this.errorMessage,
    this.bodyMeasurements,
    this.clothingFit,
  });

  factory TryOnAnalysis.failed({String? error}) {
    return TryOnAnalysis(
      hasPoseDetected: false,
      pose: null,
      tryOnPose: null,
      clothingType: null,
      detectedObjects: [],
      imageLabels: [],
      isCompatible: false,
      confidence: 0.0,
      errorMessage: error ?? 'Analysis failed',
      bodyMeasurements: null,
      clothingFit: null,
    );
  }

  /// Get compatibility status as string
  String get compatibilityStatus {
    if (!isCompatible) return 'Not Suitable';
    if (confidence > 0.85) return 'Perfect Match';
    if (confidence > 0.70) return 'Great Fit';
    if (confidence > 0.55) return 'Good Fit';
    if (confidence > 0.40) return 'Fair Fit';
    return 'Poor Fit';
  }

  /// Get confidence as percentage
  String get confidencePercentage => '${(confidence * 100).round()}%';

  /// Get detailed analysis summary
  Map<String, dynamic> get analysisDetails => {
    'pose_detected': hasPoseDetected,
    'clothing_type': clothingType,
    'objects_count': detectedObjects.length,
    'labels_count': imageLabels.length,
    'compatibility': compatibilityStatus,
    'confidence': confidencePercentage,
    'body_measurements': bodyMeasurements?.toMap(),
    'clothing_fit': clothingFit?.toMap(),
  };
}

/// Enhanced pose data for virtual try-on
class TryOnPose {
  final Map<PoseLandmarkType, PoseLandmark> landmarks;
  final double confidence;
  final BodyMeasurements measurements;
  final PoseOrientation orientation;

  TryOnPose({
    required this.landmarks,
    required this.confidence,
    required this.measurements,
    required this.orientation,
  });

  factory TryOnPose.fromPose(Pose pose) {
    final measurements = BodyMeasurements.fromPose(pose);
    final orientation = PoseOrientation.fromPose(pose);

    return TryOnPose(
      landmarks: pose.landmarks,
      confidence: _calculatePoseConfidence(pose),
      measurements: measurements,
      orientation: orientation,
    );
  }

  static double _calculatePoseConfidence(Pose pose) {
    double totalConfidence = 0.0;
    int landmarkCount = 0;

    pose.landmarks.forEach((type, landmark) {
      totalConfidence += landmark.likelihood;
      landmarkCount++;
    });

    return landmarkCount > 0 ? totalConfidence / landmarkCount : 0.0;
  }

  /// Check if pose is suitable for try-on
  bool get isSuitableForTryOn {
    final requiredLandmarks = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
    ];

    final visibleLandmarks = requiredLandmarks.where((type) {
      final landmark = landmarks[type];
      return landmark != null && landmark.likelihood > 0.5;
    }).length;

    return visibleLandmarks >= 3; // At least 3 out of 4 key landmarks
  }

  /// Get pose quality score
  double get poseQuality {
    if (!isSuitableForTryOn) return 0.0;

    double quality = confidence * 0.4;
    quality += measurements.completeness * 0.3;
    quality += orientation.frontalScore * 0.3;

    return quality.clamp(0.0, 1.0);
  }
}

/// Body measurements extracted from pose
class BodyMeasurements {
  final double? shoulderWidth;
  final double? torsoHeight;
  final double? armLength;
  final double? hipWidth;
  final double? legLength;
  final double completeness;

  BodyMeasurements({
    this.shoulderWidth,
    this.torsoHeight,
    this.armLength,
    this.hipWidth,
    this.legLength,
    required this.completeness,
  });

  factory BodyMeasurements.fromPose(Pose pose) {
    final landmarks = pose.landmarks;

    // Calculate shoulder width
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    double? shoulderWidth;
    if (leftShoulder != null && rightShoulder != null) {
      shoulderWidth = _calculateDistance(leftShoulder, rightShoulder);
    }

    // Calculate torso height
    final leftShoulderForTorso = landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    double? torsoHeight;
    if (leftShoulderForTorso != null && leftHip != null) {
      torsoHeight = _calculateDistance(leftShoulderForTorso, leftHip);
    }

    // Calculate arm length (shoulder to wrist)
    final leftShoulderForArm = landmarks[PoseLandmarkType.leftShoulder];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    double? armLength;
    if (leftShoulderForArm != null && leftWrist != null) {
      armLength = _calculateDistance(leftShoulderForArm, leftWrist);
    }

    // Calculate hip width
    final leftHipForWidth = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    double? hipWidth;
    if (leftHipForWidth != null && rightHip != null) {
      hipWidth = _calculateDistance(leftHipForWidth, rightHip);
    }

    // Calculate leg length (hip to ankle)
    final leftHipForLeg = landmarks[PoseLandmarkType.leftHip];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    double? legLength;
    if (leftHipForLeg != null && leftAnkle != null) {
      legLength = _calculateDistance(leftHipForLeg, leftAnkle);
    }

    // Calculate completeness
    final measurements = [shoulderWidth, torsoHeight, armLength, hipWidth, legLength];
    final validMeasurements = measurements.where((m) => m != null).length;
    final completeness = validMeasurements / measurements.length;

    return BodyMeasurements(
      shoulderWidth: shoulderWidth,
      torsoHeight: torsoHeight,
      armLength: armLength,
      hipWidth: hipWidth,
      legLength: legLength,
      completeness: completeness,
    );
  }

  static double _calculateDistance(PoseLandmark p1, PoseLandmark p2) {
    final dx = p1.x - p2.x;
    final dy = p1.y - p2.y;
    return sqrt(dx * dx + dy * dy);
  }

  Map<String, dynamic> toMap() {
    return {
      'shoulder_width': shoulderWidth,
      'torso_height': torsoHeight,
      'arm_length': armLength,
      'hip_width': hipWidth,
      'leg_length': legLength,
      'completeness': completeness,
    };
  }
}

/// Pose orientation analysis
class PoseOrientation {
  final double frontFacing;
  final double sideFacing;
  final double backFacing;
  final String primaryOrientation;
  final double frontalScore;

  PoseOrientation({
    required this.frontFacing,
    required this.sideFacing,
    required this.backFacing,
    required this.primaryOrientation,
    required this.frontalScore,
  });

  factory PoseOrientation.fromPose(Pose pose) {
    final landmarks = pose.landmarks;

    // Analyze shoulder and hip visibility to determine orientation
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];

    double frontScore = 0.0;
    double sideScore = 0.0;

    // Front-facing indicators
    if (leftShoulder != null && rightShoulder != null) {
      final shoulderSymmetry = 1.0 - (leftShoulder.likelihood - rightShoulder.likelihood).abs();
      frontScore += shoulderSymmetry * 0.5;
    }

    if (leftHip != null && rightHip != null) {
      final hipSymmetry = 1.0 - (leftHip.likelihood - rightHip.likelihood).abs();
      frontScore += hipSymmetry * 0.5;
    }

    // Side-facing indicators (one side much more visible)
    if (leftShoulder != null && rightShoulder != null) {
      final shoulderAsymmetry = (leftShoulder.likelihood - rightShoulder.likelihood).abs();
      sideScore += shoulderAsymmetry * 0.5;
    }

    final backScore = 1.0 - frontScore - sideScore;

    String primaryOrientation;
    if (frontScore > sideScore && frontScore > backScore) {
      primaryOrientation = 'front';
    } else if (sideScore > backScore) {
      primaryOrientation = 'side';
    } else {
      primaryOrientation = 'back';
    }

    return PoseOrientation(
      frontFacing: frontScore.clamp(0.0, 1.0),
      sideFacing: sideScore.clamp(0.0, 1.0),
      backFacing: backScore.clamp(0.0, 1.0),
      primaryOrientation: primaryOrientation,
      frontalScore: frontScore.clamp(0.0, 1.0),
    );
  }
}

/// Clothing fit analysis
class ClothingFit {
  final String clothingType;
  final double sizeCompatibility;
  final double styleCompatibility;
  final List<String> fitRecommendations;

  ClothingFit({
    required this.clothingType,
    required this.sizeCompatibility,
    required this.styleCompatibility,
    required this.fitRecommendations,
  });

  factory ClothingFit.analyze(String clothingType, BodyMeasurements bodyMeasurements) {
    final recommendations = <String>[];
    double sizeCompat = 0.8; // Default good compatibility
    double styleCompat = 0.8;

    // Analyze fit based on clothing type and measurements
    switch (clothingType.toLowerCase()) {
      case 'tops':
      case 'shirt':
      case 't-shirt':
        if (bodyMeasurements.shoulderWidth != null && bodyMeasurements.torsoHeight != null) {
          sizeCompat = 0.9;
          recommendations.add('Great fit for tops');
        } else {
          recommendations.add('Take photo showing shoulders and torso');
        }
        break;

      case 'bottoms':
      case 'pants':
      case 'jeans':
        if (bodyMeasurements.hipWidth != null && bodyMeasurements.legLength != null) {
          sizeCompat = 0.85;
          recommendations.add('Good fit for bottoms');
        } else {
          recommendations.add('Show full legs for better fit analysis');
        }
        break;

      case 'dresses':
        if (bodyMeasurements.completeness > 0.8) {
          sizeCompat = 0.9;
          styleCompat = 0.9;
          recommendations.add('Excellent for dress try-on');
        } else {
          recommendations.add('Show full body for dress fitting');
        }
        break;

      case 'outerwear':
      case 'jacket':
        if (bodyMeasurements.shoulderWidth != null && bodyMeasurements.armLength != null) {
          sizeCompat = 0.85;
          recommendations.add('Good for jacket fitting');
        } else {
          recommendations.add('Extend arms for better jacket fit');
        }
        break;

      default:
        recommendations.add('General clothing fit analysis');
    }

    return ClothingFit(
      clothingType: clothingType,
      sizeCompatibility: sizeCompat,
      styleCompatibility: styleCompat,
      fitRecommendations: recommendations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clothing_type': clothingType,
      'size_compatibility': sizeCompatibility,
      'style_compatibility': styleCompatibility,
      'recommendations': fitRecommendations,
    };
  }
}