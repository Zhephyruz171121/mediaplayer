import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/playlist.dart';
import '../models/media_item.dart';
import '../models/playlist_item.dart';
import '../models/media_type.dart';

/// Servicio para gestionar la base de datos SQLite
class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._();

  DatabaseService._();

  /// Obtiene la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'mediaplayer.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  /// Crea las tablas de la base de datos
  Future<void> _onCreate(Database db, int version) async {
    // Tabla de listas de reproducción
    await db.execute('''
      CREATE TABLE playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla de elementos multimedia
    await db.execute('''
      CREATE TABLE media_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL UNIQUE,
        media_type TEXT NOT NULL,
        duration INTEGER,
        added_at TEXT NOT NULL
      )
    ''');

    // Tabla de relación entre listas y elementos
    await db.execute('''
      CREATE TABLE playlist_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlist_id INTEGER NOT NULL,
        media_item_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        added_at TEXT NOT NULL,
        FOREIGN KEY (playlist_id) REFERENCES playlists (id) ON DELETE CASCADE,
        FOREIGN KEY (media_item_id) REFERENCES media_items (id) ON DELETE CASCADE,
        UNIQUE (playlist_id, media_item_id)
      )
    ''');

    // Índices para mejorar el rendimiento
    await db.execute('''
      CREATE INDEX idx_playlist_items_playlist_id 
      ON playlist_items (playlist_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_playlist_items_position 
      ON playlist_items (playlist_id, position)
    ''');
  }

  // ========== OPERACIONES CON LISTAS DE REPRODUCCIÓN ==========

  /// Crea una nueva lista de reproducción
  Future<int> createPlaylist(Playlist playlist) async {
    final db = await database;
    return await db.insert('playlists', playlist.toMap());
  }

  /// Obtiene todas las listas de reproducción
  Future<List<Playlist>> getPlaylists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'playlists',
      orderBy: 'updated_at DESC',
    );
    return List.generate(maps.length, (i) => Playlist.fromMap(maps[i]));
  }

  /// Obtiene una lista de reproducción por ID
  Future<Playlist?> getPlaylistById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Playlist.fromMap(maps.first);
  }

  /// Actualiza una lista de reproducción
  Future<int> updatePlaylist(Playlist playlist) async {
    final db = await database;
    return await db.update(
      'playlists',
      playlist.toMap(),
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
  }

  /// Elimina una lista de reproducción
  Future<int> deletePlaylist(int id) async {
    final db = await database;
    return await db.delete('playlists', where: 'id = ?', whereArgs: [id]);
  }

  // ========== OPERACIONES CON ELEMENTOS MULTIMEDIA ==========

  /// Crea o obtiene un elemento multimedia
  Future<int> createOrGetMediaItem(MediaItem mediaItem) async {
    final db = await database;

    // Buscar si ya existe
    final existing = await db.query(
      'media_items',
      where: 'file_path = ?',
      whereArgs: [mediaItem.filePath],
    );

    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }

    // Si no existe, crear nuevo
    return await db.insert('media_items', mediaItem.toMap());
  }

  /// Obtiene todos los elementos multimedia
  Future<List<MediaItem>> getAllMediaItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'media_items',
      orderBy: 'added_at DESC',
    );
    return List.generate(maps.length, (i) => MediaItem.fromMap(maps[i]));
  }

  /// Obtiene elementos multimedia por tipo
  Future<List<MediaItem>> getMediaItemsByType(MediaType mediaType) async {
    final db = await database;
    String typeStr;
    switch (mediaType) {
      case MediaType.audio:
        typeStr = 'audio';
        break;
      case MediaType.video:
        typeStr = 'video';
        break;
      case MediaType.image:
        typeStr = 'image';
        break;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'media_items',
      where: 'media_type = ?',
      whereArgs: [typeStr],
      orderBy: 'added_at DESC',
    );
    return List.generate(maps.length, (i) => MediaItem.fromMap(maps[i]));
  }

  /// Elimina un elemento multimedia
  Future<int> deleteMediaItem(int id) async {
    final db = await database;
    return await db.delete('media_items', where: 'id = ?', whereArgs: [id]);
  }

  // ========== OPERACIONES CON ELEMENTOS DE LISTA ==========

  /// Añade un elemento a una lista de reproducción
  Future<int> addItemToPlaylist(int playlistId, int mediaItemId) async {
    final db = await database;

    // Obtener la posición máxima actual
    final result = await db.rawQuery(
      '''
      SELECT MAX(position) as max_position 
      FROM playlist_items 
      WHERE playlist_id = ?
    ''',
      [playlistId],
    );

    final maxPosition = result.first['max_position'] as int?;
    final newPosition = (maxPosition ?? -1) + 1;

    // Insertar el nuevo elemento
    final playlistItem = PlaylistItem(
      playlistId: playlistId,
      mediaItemId: mediaItemId,
      position: newPosition,
      addedAt: DateTime.now(),
    );

    // Actualizar fecha de modificación de la lista
    await db.update(
      'playlists',
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [playlistId],
    );

    return await db.insert('playlist_items', playlistItem.toMap());
  }

  /// Obtiene los elementos de una lista de reproducción con sus detalles
  Future<List<MediaItem>> getPlaylistMediaItems(int playlistId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT m.* 
      FROM media_items m
      INNER JOIN playlist_items pi ON m.id = pi.media_item_id
      WHERE pi.playlist_id = ?
      ORDER BY pi.position ASC
    ''',
      [playlistId],
    );

    return List.generate(maps.length, (i) => MediaItem.fromMap(maps[i]));
  }

  /// Elimina un elemento de una lista de reproducción
  Future<int> removeItemFromPlaylist(int playlistId, int mediaItemId) async {
    final db = await database;

    // Obtener la posición del elemento a eliminar
    final item = await db.query(
      'playlist_items',
      where: 'playlist_id = ? AND media_item_id = ?',
      whereArgs: [playlistId, mediaItemId],
    );

    if (item.isEmpty) return 0;

    final position = item.first['position'] as int;

    // Eliminar el elemento
    final deleted = await db.delete(
      'playlist_items',
      where: 'playlist_id = ? AND media_item_id = ?',
      whereArgs: [playlistId, mediaItemId],
    );

    // Reordenar las posiciones de los elementos restantes
    await db.rawUpdate(
      '''
      UPDATE playlist_items 
      SET position = position - 1
      WHERE playlist_id = ? AND position > ?
    ''',
      [playlistId, position],
    );

    // Actualizar fecha de modificación de la lista
    await db.update(
      'playlists',
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [playlistId],
    );

    return deleted;
  }

  /// Obtiene el número de elementos en una lista de reproducción
  Future<int> getPlaylistItemCount(int playlistId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count 
      FROM playlist_items 
      WHERE playlist_id = ?
    ''',
      [playlistId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Reordena un elemento en la lista de reproducción
  Future<void> reorderPlaylistItem(
    int playlistId,
    int oldPosition,
    int newPosition,
  ) async {
    final db = await database;

    if (oldPosition == newPosition) return;

    if (oldPosition < newPosition) {
      // Mover hacia abajo
      await db.rawUpdate(
        '''
        UPDATE playlist_items 
        SET position = position - 1
        WHERE playlist_id = ? AND position > ? AND position <= ?
      ''',
        [playlistId, oldPosition, newPosition],
      );
    } else {
      // Mover hacia arriba
      await db.rawUpdate(
        '''
        UPDATE playlist_items 
        SET position = position + 1
        WHERE playlist_id = ? AND position >= ? AND position < ?
      ''',
        [playlistId, newPosition, oldPosition],
      );
    }

    // Actualizar la posición del elemento movido
    await db.rawUpdate(
      '''
      UPDATE playlist_items 
      SET position = ?
      WHERE playlist_id = ? AND position = ?
    ''',
      [newPosition, playlistId, oldPosition],
    );

    // Actualizar fecha de modificación de la lista
    await db.update(
      'playlists',
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  /// Cierra la conexión con la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
