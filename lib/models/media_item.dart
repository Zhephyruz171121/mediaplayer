import 'media_type.dart';

/// Modelo para los elementos multimedia
class MediaItem {
  final int? id;
  final String fileName;
  final String filePath;
  final MediaType mediaType;
  final Duration? duration;
  final DateTime addedAt;

  MediaItem({
    this.id,
    required this.fileName,
    required this.filePath,
    required this.mediaType,
    this.duration,
    required this.addedAt,
  });

  /// Crea una instancia desde un mapa (base de datos)
  factory MediaItem.fromMap(Map<String, dynamic> map) {
    final mediaTypeStr = map['media_type'] as String;
    MediaType mediaType;
    switch (mediaTypeStr) {
      case 'audio':
        mediaType = MediaType.audio;
        break;
      case 'video':
        mediaType = MediaType.video;
        break;
      case 'image':
        mediaType = MediaType.image;
        break;
      default:
        mediaType = MediaType.audio;
    }

    Duration? duration;
    if (map['duration'] != null) {
      duration = Duration(milliseconds: map['duration'] as int);
    }

    return MediaItem(
      id: map['id'] as int?,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      mediaType: mediaType,
      duration: duration,
      addedAt: DateTime.parse(map['added_at'] as String),
    );
  }

  /// Convierte la instancia a un mapa (para base de datos)
  Map<String, dynamic> toMap() {
    String mediaTypeStr;
    switch (mediaType) {
      case MediaType.audio:
        mediaTypeStr = 'audio';
        break;
      case MediaType.video:
        mediaTypeStr = 'video';
        break;
      case MediaType.image:
        mediaTypeStr = 'image';
        break;
    }

    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'media_type': mediaTypeStr,
      'duration': duration?.inMilliseconds,
      'added_at': addedAt.toIso8601String(),
    };
  }

  /// Crea una copia con campos actualizados
  MediaItem copyWith({
    int? id,
    String? fileName,
    String? filePath,
    MediaType? mediaType,
    Duration? duration,
    DateTime? addedAt,
  }) {
    return MediaItem(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      mediaType: mediaType ?? this.mediaType,
      duration: duration ?? this.duration,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
