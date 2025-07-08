import 'package:flutter/material.dart';
import '../../models/outfit.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../common/star_rating.dart';
import '../common/custom_card.dart';
import '../common/custom_button.dart';
import 'dart:io';

class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback? onTap;
  final VoidCallback? onTryOn;
  final VoidCallback? onSave;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final bool showActions;
  final double? height;

  const OutfitCard({
    Key? key,
    required this.outfit,
    this.onTap,
    this.onTryOn,
    this.onSave,
    this.onLike,
    this.onDislike,
    this.showActions = true,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      height: height,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppStyles.cardBorderRadius),
                  topRight: Radius.circular(AppStyles.cardBorderRadius),
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppStyles.cardBorderRadius),
                      topRight: Radius.circular(AppStyles.cardBorderRadius),
                    ),
                    child: _buildImage(),
                  ),

                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Text overlay
                  Positioned(
                    bottom: AppStyles.smallPadding,
                    left: AppStyles.smallPadding,
                    right: AppStyles.smallPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          outfit.name,
                          style: AppStyles.bodyTextStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (outfit.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            outfit.description,
                            style: AppStyles.captionTextStyle.copyWith(
                              color: Colors.white70,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        StarRating(
                          rating: outfit.rating,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actions section
          if (showActions)
            Padding(
              padding: const EdgeInsets.all(AppStyles.smallPadding),
              child: Row(
                children: [
                  if (onTryOn != null)
                    Expanded(
                      child: CustomButton(
                        text: 'Try On',
                        onPressed: onTryOn,
                        height: 36,
                        icon: Icons.camera_alt,
                      ),
                    ),
                  if (onTryOn != null && onSave != null)
                    const SizedBox(width: 8),
                  if (onSave != null)
                    Expanded(
                      child: CustomButton(
                        text: 'Save',
                        onPressed: onSave,
                        height: 36,
                        icon: Icons.bookmark_border,
                        isOutlined: true,
                      ),
                    ),
                  if (onLike != null || onDislike != null) ...[
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        if (onLike != null)
                          IconButton(
                            onPressed: onLike,
                            icon: const Icon(Icons.thumb_up_outlined),
                            iconSize: 20,
                            color: AppColors.success,
                          ),
                        if (onDislike != null)
                          IconButton(
                            onPressed: onDislike,
                            icon: const Icon(Icons.thumb_down_outlined),
                            iconSize: 20,
                            color: AppColors.error,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (outfit.imagePath.startsWith('assets/')) {
      return Image.asset(
        outfit.imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      return Image.file(
        File(outfit.imagePath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.backgroundDark.withOpacity(0.5),
      child: const Center(
        child: Icon(
          Icons.checkroom,
          size: 48,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
