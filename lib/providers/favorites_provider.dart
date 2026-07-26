import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _storageKey = 'favorite_character_ids';

  Set<int> _favoriteIds = {};
  bool _isLoaded = false;

  Set<int> get favoriteIds => _favoriteIds;
  bool get isLoaded => _isLoaded;

  bool isFavorite(int id) => _favoriteIds.contains(id);

  Future<void> loadFavorites() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey) ?? [];
    _favoriteIds = saved.map((e) => int.parse(e)).toSet();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggleFavorite(int id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _favoriteIds.map((e) => e.toString()).toList(),
    );
  }
}