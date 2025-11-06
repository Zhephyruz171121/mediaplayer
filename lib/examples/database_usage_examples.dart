import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';
import '../services/database_service.dart';

/// Ejemplos de uso de la base de datos SQLite
/// Este archivo demuestra cómo usar las diferentes funciones del DatabaseService
class DatabaseUsageExamples {
  final DatabaseService _db = DatabaseService.instance;

  /// Ejemplo 1: Crear una nueva lista de reproducción
  Future<void> createPlaylistExample() async {
    final now = DateTime.now();
    final playlist = Playlist(
      name: 'Mi Lista Favorita',
      description: 'Las mejores canciones',
      createdAt: now,
      updatedAt: now,
    );

    final playlistId = await _db.createPlaylist(playlist);
    debugPrint('Lista creada con ID: $playlistId');
  }

  /// Ejemplo 2: Obtener todas las listas de reproducción
  Future<void> getAllPlaylistsExample() async {
    final playlists = await _db.getPlaylists();

    debugPrint('Total de listas: ${playlists.length}');
    for (var playlist in playlists) {
      debugPrint('- ${playlist.name}: ${playlist.description}');
    }
  }

  /// Ejemplo 3: Crear un elemento multimedia
  Future<void> createMediaItemExample() async {
    final mediaItem = MediaItem(
      fileName: 'cancion.mp3',
      filePath: '/storage/emulated/0/Music/cancion.mp3',
      mediaType: MediaType.audio,
      duration: const Duration(minutes: 3, seconds: 45),
      addedAt: DateTime.now(),
    );

    final mediaItemId = await _db.createOrGetMediaItem(mediaItem);
    debugPrint('Elemento multimedia creado con ID: $mediaItemId');
  }

  /// Ejemplo 4: Añadir elemento a una lista de reproducción
  Future<void> addItemToPlaylistExample(int playlistId, int mediaItemId) async {
    await _db.addItemToPlaylist(playlistId, mediaItemId);
    debugPrint('Elemento añadido a la lista');
  }

  /// Ejemplo 5: Obtener elementos de una lista
  Future<void> getPlaylistItemsExample(int playlistId) async {
    final items = await _db.getPlaylistMediaItems(playlistId);

    debugPrint('Elementos en la lista:');
    for (var item in items) {
      debugPrint('- ${item.fileName} (${item.mediaType})');
    }
  }

  /// Ejemplo 6: Obtener elementos por tipo
  Future<void> getAudioFilesExample() async {
    final audioFiles = await _db.getMediaItemsByType(MediaType.audio);

    debugPrint('Archivos de audio: ${audioFiles.length}');
    for (var audio in audioFiles) {
      debugPrint('- ${audio.fileName}');
    }
  }

  /// Ejemplo 7: Actualizar una lista de reproducción
  Future<void> updatePlaylistExample(Playlist playlist) async {
    final updatedPlaylist = playlist.copyWith(
      name: 'Nombre Actualizado',
      description: 'Nueva descripción',
      updatedAt: DateTime.now(),
    );

    await _db.updatePlaylist(updatedPlaylist);
    debugPrint('Lista actualizada');
  }

  /// Ejemplo 8: Reordenar elementos en una lista
  Future<void> reorderItemsExample(int playlistId) async {
    // Mover el elemento en posición 0 a la posición 2
    await _db.reorderPlaylistItem(playlistId, 0, 2);
    debugPrint('Elementos reordenados');
  }

  /// Ejemplo 9: Contar elementos en una lista
  Future<void> countItemsExample(int playlistId) async {
    final count = await _db.getPlaylistItemCount(playlistId);
    debugPrint('La lista tiene $count elementos');
  }

  /// Ejemplo 10: Eliminar elemento de una lista
  Future<void> removeItemExample(int playlistId, int mediaItemId) async {
    await _db.removeItemFromPlaylist(playlistId, mediaItemId);
    debugPrint('Elemento eliminado de la lista');
  }

  /// Ejemplo 11: Eliminar una lista completa
  Future<void> deletePlaylistExample(int playlistId) async {
    await _db.deletePlaylist(playlistId);
    debugPrint('Lista eliminada');
  }

