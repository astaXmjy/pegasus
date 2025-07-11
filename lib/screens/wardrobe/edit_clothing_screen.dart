import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/camera_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_card.dart';
import '../../models/clothing_item.dart';
import 'dart:io';

class EditClothingScreen extends StatefulWidget {
  final String itemId;

  const EditClothingScreen({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  State<EditClothingScreen> createState() => _EditClothingScreenState();
}

class _EditClothingScreenState extends State<EditClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Tops';
  final List<String> _selectedColors = [];
  final List<String> _selectedTags = [];
  File? _selectedImage;
  bool _isLoading = false;
  ClothingItem? _originalItem;

  final List<String> _categories = [
    'Tops',
    'Bottoms',
    'Outerwear',
    'Dresses',
    'Accessories'
  ];
  final List<String> _availableColors = [
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Orange',
    'Purple',
    'Pink',
    'Brown',
    'Black',
    'White',
    'Gray',
    'Navy',
    'Maroon',
    'Teal',
    'Olive'
  ];
  final List<String> _availableTags = [
    'casual',
    'formal',
    'sporty',
    'vintage',
    'modern',
    'comfortable',
    'elegant',
    'trendy',
    'classic',
    'summer',
    'winter',
    'party',
    'work'
  ];

  @override
  void initState() {
    super.initState();
    _loadItemData();
  }

  void _loadItemData() {
    final wardrobeProvider = context.read<WardrobeProvider>();
    _originalItem = wardrobeProvider.getClothingItemById(widget.itemId);

    if (_originalItem != null) {
      _nameController.text = _originalItem!.name;
      _selectedCategory = _originalItem!.category;
      _selectedColors.addAll(_originalItem!.colors);
      _selectedTags.addAll(_originalItem!.tags);

      // Set image if it's a file path
      if (!_originalItem!.imagePath.startsWith('http') &&
          !_originalItem!.imagePath.startsWith('assets/')) {
        _selectedImage = File(_originalItem!.imagePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_originalItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item Not Found')),
        body: const Center(
          child: Text('Clothing item not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Clothing Item'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveClothingItem,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading
                    ? AppColors.textSecondary
                    : AppColors.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: AppStyles.largePadding),
              _buildBasicInfoSection(),
              const SizedBox(height: AppStyles.largePadding),
              _buildCategorySection(),
              const SizedBox(height: AppStyles.largePadding),
              _buildColorsSection(),
              const SizedBox(height: AppStyles.largePadding),
              _buildTagsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Photo', style: AppStyles.titleTextStyle),
          const SizedBox(height: AppStyles.defaultPadding),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppStyles.cardBorderRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppStyles.cardBorderRadius),
              child: _buildCurrentImage(),
            ),
          ),
          const SizedBox(height: AppStyles.defaultPadding),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Camera',
                  icon: Icons.camera_alt,
                  onPressed: _takePhoto,
                ),
              ),
              const SizedBox(width: AppStyles.defaultPadding),
              Expanded(
                child: CustomButton(
                  text: 'Gallery',
                  icon: Icons.photo_library,
                  onPressed: _pickFromGallery,
                  isOutlined: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentImage() {
    // Priority: New selected image > Original file > Original network/asset image > Placeholder
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (_originalItem!.imagePath.startsWith('http')) {
      return Image.network(
        _originalItem!.imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    } else if (_originalItem!.imagePath.startsWith('assets/')) {
      return Image.asset(
        _originalItem!.imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    } else {
      return Image.file(
        File(_originalItem!.imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyles.cardBorderRadius),
        border: Border.all(color: AppColors.textSecondary),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate,
                size: 48, color: AppColors.textSecondary),
            SizedBox(height: 8),
            Text('Update photo', style: AppStyles.subtitleTextStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Basic Information', style: AppStyles.titleTextStyle),
          const SizedBox(height: AppStyles.defaultPadding),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Item Name',
              hintText: 'e.g., Blue Denim Jacket',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty == true ? 'Name is required' : null,
          ),
          const SizedBox(height: AppStyles.defaultPadding),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Brief description of the item',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category', style: AppStyles.titleTextStyle),
          const SizedBox(height: AppStyles.defaultPadding),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                backgroundColor: AppColors.cardDark,
                selectedColor: AppColors.primaryPurple,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorsSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Colors', style: AppStyles.titleTextStyle),
          const SizedBox(height: AppStyles.defaultPadding),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableColors.map((color) {
              final isSelected = _selectedColors.contains(color);
              return FilterChip(
                label: Text(color),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedColors.add(color);
                    } else {
                      _selectedColors.remove(color);
                    }
                  });
                },
                backgroundColor: AppColors.cardDark,
                selectedColor: AppColors.primaryPurple,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tags', style: AppStyles.titleTextStyle),
          const SizedBox(height: AppStyles.defaultPadding),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
                backgroundColor: AppColors.cardDark,
                selectedColor: AppColors.primaryPurple,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    final cameraProvider = context.read<CameraProvider>();
    final image = await cameraProvider.takePicture();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final cameraProvider = context.read<CameraProvider>();
    final image = await cameraProvider.pickFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveClothingItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final wardrobeProvider = context.read<WardrobeProvider>();

      // Create updated item
      final updatedItem = _originalItem!.copyWith(
        name: _nameController.text,
        category: _selectedCategory,
        imagePath: _selectedImage?.path ?? _originalItem!.imagePath,
        colors: _selectedColors,
        tags: _selectedTags,
      );

      // Update the item
      await wardrobeProvider.updateClothingItem(updatedItem);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clothing item updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating item: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
