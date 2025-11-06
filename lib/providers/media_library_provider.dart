import 'package:flutter/foundation.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';
import '../services/database_service.dart';

/// Provider para gestionar la biblioteca multimedia
class MediaLibraryProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<MediaItem> _allItems = [];
  List<MediaItem> _filteredItems = [];
  MediaType? _selectedFilter;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MediaItem> get items => _filteredItems;
  List<MediaItem> get allItems => _allItems;
  MediaType? get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasItems => _filteredItems.isNotEmpty;

  /// Carga todos los elementos de la biblioteca
  Future<void> loadLibrary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allItems = await _db.getAllMediaItems();
      _applyFilter();
    } catch (e) {
      _error = 'Error al cargar biblioteca: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filtra elementos por tipo
  void filterByType(MediaType? type) {
    _selectedFilter = type;
    _applyFilter();
    notifyListeners();
  }

  /// Aplica el filtro actual
  void _applyFilter() {
    if (_selectedFilter == null) {
      _filteredItems = List.from(_allItems);
    } else {
      _filteredItems = _allItems
          .where((item) => item.mediaType == _selectedFilter)
          .toList();
    }
  }

  /// Obtiene elementos por tipo
  Future<List<MediaItem>> getItemsByType(MediaType type) async {
    try {
      return await _db.getMediaItemsByType(type);
    } catch (e) {
      return [];
    }
  }

  /// Limpia el filtro
  void clearFilter() {
    _selectedFilter = null;
    _applyFilter();
    notifyListeners();
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Recarga la biblioteca
  Future<void> refresh() async {
    await loadLibrary();
  }
}
