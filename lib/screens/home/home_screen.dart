import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/camera_provider.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/cards/outfit_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        actions: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryPurple,
            child: const Icon(
              Icons.person,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUploadSection(),
            const SizedBox(height: AppStyles.largePadding),
            _buildFeaturedOutfitSection(),
            const SizedBox(height: AppStyles.largePadding),
            _buildPersonalizedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return CustomCard(
      child: Column(
        children: [
          const Text(
            AppStrings.unleashStyle,
            style: AppStyles.titleTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppStyles.smallPadding),
          const Text(
            AppStrings.uploadDescription,
            style: AppStyles.subtitleTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppStyles.defaultPadding),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: AppStrings.camera,
                  icon: Icons.camera_alt,
                  onPressed: _handleCameraPress,
                ),
              ),
              const SizedBox(width: AppStyles.defaultPadding),
              Expanded(
                child: CustomButton(
                  text: AppStrings.gallery,
                  icon: Icons.photo_library,
                  onPressed: _handleGalleryPress,
                  isOutlined: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedOutfitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.featuredOutfit,
              style: AppStyles.titleTextStyle,
            ),
            TextButton(
              onPressed: () => context.go('/recommendations'),
              child: const Text(
                AppStrings.seeAll,
                style: TextStyle(color: AppColors.primaryPurple),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.defaultPadding),
        CustomCard(
          height: 300,
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppStyles.cardBorderRadius),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gradientStart,
                      AppColors.gradientEnd,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: AppStyles.defaultPadding,
                left: AppStyles.defaultPadding,
                right: AppStyles.defaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Effortlessly chic and ready for any urban adventure.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get ready to turn heads with this effortlessly chic.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: AppStrings.tryItOn,
                      onPressed: () => context.go('/try-on'),
                      backgroundColor: Colors.white,
                      textColor: AppColors.primaryPurple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalizedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.personalizedForYou,
              style: AppStyles.titleTextStyle,
            ),
            TextButton(
              onPressed: () => context.go('/recommendations'),
              child: const Text(
                'More',
                style: TextStyle(color: AppColors.primaryPurple),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.defaultPadding),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: AppStyles.defaultPadding),
                child: CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft:
                                  Radius.circular(AppStyles.cardBorderRadius),
                              topRight:
                                  Radius.circular(AppStyles.cardBorderRadius),
                            ),
                            color: AppColors.backgroundDark.withOpacity(0.3),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.checkroom,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppStyles.smallPadding),
                        child: Column(
                          children: [
                            Text(
                              'Outfit ${index + 1}',
                              style: AppStyles.bodyTextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Perfect for casual days',
                              style: AppStyles.captionTextStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleCameraPress() async {
    final cameraProvider = context.read<CameraProvider>();
    await cameraProvider.initializeCamera();

    if (cameraProvider.isInitialized) {
      context.go('/try-on');
    } else {
      _showError('Camera initialization failed');
    }
  }

  void _handleGalleryPress() async {
    final cameraProvider = context.read<CameraProvider>();
    final image = await cameraProvider.pickFromGallery();

    if (image != null) {
      context.go('/try-on');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
