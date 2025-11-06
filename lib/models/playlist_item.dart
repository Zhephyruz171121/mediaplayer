/// Modelo para la relación entre listas de reproducción y elementos multimedia
class PlaylistItem {
  final int? id;
  final int playlistId;
  final int mediaItemId;
  final int position;
  final DateTime addedAt;

  PlaylistItem({
    this.id,
    required this.playlistId,
    required this.mediaItemId,
    required this.position,
    required this.addedAt,
  });

  /// Crea una instancia desde un mapa (base de datos)
  factory PlaylistItem.fromMap(Map<String, dynamic> map) {
    return PlaylistItem(
      id: map['id'] as int?,
      playlistId: map['playlist_id'] as int,
      mediaItemId: map['media_item_id'] as int,
      position: map['position'] as int,
      addedAt: DateTime.parse(map['added_at'] as String),
    );
  }

  /// Convierte la instancia a un mapa (para base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playlist_id': playlistId,
      'media_item_id': mediaItemId,
      'position': position,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