  /// Ejemplo 12: Flujo completo - Crear lista y añadir elementos
  Future<void> completeWorkflowExample() async {
    try {
      // 1. Crear lista de reproducción
      final now = DateTime.now();
      final playlist = Playlist(
        name: 'Rock Clásico',
        description: 'Las mejores canciones de rock',
        createdAt: now,
        updatedAt: now,
      );
      final playlistId = await _db.createPlaylist(playlist);
      debugPrint('✓ Lista creada: ID $playlistId');

      // 2. Crear elementos multimedia
      final songs = [
        MediaItem(
          fileName: 'Bohemian Rhapsody.mp3',
          filePath: '/storage/music/bohemian.mp3',
          mediaType: MediaType.audio,
          duration: const Duration(minutes: 5, seconds: 55),
          addedAt: DateTime.now(),
        ),
        MediaItem(
          fileName: 'Stairway to Heaven.mp3',
          filePath: '/storage/music/stairway.mp3',
          mediaType: MediaType.audio,
          duration: const Duration(minutes: 8, seconds: 2),
          addedAt: DateTime.now(),
        ),
        MediaItem(
          fileName: 'Hotel California.mp3',
          filePath: '/storage/music/hotel.mp3',
          mediaType: MediaType.audio,
          duration: const Duration(minutes: 6, seconds: 30),
          addedAt: DateTime.now(),
        ),
      ];

      // 3. Añadir cada canción a la lista
      for (var song in songs) {
        final mediaItemId = await _db.createOrGetMediaItem(song);
        await _db.addItemToPlaylist(playlistId, mediaItemId);
        debugPrint('✓ Añadida: ${song.fileName}');
      }

      // 4. Verificar el resultado
      final items = await _db.getPlaylistMediaItems(playlistId);
      debugPrint('\n📋 Lista final con ${items.length} canciones:');
      for (var i = 0; i < items.length; i++) {
        debugPrint('${i + 1}. ${items[i].fileName}');
      }

      debugPrint('\n✅ Flujo completado exitosamente!');
    } catch (e) {
      debugPrint('❌ Error en el flujo: $e');
    }
  }

  /// Ejemplo 13: Obtener una lista específica por ID
  Future<void> getPlaylistByIdExample(int playlistId) async {
    final playlist = await _db.getPlaylistById(playlistId);

    if (playlist != null) {
      debugPrint('Lista encontrada:');
      debugPrint('- Nombre: ${playlist.name}');
      debugPrint('- Descripción: ${playlist.description}');
      debugPrint('- Creada: ${playlist.createdAt}');
      debugPrint('- Actualizada: ${playlist.updatedAt}');
    } else {
      debugPrint('Lista no encontrada');
    }
  }

  /// Ejemplo 14: Gestionar diferentes tipos de medios
  Future<void> mixedMediaPlaylistExample() async {
    try {
      // Crear lista mixta
      final now = DateTime.now();
      final playlist = Playlist(
        name: 'Multimedia Mix',
        description: 'Audio, video e imágenes',
        createdAt: now,
        updatedAt: now,
      );
      final playlistId = await _db.createPlaylist(playlist);

      // Crear elementos de diferentes tipos
      final items = [
        MediaItem(
          fileName: 'song.mp3',
          filePath: '/storage/music/song.mp3',
          mediaType: MediaType.audio,
          addedAt: DateTime.now(),
        ),
        MediaItem(
          fileName: 'video.mp4',
          filePath: '/storage/videos/video.mp4',
          mediaType: MediaType.video,
          addedAt: DateTime.now(),
        ),
        MediaItem(
          fileName: 'photo.jpg',
          filePath: '/storage/pictures/photo.jpg',
          mediaType: MediaType.image,
          addedAt: DateTime.now(),
        ),
      ];

      // Añadir todos los elementos
      for (var item in items) {
        final mediaItemId = await _db.createOrGetMediaItem(item);
        await _db.addItemToPlaylist(playlistId, mediaItemId);
      }

      debugPrint('✓ Lista multimedia creada con éxito');

      // Obtener estadísticas por tipo
      final audioCount = (await _db.getMediaItemsByType(
        MediaType.audio,
      )).length;
      final videoCount = (await _db.getMediaItemsByType(
        MediaType.video,
      )).length;
      final imageCount = (await _db.getMediaItemsByType(
        MediaType.image,
      )).length;

      debugPrint('Estadísticas de la biblioteca:');
      debugPrint('- Audio: $audioCount');
      debugPrint('- Video: $videoCount');
      debugPrint('- Imágenes: $imageCount');
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }
}
