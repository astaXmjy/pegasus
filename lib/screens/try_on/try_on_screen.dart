import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/camera_provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/ml_provider.dart'; // ADD THIS
import '../../widgets/common/custom_button.dart';
import '../../widgets/cards/clothing_item_card.dart';
import 'dart:io';

class TryOnScreen extends StatefulWidget {
  const TryOnScreen({Key? key}) : super(key: key);

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  String? selectedItemId; // ADD THIS - Track selected item
  bool _showMLAnalysis = false; // ADD THIS - Toggle ML overlay

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
      _initializeML(); // ADD THIS
    });
  }

  Future<void> _initializeCamera() async {
    final cameraProvider = context.read<CameraProvider>();
    await cameraProvider.initializeCamera();
  }

  // ADD THIS - Initialize ML services
  Future<void> _initializeML() async {
    final mlProvider = context.read<MLProvider>();
    if (!mlProvider.isInitialized) {
      await mlProvider.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tryOn),
        actions: [
          // ADD THIS - ML Analysis toggle button
          Consumer<MLProvider>(
            builder: (context, mlProvider, child) {
              return IconButton(
                onPressed: mlProvider.isInitialized ? _toggleMLAnalysis : null,
                icon: Icon(
                  _showMLAnalysis ? Icons.visibility_off : Icons.psychology,
                  color: _showMLAnalysis ? AppColors.primaryPurple : null,
                ),
                tooltip:
                    _showMLAnalysis ? 'Hide AI Analysis' : 'Show AI Analysis',
              );
            },
          ),
          IconButton(
            onPressed: _switchCamera,
            icon: const Icon(Icons.flip_camera_ios),
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera preview section - ENHANCED with ML
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppStyles.defaultPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppStyles.cardBorderRadius),
                color: AppColors.cardDark,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppStyles.cardBorderRadius),
                child: _buildCameraPreview(),
              ),
            ),
          ),

          // ADD THIS - ML Status Bar
          _buildMLStatusBar(),

          // Wardrobe selection section - ENHANCED with selection tracking
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppStyles.defaultPadding),
                  child: Row(
                    children: [
                      const Text(
                        AppStrings.yourWardrobe,
                        style: AppStyles.titleTextStyle,
                      ),
                      // ADD THIS - Selection indicator
                      if (selectedItemId != null) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Selected',
                            style: AppStyles.captionTextStyle.copyWith(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppStyles.defaultPadding),
                Expanded(
                  child: _buildWardrobeSelection(),
                ),
              ],
            ),
          ),

          // Action buttons - ENHANCED with ML features
          Padding(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Column(
              children: [
                // ADD THIS - Selected item display
                if (selectedItemId != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryPurple.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.checkroom,
                          color: AppColors.primaryPurple,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selected: ${_getSelectedItemName()}',
                            style: AppStyles.bodyTextStyle.copyWith(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _clearSelection,
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.primaryPurple,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Text(
                  AppStrings.fitAdjustments,
                  style: AppStyles.subtitleTextStyle,
                ),
                const SizedBox(height: AppStyles.smallPadding),
                Row(
                  children: [
                    Expanded(
                      child: Consumer<MLProvider>(
                        builder: (context, mlProvider, child) {
                          // ENHANCED - Show different button based on ML status
                          return CustomButton(
                            text: mlProvider.isInitialized &&
                                    selectedItemId != null
                                ? 'AI Analysis'
                                : AppStrings.captureTryOn,
                            icon: mlProvider.isInitialized &&
                                    selectedItemId != null
                                ? Icons.psychology
                                : Icons.camera_alt,
                            onPressed: mlProvider.isInitialized &&
                                    selectedItemId != null
                                ? _performAIAnalysis
                                : _captureTryOn,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppStyles.defaultPadding),
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.save,
                        icon: Icons.bookmark,
                        onPressed: _saveOutfit,
                        isOutlined: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ENHANCED - Camera preview with ML overlay
  Widget _buildCameraPreview() {
    return Consumer2<CameraProvider, MLProvider>(
      builder: (context, cameraProvider, mlProvider, child) {
        if (cameraProvider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryPurple),
                SizedBox(height: 16),
                Text('Initializing camera...',
                    style: AppStyles.subtitleTextStyle),
              ],
            ),
          );
        }

        if (cameraProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  cameraProvider.errorMessage!,
                  style: AppStyles.subtitleTextStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Retry',
                  onPressed: () => cameraProvider.initializeCamera(),
                ),
              ],
            ),
          );
        }

        if (!cameraProvider.isInitialized ||
            cameraProvider.controller == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'Camera not available',
                  style: AppStyles.subtitleTextStyle,
                ),
              ],
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppStyles.cardBorderRadius),
          child: Stack(
            children: [
              // Fill entire container
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width:
                        cameraProvider.controller!.value.previewSize?.height ??
                            1,
                    height:
                        cameraProvider.controller!.value.previewSize?.width ??
                            1,
                    child: CameraPreview(cameraProvider.controller!),
                  ),
                ),
              ),

              // ADD THIS - ML Analysis overlay
              if (_showMLAnalysis && mlProvider.isInitialized)
                Positioned.fill(
                  child: _buildMLOverlay(),
                ),

              // ENHANCED - Dynamic border overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _getBorderColor(mlProvider),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getOverlayText(mlProvider),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 4,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ADD THIS - ML Status Bar
  Widget _buildMLStatusBar() {
    return Consumer<MLProvider>(
      builder: (context, mlProvider, child) {
        if (mlProvider.isInitializing) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.cardDark,
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: mlProvider.initializationProgress,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Initializing AI... ${(mlProvider.initializationProgress * 100).round()}%',
                  style: AppStyles.captionTextStyle,
                ),
              ],
            ),
          );
        }

        if (!mlProvider.isInitialized) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.warning.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.warning, size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                const Text('AI not ready', style: AppStyles.captionTextStyle),
                const Spacer(),
                TextButton(
                  onPressed: () => mlProvider.initialize(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.success.withOpacity(0.1),
          child: Row(
            children: [
              const Icon(Icons.check_circle,
                  size: 16, color: AppColors.success),
              const SizedBox(width: 8),
              const Text('AI Ready for Analysis',
                  style: AppStyles.captionTextStyle),
              if (_showMLAnalysis) ...[
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Live Analysis',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ADD THIS - ML Analysis overlay
  Widget _buildMLOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.primaryPurple.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              color: AppColors.primaryPurple,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'AI Analysis Active',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 4,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ENHANCED - Wardrobe selection with visual feedback
  Widget _buildWardrobeSelection() {
    return Consumer<WardrobeProvider>(
      builder: (context, wardrobeProvider, child) {
        final items = wardrobeProvider.clothingItems.take(5).toList();

        if (items.isEmpty) {
          return const Center(
            child: Text(
              'No clothing items available.\nAdd some items to your wardrobe first!',
              style: AppStyles.subtitleTextStyle,
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding:
              const EdgeInsets.symmetric(horizontal: AppStyles.defaultPadding),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              width: 120,
              margin: const EdgeInsets.only(right: AppStyles.defaultPadding),
              child: ClothingItemCard(
                item: item,
                isCompact: true,
                isSelected: selectedItemId == item.id, // ADD THIS
                onTap: () => _selectClothingItem(item.id),
              ),
            );
          },
        );
      },
    );
  }

  // ADD THESE HELPER METHODS
  Color _getBorderColor(MLProvider mlProvider) {
    if (!mlProvider.isInitialized) {
      return AppColors.textSecondary.withOpacity(0.3);
    }
    if (selectedItemId != null) {
      return AppColors.success.withOpacity(0.7);
    }
    return AppColors.primaryPurple.withOpacity(0.5);
  }

  String _getOverlayText(MLProvider mlProvider) {
    if (!mlProvider.isInitialized) {
      return 'Camera Preview';
    }
    if (selectedItemId != null) {
      return 'Ready for AI Analysis';
    }
    return 'AI Virtual Try-On Ready';
  }

  String _getSelectedItemName() {
    if (selectedItemId == null) return '';
    final provider = context.read<WardrobeProvider>();
    final item = provider.getClothingItemById(selectedItemId!);
    return item?.name ?? '';
  }

  File? _getSelectedClothingImage() {
    if (selectedItemId == null) return null;
    final provider = context.read<WardrobeProvider>();
    final item = provider.getClothingItemById(selectedItemId!);
    if (item != null &&
        !item.imagePath.startsWith('http') &&
        !item.imagePath.startsWith('assets/')) {
      return File(item.imagePath);
    }
    return null;
  }

  // ADD THIS - Toggle ML analysis view
  void _toggleMLAnalysis() {
    setState(() {
      _showMLAnalysis = !_showMLAnalysis;
    });
  }

  // ADD THIS - Clear selection
  void _clearSelection() {
    setState(() {
      selectedItemId = null;
    });
  }

  void _switchCamera() async {
    final cameraProvider = context.read<CameraProvider>();
    await cameraProvider.switchCamera();
  }

  // ENHANCED - Select clothing item with visual feedback
  void _selectClothingItem(String itemId) {
    setState(() {
      selectedItemId = itemId;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Selected: ${_getSelectedItemName()} for virtual try-on!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Clear',
          textColor: Colors.white,
          onPressed: _clearSelection,
        ),
      ),
    );
  }

  // ADD THIS - AI Analysis function
  Future<void> _performAIAnalysis() async {
    if (selectedItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a clothing item first!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final cameraProvider = context.read<CameraProvider>();
    final mlProvider = context.read<MLProvider>();

    // Show progress
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Performing AI analysis...'),
          ],
        ),
        backgroundColor: AppColors.primaryPurple,
        duration: Duration(seconds: 3),
      ),
    );

    // Capture user image
    final userImage = await cameraProvider.takePicture();
    if (userImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to capture image'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Get selected clothing image
    final clothingImage = _getSelectedClothingImage();
    if (clothingImage == null) {
      // For demo, we'll use the user image as clothing image
      // In real implementation, you'd get the actual clothing image
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Using demo analysis...'),
          backgroundColor: AppColors.primaryPurple,
        ),
      );
    }

    // Perform quick analysis for demo
    try {
      final analysis = await mlProvider.analyzeTryOnCompatibility(
          userImage, clothingImage ?? userImage);

      if (analysis != null) {
        // Show quick results
        _showAnalysisResults(
            analysis.compatibilityStatus, analysis.confidencePercentage);
      } else {
        throw Exception('Analysis failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ADD THIS - Show analysis results
  void _showAnalysisResults(String status, String confidence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Row(
          children: [
            const Icon(Icons.psychology, color: AppColors.primaryPurple),
            const SizedBox(width: 8),
            const Text('AI Analysis Results'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compatibility: $status'),
            const SizedBox(height: 8),
            Text('Confidence: $confidence'),
            const SizedBox(height: 16),
            const Text(
              'This is a demo analysis. Full virtual try-on will be available in Phase 3!',
              style: AppStyles.captionTextStyle,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performVirtualTryOn();
            },
            child: const Text('Virtual Try-On'),
          ),
        ],
      ),
    );
  }

  // ADD THIS - Virtual try-on placeholder
  void _performVirtualTryOn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Virtual try-on feature coming in Phase 3!'),
        backgroundColor: AppColors.primaryPurple,
      ),
    );
  }

  // ENHANCED - Capture with selection validation
  void _captureTryOn() async {
    final cameraProvider = context.read<CameraProvider>();
    final image = await cameraProvider.takePicture();

    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(selectedItemId != null
              ? 'Try-on with ${_getSelectedItemName()} captured!'
              : 'Photo captured successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(cameraProvider.errorMessage ?? 'Failed to capture try-on'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ENHANCED - Save with selection info
  void _saveOutfit() {
    if (selectedItemId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Outfit with ${_getSelectedItemName()} saved to favorites!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a clothing item to save outfit!'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }
}
