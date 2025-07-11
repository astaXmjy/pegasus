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
  final bool isCompact;
  final bool isSelected;
  final double? width;
  final double? height;

  const ClothingItemCard({
    Key? key,
    required this.item,
    this.onTap,
    this.onFavorite,
    this.onEdit,
    this.onDelete,
    this.isCompact = false,
    this.isSelected = false,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyles.cardBorderRadius),
        border: isSelected
            ? Border.all(color: AppColors.primaryPurple, width: 2)
            : null,
      ),
      child: CustomCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        backgroundColor: isSelected
            ? AppColors.primaryPurple.withOpacity(0.1)
            : AppColors.cardDark,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive dimensions based on available space
            final cardWidth = constraints.maxWidth;
            final cardHeight = constraints.maxHeight;

            // Determine if we're in compact mode based on available space
            final isAutoCompact = cardWidth < 140 || isCompact;

            // Calculate image height as percentage of total height
            final imageHeight = isAutoCompact
                ? (cardHeight * 0.65)
                    .clamp(60.0, 100.0) // 65% of height, min 60px, max 100px
                : (cardHeight * 0.70)
                    .clamp(100.0, 200.0); // 70% of height, min 100px, max 200px

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section - RESPONSIVE
                Flexible(
                  flex:
                      isAutoCompact ? 65 : 70, // 65% or 70% of available height
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: isAutoCompact ? 60 : 100,
                      maxHeight: imageHeight,
                    ),
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

                // Content section - RESPONSIVE
                Flexible(
                  flex:
                      isAutoCompact ? 35 : 30, // 35% or 30% of available height
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isAutoCompact ? 6.0 : 8.0),
                    child: _buildContent(cardWidth, isAutoCompact),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(double cardWidth, bool isAutoCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Item name - RESPONSIVE
        Flexible(
          flex: 2,
          child: Text(
            item.name,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                  cardWidth, isAutoCompact ? 10 : 13, isAutoCompact ? 12 : 15),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: isAutoCompact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        SizedBox(height: isAutoCompact ? 2 : 4),

        // Category - RESPONSIVE
        Flexible(
          flex: 1,
          child: Text(
            item.category,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                  cardWidth, isAutoCompact ? 8 : 11, isAutoCompact ? 10 : 13),
              color: AppColors.textSecondary,
            ),
          ),
        ),

        SizedBox(height: isAutoCompact ? 4 : 6),

        // Rating and actions - RESPONSIVE
        Flexible(
          flex: 1,
          child: Row(
            children: [
              // Rating - only show if there's enough space
              if (cardWidth > 100) ...[
                StarRating(
                  rating: item.rating,
                  size: _getResponsiveFontSize(cardWidth, 10, 14),
                ),
                const Spacer(),
              ],

              // Action buttons - only show if there's enough space and actions exist
              if (cardWidth > 120 && (onEdit != null || onDelete != null))
                _buildActionButtons(isAutoCompact),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isAutoCompact) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          InkWell(
            onTap: onEdit,
            child: Icon(
              Icons.edit,
              size: isAutoCompact ? 14 : 16,
              color: AppColors.textSecondary,
            ),
          ),
        if (onEdit != null && onDelete != null)
          SizedBox(width: isAutoCompact ? 4 : 6),
        if (onDelete != null)
          InkWell(
            onTap: onDelete,
            child: Icon(
              Icons.delete_outline,
              size: isAutoCompact ? 14 : 16,
              color: AppColors.error,
            ),
          ),
      ],
    );
  }

  double _getResponsiveFontSize(
      double cardWidth, double minSize, double maxSize) {
    // Scale font size based on card width
    final factor =
        (cardWidth / 180).clamp(0.7, 1.3); // 180px as reference width
    return (minSize + (maxSize - minSize) * factor).clamp(minSize, maxSize);
  }

  Widget _buildImage() {
    Widget imageWidget;

    if (item.imagePath.startsWith('assets/')) {
      imageWidget = Image.asset(
        item.imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ IMAGE ERROR: Failed to load asset ${item.imagePath}');
          return _buildPlaceholder();
        },
      );
    } else if (item.imagePath.startsWith('http')) {
      imageWidget = Image.network(
        item.imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: AppColors.primaryPurple,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint(
              '❌ IMAGE ERROR: Failed to load network image ${item.imagePath}');
          return _buildPlaceholder();
        },
      );
    } else {
      imageWidget = Image.file(
        File(item.imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ IMAGE ERROR: Failed to load file ${item.imagePath}');
          return _buildPlaceholder();
        },
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 120;
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.cardDark,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.checkroom,
                size: isSmall ? 24 : 40,
                color: AppColors.textSecondary,
              ),
              if (!isSmall) ...[
                const SizedBox(height: 4),
                Text(
                  item.category,
                  style: TextStyle(
                    fontSize: isSmall ? 8 : 10,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
