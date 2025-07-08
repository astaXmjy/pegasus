// lib/widgets/cards/clothing_item_card.dart - FIXED VERSION

import 'package:flutter/material.dart';
import '../../models/clothing_item.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../common/star_rating.dart';
import '../common/custom_card.dart';
import 'dart:io';

class ClothingItemCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ClothingItemCard({
    Key? key,
    required this.item,
    this.onTap,
    this.onFavorite,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section - FIXED: Added Flexible instead of Expanded
          Flexible(
            flex: 3,
            child: Container(
              width: double.infinity,
              height: 120, // FIXED: Added explicit height
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppStyles.cardBorderRadius),
                  topRight: Radius.circular(AppStyles.cardBorderRadius),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppStyles.cardBorderRadius),
                  topRight: Radius.circular(AppStyles.cardBorderRadius),
                ),
                child: _buildImage(),
              ),
            ),
          ),

          // Content section - FIXED: Reduced padding and font sizes
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(6.0), // FIXED: Reduced from 8.0
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // FIXED: Added this
                children: [
                  // Item name - FIXED: Reduced font size
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 12, // FIXED: Reduced from 14
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1, // FIXED: Reduced from 2
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2), // FIXED: Reduced from 4

                  // Category - FIXED: Smaller font
                  Text(
                    item.category,
                    style: const TextStyle(
                      fontSize: 10, // FIXED: Reduced from 12
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 4), // FIXED: Added small spacer

                  // Rating and actions - FIXED: Simplified layout
                  Row(
                    children: [
                      StarRating(
                        rating: item.rating,
                        size: 12, // FIXED: Reduced from 14
                      ),
                      const Spacer(),

                      // Action buttons - FIXED: Made smaller
                      if (onEdit != null || onDelete != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (onEdit != null)
                              InkWell(
                                onTap: onEdit,
                                child: const Icon(
                                  Icons.edit,
                                  size: 14, // FIXED: Reduced from 16
                                  color: AppColors.textSecondary,
                                ),
                              ),

                            if (onEdit != null && onDelete != null)
                              const SizedBox(
                                  width: 4), // FIXED: Reduced spacing

                            if (onDelete != null)
                              InkWell(
                                onTap: onDelete,
                                child: const Icon(
                                  Icons.delete_outline,
                                  size: 14, // FIXED: Reduced from 16
                                  color: AppColors.error,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (item.imagePath.startsWith('assets/')) {
      // Asset image
      return Image.asset(
        item.imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      // File image
      return Image.file(
        File(item.imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.cardDark,
      child: const Center(
        child: Icon(
          Icons.checkroom,
          size: 32, // FIXED: Reduced from 48
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
