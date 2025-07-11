import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../services/storage_service.dart';

class WardrobeProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<ClothingItem> _clothingItems = [];
  List<Outfit> _outfits = [];
  String _selectedCategory = 'All Items';
  bool _isLoading = false;

  List<ClothingItem> get clothingItems => _clothingItems;
  List<Outfit> get outfits => _outfits;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  List<ClothingItem> get filteredClothingItems {
    debugPrint('🔍 FILTERING: Category = $_selectedCategory');
    debugPrint('🔍 FILTERING: Total items = ${_clothingItems.length}');

    if (_selectedCategory == 'All Items') {
      debugPrint('🔍 FILTERING: Returning all ${_clothingItems.length} items');
      return _clothingItems;
    }

    final filtered = _clothingItems
        .where((item) =>
            item.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();

    debugPrint('🔍 FILTERING: Filtered to ${filtered.length} items');
    return filtered;
  }

  List<String> get categories => [
        'All Items',
        'Tops',
        'Bottoms',
        'Outerwear',
        'Dresses',
        'Accessories',
      ];

  // Initialize and load data
  Future<void> init() async {
    debugPrint('🚀 WARDROBE: Starting initialization...');
    await loadData();

    debugPrint(
        '📊 WARDROBE: After loading - ${_clothingItems.length} items found');

    // FORCE load sample data for testing (remove this later)
    if (_clothingItems.isEmpty) {
      debugPrint('📝 WARDROBE: No items found, loading sample data...');
      await _loadSampleData();
    } else {
      debugPrint('✅ WARDROBE: Found existing items, skipping sample data');
      // Print existing items for debugging
      for (var item in _clothingItems) {
        debugPrint('📦 EXISTING ITEM: ${item.name} (${item.category})');
      }
    }
  }

  // Load data from storage
  Future<void> loadData() async {
    debugPrint('💾 STORAGE: Loading data from SharedPreferences...');
    _isLoading = true;
    notifyListeners();

    try {
      _clothingItems = await _storage.getClothingItems();
      _outfits = await _storage.getOutfits();
      debugPrint('💾 STORAGE: Loaded ${_clothingItems.length} clothing items');
      debugPrint('💾 STORAGE: Loaded ${_outfits.length} outfits');
    } catch (e) {
      debugPrint('❌ STORAGE ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add clothing item
  Future<void> addClothingItem(ClothingItem item) async {
    debugPrint('➕ ADDING: ${item.name} to wardrobe');
    try {
      _clothingItems.add(item);
      await _storage.saveClothingItems(_clothingItems);
      debugPrint(
          '✅ ADDED: Item saved successfully. Total items: ${_clothingItems.length}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ ADD ERROR: $e');
      rethrow;
    }
  }

  // Update category filter
  void setSelectedCategory(String category) {
    debugPrint('🏷️ FILTER: Changing category to: $category');
    _selectedCategory = category;
    notifyListeners();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String itemId) async {
    debugPrint('❤️ FAVORITE: Toggling for item: $itemId');
    final index = _clothingItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _clothingItems[index] = _clothingItems[index].copyWith(
        isFavorite: !_clothingItems[index].isFavorite,
      );
      await _storage.saveClothingItems(_clothingItems);
      debugPrint('❤️ FAVORITE: Updated successfully');
      notifyListeners();
    } else {
      debugPrint('❌ FAVORITE: Item not found: $itemId');
    }
  }

  // Remove clothing item
  Future<void> removeClothingItem(String itemId) async {
    debugPrint('🗑️ REMOVING: Item $itemId');
    final oldCount = _clothingItems.length;
    _clothingItems.removeWhere((item) => item.id == itemId);
    await _storage.saveClothingItems(_clothingItems);
    debugPrint(
        '🗑️ REMOVED: Items reduced from $oldCount to ${_clothingItems.length}');
    notifyListeners();
  }

  // Add outfit
  Future<void> addOutfit(Outfit outfit) async {
    debugPrint('👗 OUTFIT: Adding ${outfit.name}');
    _outfits.add(outfit);
    await _storage.saveOutfits(_outfits);
    notifyListeners();
  }

  // Get clothing item by ID
  ClothingItem? getClothingItemById(String id) {
    try {
      final item = _clothingItems.firstWhere((item) => item.id == id);
      debugPrint('🔍 FOUND: Item ${item.name} by ID $id');
      return item;
    } catch (e) {
      debugPrint('❌ NOT FOUND: Item with ID $id');
      return null;
    }
  }

  // FORCE CLEAR DATA FOR TESTING
  Future<void> clearAllData() async {
    debugPrint('🧹 CLEARING: All wardrobe data');
    _clothingItems.clear();
    _outfits.clear();
    await _storage.clearAllData();
    notifyListeners();
    debugPrint('🧹 CLEARED: All data removed');
  }

  // Load sample data for demo
  Future<void> _loadSampleData() async {
    debugPrint('📝 SAMPLE DATA: Creating sample clothing items...');

    final sampleItems = [
      ClothingItem(
        name: 'Classic Denim Jacket',
        category: 'Outerwear',
        imagePath: 'assets/images/clothing/denim_jacket.jpg',
        colors: ['Blue', 'Indigo'],
        tags: ['casual', 'vintage', 'denim'],
        rating: 4.5,
      ),
      ClothingItem(
        name: 'Cotton T-Shirt',
        category: 'Tops',
        imagePath: 'assets/images/clothing/yellow_tshirt.jpg',
        colors: ['Yellow', 'Mustard'],
        tags: ['casual', 'comfortable', 'cotton'],
        rating: 4.2,
      ),
      ClothingItem(
        name: 'Athletic Joggers',
        category: 'Bottoms',
        imagePath: 'assets/images/clothing/black_joggers.jpg',
        colors: ['Black', 'Charcoal'],
        tags: ['sporty', 'comfortable', 'elastic'],
        rating: 4.0,
      ),
      ClothingItem(
        name: 'Summer Dress',
        category: 'Dresses',
        imagePath: 'assets/images/clothing/summer_dress.jpg',
        colors: ['Orange', 'Coral', 'Pink'],
        tags: ['elegant', 'summer', 'flowy'],
        rating: 4.8,
      ),
    ];

    debugPrint('📝 SAMPLE DATA: Adding ${sampleItems.length} items...');

    for (int i = 0; i < sampleItems.length; i++) {
      final item = sampleItems[i];
      debugPrint('📝 SAMPLE DATA: Adding item ${i + 1}: ${item.name}');
      await addClothingItem(item);
    }

    debugPrint('✅ SAMPLE DATA: All sample items added successfully!');
    debugPrint(
        '📊 FINAL COUNT: ${_clothingItems.length} total items in wardrobe');
  }

  Future<void> updateClothingItem(ClothingItem updatedItem) async {
    debugPrint('🔄 UPDATING: Clothing item ${updatedItem.name}');
    try {
      final index =
          _clothingItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _clothingItems[index] = updatedItem;
        await _storage.saveClothingItems(_clothingItems);
        debugPrint('✅ UPDATED: Item updated successfully');
        notifyListeners();
      } else {
        throw Exception('Item not found');
      }
    } catch (e) {
      debugPrint('❌ UPDATE ERROR: $e');
      rethrow;
    }
  }
}
