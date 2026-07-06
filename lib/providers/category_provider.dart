import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProvider extends ChangeNotifier {
  List<String> _categories = [
    'Work',
    'Personal',
    'Shopping',
    'Health',
    'Other',
  ];

  static const String _storageKey = 'categories';

  List<String> get categories => List.unmodifiable(_categories);

  // Load categories from storage
  Future<void> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? categoriesJson = prefs.getString(_storageKey);

      if (categoriesJson != null) {
        final List<dynamic> decoded = json.decode(categoriesJson);
        _categories = decoded.cast<String>();
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
    notifyListeners();
  }

  // Save categories to storage
  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String categoriesJson = json.encode(_categories);
      await prefs.setString(_storageKey, categoriesJson);
    } catch (e) {
      debugPrint('Error saving categories: $e');
    }
  }

  // Add a new category
  Future<bool> addCategory(String category) async {
    final trimmed = category.trim();
    if (trimmed.isEmpty || _categories.contains(trimmed)) {
      return false;
    }

    _categories.add(trimmed);
    _categories.sort();
    notifyListeners();
    await _saveCategories();
    return true;
  }

  // Update a category name
  Future<bool> updateCategory(String oldName, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || !_categories.contains(oldName)) {
      return false;
    }

    if (_categories.contains(trimmed) && trimmed != oldName) {
      return false;
    }

    final index = _categories.indexOf(oldName);
    _categories[index] = trimmed;
    _categories.sort();
    notifyListeners();
    await _saveCategories();
    return true;
  }

  // Delete a category
  Future<void> deleteCategory(String category) async {
    _categories.remove(category);
    notifyListeners();
    await _saveCategories();
  }
}
