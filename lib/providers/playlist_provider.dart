import 'package:flutter/foundation.dart';
import '../models/playlist.dart';
import '../services/database_service.dart';

/// Provider para gestionar las listas de reproducción
class PlaylistProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<Playlist> _playlists = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPlaylists => _playlists.isNotEmpty;

  /// Carga todas las listas de reproducción
  Future<void> loadPlaylists() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _playlists = await _db.getPlaylists();
    } catch (e) {
      _error = 'Error al cargar listas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea una nueva lista de reproducción
  Future<bool> createPlaylist(String name, String description) async {
    try {
      final now = DateTime.now();
      final playlist = Playlist(
        name: name,
        description: description,
        createdAt: now,
        updatedAt: now,
      );

      await _db.createPlaylist(playlist);
      await loadPlaylists();
      return true;
    } catch (e) {
      _error = 'Error al crear lista: $e';
      notifyListeners();
      return false;
    }
  }

  /// Actualiza una lista de reproducción
  Future<bool> updatePlaylist(Playlist playlist) async {
    try {
      final updatedPlaylist = playlist.copyWith(updatedAt: DateTime.now());
      await _db.updatePlaylist(updatedPlaylist);
      await loadPlaylists();
      return true;
    } catch (e) {
      _error = 'Error al actualizar lista: $e';
      notifyListeners();
      return false;
    }
  }

  /// Elimina una lista de reproducción
  Future<bool> deletePlaylist(int id) async {
    try {
      await _db.deletePlaylist(id);
      await loadPlaylists();
      return true;
    } catch (e) {
      _error = 'Error al eliminar lista: $e';
      notifyListeners();
      return false;
    }
  }

  /// Obtiene el número de elementos en una lista
  Future<int> getPlaylistItemCount(int playlistId) async {
    try {
      return await _db.getPlaylistItemCount(playlistId);
    } catch (e) {
      return 0;
    }
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
