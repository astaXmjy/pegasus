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
    if (_selectedCategory == 'All Items') {
      return _clothingItems;
    }
    return _clothingItems
        .where((item) =>
            item.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  List<String> get categories => [
        'All Items',
        'Tops',
        'Bottoms',
        'Outerwear',
        'Dresses',
      ];

  // Initialize and load data
  Future<void> init() async {
    await loadData();
    await _loadSampleData(); // Add sample data for demo
  }

  // Load data from storage
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _clothingItems = await _storage.getClothingItems();
      _outfits = await _storage.getOutfits();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add clothing item
  Future<void> addClothingItem(ClothingItem item) async {
    _clothingItems.add(item);
    await _storage.saveClothingItems(_clothingItems);
    notifyListeners();
  }

  // Update category filter
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String itemId) async {
    final index = _clothingItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _clothingItems[index] = _clothingItems[index].copyWith(
        isFavorite: !_clothingItems[index].isFavorite,
      );
      await _storage.saveClothingItems(_clothingItems);
      notifyListeners();
    }
  }

  // Remove clothing item
  Future<void> removeClothingItem(String itemId) async {
    _clothingItems.removeWhere((item) => item.id == itemId);
    await _storage.saveClothingItems(_clothingItems);
    notifyListeners();
  }

  // Add outfit
  Future<void> addOutfit(Outfit outfit) async {
    _outfits.add(outfit);
    await _storage.saveOutfits(_outfits);
    notifyListeners();
  }

  // Get clothing item by ID
  ClothingItem? getClothingItemById(String id) {
    try {
      return _clothingItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Load sample data for demo
  Future<void> _loadSampleData() async {
    if (_clothingItems.isEmpty) {
      final sampleItems = [
        ClothingItem(
          name: 'Classic Denim Jacket',
          category: 'Outerwear',
          imagePath: 'assets/images/denim_jacket.jpg',
          colors: ['Blue', 'Indigo'],
          tags: ['casual', 'vintage', 'denim'],
          rating: 4.5,
        ),
        ClothingItem(
          name: 'Soft Cotton Crew-Neck T-Shirt',
          category: 'Tops',
          imagePath: 'assets/images/yellow_tshirt.jpg',
          colors: ['Yellow', 'Mustard'],
          tags: ['casual', 'comfortable', 'cotton'],
          rating: 4.2,
        ),
        ClothingItem(
          name: 'Sporty Jogger Pants',
          category: 'Bottoms',
          imagePath: 'assets/images/black_joggers.jpg',
          colors: ['Black', 'Charcoal'],
          tags: ['sporty', 'comfortable', 'elastic'],
          rating: 4.0,
        ),
        ClothingItem(
          name: 'Elegant Summer Maxi Dress',
          category: 'Dresses',
          imagePath: 'assets/images/summer_dress.jpg',
          colors: ['Orange', 'Coral', 'Pink'],
          tags: ['elegant', 'summer', 'flowy'],
          rating: 4.8,
        ),
      ];

      for (final item in sampleItems) {
        await addClothingItem(item);
      }
    }
  }
}
