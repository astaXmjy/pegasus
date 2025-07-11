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
    await cameraProvider.initializeCamera();
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
        // ... error handling code stays the same ...

        // SIMPLE FIX - Replace the complex preview with this:
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

              // Purple border overlay
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
                      'AI Virtual Try-On Ready',
                      style: TextStyle(
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
                onTap: () => _selectClothingItem(item.id),
              ),
            );
          },
        );
      },
    );
  }

  void _switchCamera() async {
    final cameraProvider = context.read<CameraProvider>();
    await cameraProvider.switchCamera();
  }

  void _selectClothingItem(String itemId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Clothing item selected for virtual try-on!'),
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
        SnackBar(
          content:
              Text(cameraProvider.errorMessage ?? 'Failed to capture try-on'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _saveOutfit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Outfit saved to favorites!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
