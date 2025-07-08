import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/user_preferences.dart';

class StorageService {
  static const String _clothingItemsKey = 'clothing_items';
  static const String _outfitsKey = 'outfits';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _recentlyViewedKey = 'recently_viewed';

  Future<List<ClothingItem>> getClothingItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_clothingItemsKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => ClothingItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error loading clothing items: $e');
      return [];
    }
  }

  Future<bool> saveClothingItems(List<ClothingItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString =
          json.encode(items.map((item) => item.toJson()).toList());
      return await prefs.setString(_clothingItemsKey, jsonString);
    } catch (e) {
      debugPrint('Error saving clothing items: $e');
      return false;
    }
  }

  Future<List<Outfit>> getOutfits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_outfitsKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => Outfit.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error loading outfits: $e');
      return [];
    }
  }

  Future<bool> saveOutfits(List<Outfit> outfits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString =
          json.encode(outfits.map((outfit) => outfit.toJson()).toList());
      return await prefs.setString(_outfitsKey, jsonString);
    } catch (e) {
      debugPrint('Error saving outfits: $e');
      return false;
    }
  }

  Future<UserPreferences?> getUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_userPreferencesKey);

      if (jsonString != null) {
        return UserPreferences.fromJson(json.decode(jsonString));
      }
      return null;
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
      return null;
    }
  }

  Future<bool> saveUserPreferences(UserPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(preferences.toJson());
      return await prefs.setString(_userPreferencesKey, jsonString);
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
      return false;
    }
  }

  Future<List<String>> getRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_recentlyViewedKey) ?? [];
    } catch (e) {
      debugPrint('Error loading recently viewed: $e');
      return [];
    }
  }

  Future<bool> addToRecentlyViewed(String itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recentlyViewed =
          prefs.getStringList(_recentlyViewedKey) ?? [];

      // Remove if already exists to avoid duplicates
      recentlyViewed.remove(itemId);
      // Add to beginning of list
      recentlyViewed.insert(0, itemId);
      // Keep only last 10 items
      if (recentlyViewed.length > 10) {
        recentlyViewed = recentlyViewed.take(10).toList();
      }

      return await prefs.setStringList(_recentlyViewedKey, recentlyViewed);
    } catch (e) {
      debugPrint('Error adding to recently viewed: $e');
      return false;
    }
  }

  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_clothingItemsKey);
      await prefs.remove(_outfitsKey);
      await prefs.remove(_userPreferencesKey);
      await prefs.remove(_recentlyViewedKey);
      return true;
    } catch (e) {
      debugPrint('Error clearing data: $e');
      return false;
    }
  }
}
