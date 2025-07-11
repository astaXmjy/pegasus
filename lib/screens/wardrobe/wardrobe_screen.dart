import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/wardrobe_provider.dart';
import '../../widgets/common/category_chips.dart';
import '../../widgets/cards/clothing_item_card.dart';
import 'package:go_router/go_router.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({Key? key}) : super(key: key);

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.yourWardrobe),
        actions: [
          // ADD THIS DEBUG BUTTON TEMPORARILY
          IconButton(
            onPressed: () {
              debugPrint('🧹 DEBUG: Clearing all data...');
              context.read<WardrobeProvider>().clearAllData();
            },
            icon: const Icon(Icons.delete_forever, color: Colors.red),
          ),
          IconButton(
            onPressed: _addNewClothing,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ADD THIS DEBUG INFO WIDGET
          Consumer<WardrobeProvider>(
            builder: (context, provider, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.blue.withOpacity(0.2),
                child: Text(
                  'DEBUG: ${provider.clothingItems.length} total items, '
                  '${provider.filteredClothingItems.length} filtered items, '
                  'Category: ${provider.selectedCategory}',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              );
            },
          ),

          const Padding(
            padding: EdgeInsets.only(
              left: AppStyles.defaultPadding,
              top: AppStyles.smallPadding,
            ),
            child: Text(
              AppStrings.categories,
              style: AppStyles.titleTextStyle,
            ),
          ),
          const SizedBox(height: AppStyles.smallPadding),
          _buildCategoryFilter(),
          const SizedBox(height: AppStyles.defaultPadding),
          Expanded(
            child: _buildClothingGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewClothing,
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<WardrobeProvider>(
      builder: (context, wardrobeProvider, child) {
        return CategoryChips(
          categories: wardrobeProvider.categories,
          selectedCategory: wardrobeProvider.selectedCategory,
          onCategorySelected: wardrobeProvider.setSelectedCategory,
        );
      },
    );
  }

  Widget _buildClothingGrid() {
    return Consumer<WardrobeProvider>(
      builder: (context, wardrobeProvider, child) {
        if (wardrobeProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPurple),
          );
        }

        final items = wardrobeProvider.filteredClothingItems;

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.checkroom,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No clothing items found',
                  style: AppStyles.titleTextStyle,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add some clothes to get started!',
                  style: AppStyles.subtitleTextStyle,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _addNewClothing,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Clothing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppStyles.defaultPadding),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: AppStyles.defaultPadding,
            crossAxisSpacing: AppStyles.defaultPadding,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ClothingItemCard(
                item: item,
                onTap: () => _viewClothingItem(item.id),
                onFavorite: () => _toggleFavorite(item.id),
                onEdit: () => _editClothingItem(item.id),
                onDelete: () => _deleteClothingItem(item.id),
              );
            },
          ),
        );
      },
    );
  }

  void _addNewClothing() {
    context.push('/wardrobe/add');
  }

  void _viewClothingItem(String itemId) {
    print("view_clothing");
    context.push('/wardrobe/item/$itemId');
  }

  void _toggleFavorite(String itemId) {
    context.read<WardrobeProvider>().toggleFavorite(itemId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favorite status updated!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _editClothingItem(String itemId) {
    context.push('/wardrobe/edit/${itemId}');
  }

  void _deleteClothingItem(String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Clothing Item'),
        content: const Text('Are you sure you want to delete this item?'),
        backgroundColor: AppColors.cardDark,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WardrobeProvider>().removeClothingItem(itemId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clothing item deleted!'),
                  backgroundColor: AppColors.error,
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
