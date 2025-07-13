import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../providers/ml_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_card.dart';
import '../../models/ml_models.dart';
import 'dart:io';

class MLAnalysisScreen extends StatefulWidget {
  final File userImage;
  final File clothingImage;

  const MLAnalysisScreen({
    Key? key,
    required this.userImage,
    required this.clothingImage,
  }) : super(key: key);

  @override
  State<MLAnalysisScreen> createState() => _MLAnalysisScreenState();
}

class _MLAnalysisScreenState extends State<MLAnalysisScreen> {
  TryOnAnalysis? _analysis;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    final mlProvider = context.read<MLProvider>();
    final analysis = await mlProvider.analyzeTryOnCompatibility(
      widget.userImage,
      widget.clothingImage,
    );

    setState(() {
      _analysis = analysis;
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis'),
        actions: [
          if (_analysis != null)
            IconButton(
              onPressed: _shareAnalysis,
              icon: const Icon(Icons.share),
            ),
        ],
      ),
      body: _isAnalyzing
          ? _buildAnalyzingView()
          : _analysis != null
              ? _buildAnalysisResults()
              : _buildErrorView(),
    );
  }

  Widget _buildAnalyzingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: AppColors.primaryPurple,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'AI is analyzing your try-on...',
            style: AppStyles.titleTextStyle,
          ),
          SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: AppStyles.subtitleTextStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults() {
    final analysis = _analysis!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      child: Column(
        children: [
          _buildOverallScore(analysis),
          const SizedBox(height: AppStyles.largePadding),
          _buildImageComparison(),
          const SizedBox(height: AppStyles.largePadding),
          _buildDetailedAnalysis(analysis),
          const SizedBox(height: AppStyles.largePadding),
          _buildRecommendations(analysis),
          const SizedBox(height: AppStyles.largePadding),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildOverallScore(TryOnAnalysis analysis) {
    return CustomCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _getScoreColors(analysis.confidence),
                  ),
                ),
                child: Center(
                  child: Text(
                    analysis.confidencePercentage,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.compatibilityStatus,
                      style: AppStyles.titleTextStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Compatibility Score',
                      style: AppStyles.subtitleTextStyle,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: analysis.confidence,
                      backgroundColor: AppColors.cardDark,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(analysis.confidence),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (analysis.clothingType != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.checkroom, color: AppColors.primaryPurple),
                const SizedBox(width: 8),
                Text(
                  'Detected: ${analysis.clothingType}',
                  style: AppStyles.bodyTextStyle,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageComparison() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Images', style: AppStyles.titleTextStyle),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        widget.userImage,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Your Photo', style: AppStyles.captionTextStyle),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.add, color: AppColors.primaryPurple),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        widget.clothingImage,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Clothing Item',
                        style: AppStyles.captionTextStyle),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis(TryOnAnalysis analysis) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detailed Analysis', style: AppStyles.titleTextStyle),
          const SizedBox(height: 16),
          _buildAnalysisItem(
            'Pose Detection',
            analysis.hasPoseDetected ? 'Detected' : 'Not Detected',
            analysis.hasPoseDetected ? Icons.check_circle : Icons.error,
            analysis.hasPoseDetected ? AppColors.success : AppColors.error,
          ),
          if (analysis.tryOnPose != null) ...[
            _buildAnalysisItem(
              'Pose Quality',
              '${(analysis.tryOnPose!.poseQuality * 100).round()}%',
              Icons.fitness_center,
              _getScoreColor(analysis.tryOnPose!.poseQuality),
            ),
            _buildAnalysisItem(
              'Body Orientation',
              analysis.tryOnPose!.orientation.primaryOrientation.toUpperCase(),
              Icons.accessibility,
              AppColors.primaryPurple,
            ),
            if (analysis.tryOnPose!.measurements.completeness > 0)
              _buildAnalysisItem(
                'Measurements',
                '${(analysis.tryOnPose!.measurements.completeness * 100).round()}% Complete',
                Icons.straighten,
                _getScoreColor(analysis.tryOnPose!.measurements.completeness),
              ),
          ],
          _buildAnalysisItem(
            'Objects Detected',
            '${analysis.detectedObjects.length} items',
            Icons.search,
            AppColors.textSecondary,
          ),
          _buildAnalysisItem(
            'Image Labels',
            '${analysis.imageLabels.length} labels',
            Icons.label,
            AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(
      String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: AppStyles.bodyTextStyle),
          ),
          Text(
            value,
            style: AppStyles.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(TryOnAnalysis analysis) {
    List<String> recommendations = [];

    if (!analysis.hasPoseDetected) {
      recommendations.add('Take a clearer photo showing your full body');
    }

    if (analysis.tryOnPose?.orientation.primaryOrientation == 'side') {
      recommendations.add('Face the camera directly for better results');
    }

    if (analysis.tryOnPose?.measurements.completeness != null &&
        analysis.tryOnPose!.measurements.completeness < 0.7) {
      recommendations.add('Show more of your body for accurate fitting');
    }

    if (analysis.clothingFit?.fitRecommendations != null) {
      recommendations.addAll(analysis.clothingFit!.fitRecommendations);
    }

    if (recommendations.isEmpty) {
      recommendations.add('Great photo! Ready for virtual try-on');
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recommendations', style: AppStyles.titleTextStyle),
          const SizedBox(height: 16),
          ...recommendations
              .map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 6, right: 12),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(rec, style: AppStyles.bodyTextStyle),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'Proceed to Virtual Try-On',
          icon: Icons.preview,
          onPressed: _analysis?.isCompatible == true ? _proceedToTryOn : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Try Again',
                icon: Icons.refresh,
                onPressed: _retakePhoto,
                isOutlined: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Save Analysis',
                icon: Icons.save,
                onPressed: _saveAnalysis,
                isOutlined: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Analysis Failed',
            style: AppStyles.titleTextStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            'Unable to analyze the images',
            style: AppStyles.subtitleTextStyle,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Try Again',
            icon: Icons.refresh,
            onPressed: _startAnalysis,
          ),
        ],
      ),
    );
  }

  List<Color> _getScoreColors(double score) {
    if (score > 0.8) {
      return [AppColors.success, const Color(0xFF00E676)];
    } else if (score > 0.6) {
      return [AppColors.primaryPurple, AppColors.accentPink];
    } else if (score > 0.4) {
      return [AppColors.warning, const Color(0xFFFFB74D)];
    } else {
      return [AppColors.error, const Color(0xFFFF8A80)];
    }
  }

  Color _getScoreColor(double score) {
    if (score > 0.8) return AppColors.success;
    if (score > 0.6) return AppColors.primaryPurple;
    if (score > 0.4) return AppColors.warning;
    return AppColors.error;
  }

  void _proceedToTryOn() {
    // TODO: Navigate to virtual try-on screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Virtual try-on feature coming in Phase 3!'),
        backgroundColor: AppColors.primaryPurple,
      ),
    );
  }

  void _retakePhoto() {
    context.pop();
  }

  void _saveAnalysis() {
    // TODO: Save analysis to user's history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analysis saved to your history!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _shareAnalysis() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing feature coming soon!'),
        backgroundColor: AppColors.primaryPurple,
      ),
    );
  }
}
