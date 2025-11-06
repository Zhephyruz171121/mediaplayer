/// Enumeración de los tipos de medios soportados
enum MediaType { audio, video, image }

/// Extensión para obtener información adicional del tipo de medio
extension MediaTypeExtension on MediaType {
  /// Retorna las extensiones de archivo válidas para cada tipo
  static List<String> get audioExtensions => [
    'mp3',
    'wav',
    'aac',
    'm4a',
    'ogg',
    'flac',
  ];

  static List<String> get videoExtensions => [
    'mp4',
    'avi',
    'mkv',
    'mov',
    'wmv',
    'flv',
  ];

  static List<String> get imageExtensions => [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
  ];

  /// Retorna todas las extensiones soportadas
  static List<String> get allExtensions => [
    ...audioExtensions,
    ...videoExtensions,
    ...imageExtensions,
  ];

  /// Determina el tipo de medio basado en la extensión del archivo
  static MediaType? fromExtension(String extension) {
    final ext = extension.toLowerCase();
    if (audioExtensions.contains(ext)) return MediaType.audio;
    if (videoExtensions.contains(ext)) return MediaType.video;
    if (imageExtensions.contains(ext)) return MediaType.image;
    return null;
  }
}
