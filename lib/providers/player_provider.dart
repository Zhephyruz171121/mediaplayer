import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';

/// Provider para gestionar el reproductor multimedia
class PlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Estado del reproductor
  String? _filePath;
  String? _fileName;
  MediaType? _mediaType;
  PlayerState? _playerState;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Lista de reproducción
  List<MediaItem>? _playlist;
  int _currentIndex = 0;

  // Getters
  String? get filePath => _filePath;
  String? get fileName => _fileName;
  MediaType? get mediaType => _mediaType;
  PlayerState? get playerState => _playerState;
  Duration get duration => _duration;
  Duration get position => _position;
  List<MediaItem>? get playlist => _playlist;
  int get currentIndex => _currentIndex;
  bool get hasFile => _filePath != null;
  bool get hasPlaylist => _playlist != null && _playlist!.isNotEmpty;
  bool get isPlaying => _playerState == PlayerState.playing;
  AudioPlayer get audioPlayer => _audioPlayer;

  PlayerProvider() {
    _setupListeners();
  }

  /// Configura los listeners del reproductor
  void _setupListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _playerState = state;
      notifyListeners();

      // Reproducción automática al terminar
      if (state == PlayerState.completed && hasPlaylist) {
        playNext();
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });
  }

  /// Carga un archivo
  void loadFile(
    String filePath,
    String fileName,
    MediaType mediaType, {
    List<MediaItem>? playlist,
    int initialIndex = 0,
  }) {
    _filePath = filePath;
    _fileName = fileName;
    _mediaType = mediaType;
    _playlist = playlist;
    _currentIndex = initialIndex;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  /// Reproduce
  Future<void> play() async {
    if (_filePath == null || _mediaType != MediaType.audio) return;
    await _audioPlayer.play(DeviceFileSource(_filePath!));
  }

  /// Pausa
  Future<void> pause() async {
    if (_mediaType != MediaType.audio) return;
    await _audioPlayer.pause();
  }

  /// Detiene
  Future<void> stop() async {
    if (_mediaType != MediaType.audio) return;
    await _audioPlayer.stop();
    _position = Duration.zero;
    notifyListeners();
  }

  /// Busca posición
  Future<void> seek(Duration position) async {
    if (_mediaType != MediaType.audio) return;
    await _audioPlayer.seek(position);
  }

  /// Adelanta 5 segundos
  Future<void> seekForward() async {
    final newPosition = _position + const Duration(seconds: 5);
    await seek(newPosition < _duration ? newPosition : _duration);
  }

  /// Retrocede 5 segundos
  Future<void> seekBackward() async {
    final newPosition = _position - const Duration(seconds: 5);
    await seek(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  /// Reproduce el siguiente elemento
  Future<void> playNext() async {
    if (!hasPlaylist) return;

    if (_currentIndex < _playlist!.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0; // Volver al inicio
    }
    await _loadAndPlayFromPlaylist(_currentIndex);
  }

  /// Reproduce el elemento anterior
  Future<void> playPrevious() async {
    if (!hasPlaylist) return;

    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _playlist!.length - 1; // Ir al último
    }
    await _loadAndPlayFromPlaylist(_currentIndex);
  }

  /// Carga y reproduce un elemento de la lista
  Future<bool> _loadAndPlayFromPlaylist(int index) async {
    if (!hasPlaylist || index < 0 || index >= _playlist!.length) {
      return false;
    }

    final item = _playlist![index];

    // Detener reproducción actual
    await stop();

    // Cargar nuevo archivo
    _filePath = item.filePath;
    _fileName = item.fileName;
    _mediaType = item.mediaType;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();

    // Reproducir si es audio
    if (_mediaType == MediaType.audio) {
      await play();
      return true;
    }

    return false;
  }

  /// Limpia el estado
  void clear() {
    stop();
    _filePath = null;
    _fileName = null;
    _mediaType = null;
    _playlist = null;
    _currentIndex = 0;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
