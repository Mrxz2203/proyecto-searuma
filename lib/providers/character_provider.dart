import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/uma_api_service.dart';

class CharacterProvider extends ChangeNotifier {
  final UmaApiService _apiService = UmaApiService();

  List<Character> _allCharacters = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;

  static const int itemsPerPage = 20;

  List<Character> get _filtered {
    if (_searchQuery.isEmpty) return _allCharacters;
    final query = _searchQuery.toLowerCase();
    return _allCharacters.where((c) => c.nameEn.toLowerCase().contains(query)).toList();
  }

  List<Character> get paginatedCharacters {
    final filtered = _filtered;
    final start = (_currentPage - 1) * itemsPerPage;
    if (start >= filtered.length) return [];
    final end = (start + itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  int get totalPages {
    final count = _filtered.length;
    if (count == 0) return 1;
    return (count / itemsPerPage).ceil();
  }

  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _allCharacters.length;

  Future<void> loadCharacters() async {
    if (_allCharacters.isNotEmpty) return; // evita recargar si ya hay datos
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allCharacters = await _apiService.fetchCharacterList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }
}