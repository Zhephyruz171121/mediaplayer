import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/media_item.dart';
import '../models/media_type.dart';
import '../services/database_service.dart';

/// Provider para gestionar los elementos de una lista de reproducción
class PlaylistItemsProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  int? _playlistId;
  List<MediaItem> _items = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MediaItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasItems => _items.isNotEmpty;
  int get itemCount => _items.length;

  /// Establece la lista de reproducción actual
  void setPlaylist(int playlistId) {
    _playlistId = playlistId;
    loadItems();
  }

  /// Carga los elementos de la lista
  Future<void> loadItems() async {
    if (_playlistId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _db.getPlaylistMediaItems(_playlistId!);
    } catch (e) {
      _error = 'Error al cargar elementos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Añade un archivo a la lista
  Future<bool> addMediaItem(
    String fileName,
    String filePath,
    MediaType mediaType,
  ) async {
    if (_playlistId == null) return false;

    try {
      final mediaItem = MediaItem(
        fileName: fileName,
        filePath: filePath,
        mediaType: mediaType,
        addedAt: DateTime.now(),
      );

      final mediaItemId = await _db.createOrGetMediaItem(mediaItem);
      await _db.addItemToPlaylist(_playlistId!, mediaItemId);
      await loadItems();
      return true;
    } catch (e) {
      _error = 'Error al añadir archivo: $e';
      notifyListeners();
      return false;
    }
  }

  /// Añade un elemento existente a la lista
  Future<bool> addExistingMediaItem(int mediaItemId) async {
    if (_playlistId == null) return false;

    try {
      await _db.addItemToPlaylist(_playlistId!, mediaItemId);
      await loadItems();
      return true;
    } catch (e) {
      _error = 'Este archivo ya está en la lista';
      notifyListeners();
      return false;
    }
  }

  /// Elimina un elemento de la lista
  Future<bool> removeMediaItem(int mediaItemId) async {
    if (_playlistId == null) return false;

    try {
      await _db.removeItemFromPlaylist(_playlistId!, mediaItemId);
      await loadItems();
      return true;
    } catch (e) {
      _error = 'Error al eliminar elemento: $e';
      notifyListeners();
      return false;
    }
  }

  /// Reordena elementos en la lista
  Future<bool> reorderItems(int oldIndex, int newIndex) async {
    if (_playlistId == null) return false;

    try {
      // Actualizar UI inmediatamente
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
      notifyListeners();

      // Actualizar base de datos
      await _db.reorderPlaylistItem(_playlistId!, oldIndex, newIndex);
      return true;
    } catch (e) {
      _error = 'Error al reordenar: $e';
      // Recargar en caso de error
      await loadItems();
      return false;
    }
  }

  /// Verifica si un archivo existe
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Limpia el estado
  void clear() {
    _playlistId = null;
    _items = [];
    _error = null;
    notifyListeners();
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
