import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../providers/wardrobe_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/star_rating.dart';
import '../../models/clothing_item.dart';
import 'dart:io';

class ClothingDetailScreen extends StatelessWidget {
  final String itemId;

  const ClothingDetailScreen({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WardrobeProvider>(
      builder: (context, wardrobeProvider, child) {
        final item = wardrobeProvider.getClothingItemById(itemId);

        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Item Not Found')),
            body: const Center(
              child: Text('Clothing item not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(item.name),
            actions: [
              IconButton(
                onPressed: () => _editItem(context, item),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () => _deleteItem(context, item.id),
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(item),
                _buildDetailsSection(item),
                _buildActionsSection(context, item),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(ClothingItem item) {
    return Container(
      height: 400,
      width: double.infinity,
      child: item.imagePath.startsWith('assets/')
          ? Image.asset(
              item.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          : Image.file(
              File(item.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.cardDark,
      child: const Center(
        child: Icon(
          Icons.checkroom,
          size: 64,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDetailsSection(ClothingItem item) {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: AppStyles.titleTextStyle,
                ),
              ),
              IconButton(
                onPressed: () {}, // TODO: Implement favorite toggle
                icon: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: item.isFavorite
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.smallPadding),
          Text(
            item.category,
            style: AppStyles.subtitleTextStyle.copyWith(
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: AppStyles.defaultPadding),
          StarRating(rating: item.rating),
          const SizedBox(height: AppStyles.defaultPadding),
          if (item.colors.isNotEmpty) ...[
            const Text('Colors:', style: AppStyles.bodyTextStyle),
            const SizedBox(height: AppStyles.smallPadding),
            Wrap(
              spacing: 8,
              children: item.colors
                  .map((color) => Chip(
                        label: Text(color),
                        backgroundColor: AppColors.cardDark,
                        labelStyle:
                            const TextStyle(color: AppColors.textPrimary),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppStyles.defaultPadding),
          ],
          if (item.tags.isNotEmpty) ...[
            const Text('Tags:', style: AppStyles.bodyTextStyle),
            const SizedBox(height: AppStyles.smallPadding),
            Wrap(
              spacing: 8,
              children: item.tags
                  .map((tag) => Chip(
                        label: Text('#$tag'),
                        backgroundColor:
                            AppColors.primaryPurple.withOpacity(0.2),
                        labelStyle:
                            const TextStyle(color: AppColors.primaryPurple),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, ClothingItem item) {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      child: Column(
        children: [
          CustomButton(
            text: 'Try On This Item',
            icon: Icons.camera_alt,
            onPressed: () {
              // TODO: Navigate to try-on with this item
              context.go('/try-on');
            },
          ),
          const SizedBox(height: AppStyles.defaultPadding),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Create Outfit',
                  icon: Icons.add,
                  onPressed: () {
                    // TODO: Navigate to outfit creation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Outfit creation coming soon!')),
                    );
                  },
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: AppStyles.defaultPadding),
              Expanded(
                child: CustomButton(
                  text: 'Find Similar',
                  icon: Icons.search,
                  onPressed: () {
                    // TODO: Implement similar item search
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Similar search coming soon!')),
                    );
                  },
                  isOutlined: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editItem(BuildContext context, ClothingItem item) {
    // TODO: Navigate to edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon!')),
    );
  }

  void _deleteItem(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content:
            const Text('Are you sure you want to delete this clothing item?'),
        backgroundColor: AppColors.cardDark,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WardrobeProvider>().removeClothingItem(itemId);
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to wardrobe
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item deleted successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
