import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/camera_provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/cards/clothing_item_card.dart';

class TryOnScreen extends StatefulWidget {
  const TryOnScreen({Key? key}) : super(key: key);

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
    });
  }

  Future<void> _initializeCamera() async {
    final cameraProvider = context.read<CameraProvider>();
    if (!cameraProvider.isInitialized) {
      await cameraProvider.initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tryOn),
        actions: [
          IconButton(
            onPressed: _switchCamera,
            icon: const Icon(Icons.flip_camera_ios),
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera preview section
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

          // Wardrobe selection section
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppStyles.defaultPadding),
                  child: Text(
                    AppStrings.yourWardrobe,
                    style: AppStyles.titleTextStyle,
                  ),
                ),
                const SizedBox(height: AppStyles.defaultPadding),
                Expanded(
                  child: _buildWardrobeSelection(),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Column(
              children: [
                const Text(
                  AppStrings.fitAdjustments,
                  style: AppStyles.subtitleTextStyle,
                ),
                const SizedBox(height: AppStyles.smallPadding),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.captureTryOn,
                        icon: Icons.camera_alt,
                        onPressed: _captureTryOn,
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

  Widget _buildCameraPreview() {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        if (cameraProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPurple),
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

        return Stack(
          children: [
            CameraPreview(cameraProvider.controller!),

            // AI overlay placeholder
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primaryPurple.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'AI-Powered Virtual Try-On',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
        );
      },
    );
  }

  Widget _buildWardrobeSelection() {
    return Consumer<WardrobeProvider>(
      builder: (context, wardrobeProvider, child) {
        final items = wardrobeProvider.clothingItems.take(3).toList();

        if (items.isEmpty) {
          return const Center(
            child: Text(
              'No clothing items available',
              style: AppStyles.subtitleTextStyle,
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
                onTap: () => _selectClothingItem(item.id),
              ),
            );
          },
        );
      },
    );
  }

  void _switchCamera() {
    // TODO: Implement camera switching
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera switching coming soon!'),
        backgroundColor: AppColors.primaryPurple,
      ),
    );
  }

  void _selectClothingItem(String itemId) {
    // TODO: Implement clothing item selection for try-on
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Clothing item selected for try-on!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _captureTryOn() async {
    final cameraProvider = context.read<CameraProvider>();
    final image = await cameraProvider.takePicture();

    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Try-on captured successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to capture try-on'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _saveOutfit() {
    // TODO: Implement outfit saving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Outfit saved to favorites!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
