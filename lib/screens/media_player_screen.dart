import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';

import '../models/media_type.dart';
import '../models/media_item.dart';
import '../services/permission_service.dart';
import '../services/file_picker_service.dart';
import '../widgets/audio_display.dart';
import '../widgets/video_display.dart';
import '../widgets/image_display.dart';
import '../widgets/empty_media_display.dart';
import '../widgets/media_control_panel.dart';
import '../widgets/audio_progress_bar.dart';
import 'playlists_screen.dart';

/// Pantalla principal del reproductor multimedia
class MediaPlayerScreen extends StatefulWidget {
  final String? filePath;
  final String? fileName;
  final MediaType? mediaType;
  final List<MediaItem>? playlist;
  final int? initialIndex;

  const MediaPlayerScreen({
    super.key,
    this.filePath,
    this.fileName,
    this.mediaType,
    this.playlist,
    this.initialIndex,
  });

  @override
  State<MediaPlayerScreen> createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  // Reproductor de audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState? _playerState;

  // Información del archivo
  String? _filePath;
  String? _fileName;
  MediaType? _mediaType;

  // Reproductor de video
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // Progreso del audio
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Lista de reproducción
  List<MediaItem>? _playlist;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAudioListeners();

    // Configurar lista de reproducción si existe
    _playlist = widget.playlist;
    _currentIndex = widget.initialIndex ?? 0;

    // Si se proporcionaron datos iniciales, cargarlos
    if (widget.filePath != null &&
        widget.fileName != null &&
        widget.mediaType != null) {
      _filePath = widget.filePath;
      _fileName = widget.fileName;
      _mediaType = widget.mediaType;

      // Iniciar reproducción según el tipo
      Future.delayed(Duration.zero, () {
        if (_mediaType == MediaType.audio) {
          _play();
        } else if (_mediaType == MediaType.video) {
          _initializeVideo();
        }
      });
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  /// Configura los listeners del reproductor de audio
  void _setupAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() => _playerState = state);

      // Si terminó de reproducir y hay una lista, reproducir siguiente
      if (state == PlayerState.completed &&
          _playlist != null &&
          _playlist!.isNotEmpty) {
        _playNext();
      }
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() => _position = position);
    });
  }

  /// Libera los recursos de los controladores
  void _disposeControllers() {
    _audioPlayer.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
  }

  /// Abre el selector de archivos
  Future<void> _pickFile() async {
    // Solicitar permisos
    final hasPermission = await PermissionService.requestAudioPermission();
    if (!hasPermission) {
      _showPermissionDeniedMessage();
      return;
    }

    // Seleccionar archivo
    final result = await FilePickerService.pickMediaFile();
    if (result == null) return;

    // Detener reproducción anterior
    await _stop();

    // Actualizar estado
    setState(() {
      _filePath = result.filePath;
      _fileName = result.fileName;
      _mediaType = result.mediaType;
    });

    // Iniciar reproducción según el tipo
    if (_mediaType == MediaType.audio) {
      await _play();
    } else if (_mediaType == MediaType.video) {
      await _initializeVideo();
    }
  }

  /// Muestra mensaje de permiso denegado
  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permiso denegado para acceder a archivos.'),
      ),
    );
  }

  /// Inicializa el reproductor de video
  Future<void> _initializeVideo() async {
    if (_filePath == null) return;

    _videoPlayerController = VideoPlayerController.file(File(_filePath!));
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
    );

    setState(() {});
  }

  /// Inicia o reanuda la reproducción
  Future<void> _play() async {
    if (_filePath == null) return;

    if (_mediaType == MediaType.audio) {
      await _audioPlayer.play(DeviceFileSource(_filePath!));
    } else if (_mediaType == MediaType.video &&
        _videoPlayerController != null) {
      _videoPlayerController!.play();
    }
  }

  /// Pausa la reproducción
  Future<void> _pause() async {
    if (_mediaType == MediaType.audio) {
      await _audioPlayer.pause();
    } else if (_mediaType == MediaType.video &&
        _videoPlayerController != null) {
      _videoPlayerController!.pause();
    }
  }

  /// Detiene la reproducción
  Future<void> _stop() async {
    if (_mediaType == MediaType.audio) {
      await _audioPlayer.stop();
    } else if (_mediaType == MediaType.video) {
      _videoPlayerController?.pause();
      _videoPlayerController?.dispose();
      _chewieController?.dispose();
      _videoPlayerController = null;
      _chewieController = null;
    }

    setState(() {
      _fileName = null;
      _filePath = null;
      _mediaType = null;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
  }

  /// Adelanta 5 segundos
  Future<void> _seekForward() async {
    const seekDuration = Duration(seconds: 5);

    if (_mediaType == MediaType.audio) {
      final newPosition = _position + seekDuration;
      await _audioPlayer.seek(
        newPosition < _duration ? newPosition : _duration,
      );
    } else if (_mediaType == MediaType.video &&
        _videoPlayerController != null) {
      final currentPosition = await _videoPlayerController!.position;
      if (currentPosition != null) {
        final newPosition = currentPosition + seekDuration;
        final maxDuration = _videoPlayerController!.value.duration;
        await _videoPlayerController!.seekTo(
          newPosition < maxDuration ? newPosition : maxDuration,
        );
      }
    }
  }

  /// Atrasa 5 segundos
  Future<void> _seekBackward() async {
    const seekDuration = Duration(seconds: 5);

    if (_mediaType == MediaType.audio) {
      final newPosition = _position - seekDuration;
      await _audioPlayer.seek(
        newPosition > Duration.zero ? newPosition : Duration.zero,
      );
    } else if (_mediaType == MediaType.video &&
        _videoPlayerController != null) {
      final currentPosition = await _videoPlayerController!.position;
      if (currentPosition != null) {
        final newPosition = currentPosition - seekDuration;
        await _videoPlayerController!.seekTo(
          newPosition > Duration.zero ? newPosition : Duration.zero,
        );
      }
    }
  }

  /// Reproduce el siguiente elemento de la lista
  Future<void> _playNext() async {
    if (_playlist == null || _playlist!.isEmpty) return;

    // Si no estamos en el último elemento
    if (_currentIndex < _playlist!.length - 1) {
      _currentIndex++;
      await _loadAndPlayFromPlaylist(_currentIndex);
    } else {
      // Opcional: volver al inicio o detener
      _currentIndex = 0;
      await _loadAndPlayFromPlaylist(_currentIndex);
    }
  }

  /// Reproduce el elemento anterior de la lista
  Future<void> _playPrevious() async {
    if (_playlist == null || _playlist!.isEmpty) return;

    // Si no estamos en el primer elemento
    if (_currentIndex > 0) {
      _currentIndex--;
      await _loadAndPlayFromPlaylist(_currentIndex);
    } else {
      // Opcional: ir al último o quedarse en el primero
      _currentIndex = _playlist!.length - 1;
      await _loadAndPlayFromPlaylist(_currentIndex);
    }
  }

  /// Carga y reproduce un elemento de la lista
  Future<void> _loadAndPlayFromPlaylist(int index) async {
    if (_playlist == null || index < 0 || index >= _playlist!.length) return;

    final item = _playlist![index];

    // Verificar si el archivo existe
    final file = File(item.filePath);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.fileName} no existe o fue movido')),
      );
      // Intentar con el siguiente
      if (index < _playlist!.length - 1) {
        _currentIndex = index + 1;
        await _loadAndPlayFromPlaylist(_currentIndex);
      }
      return;
    }

    // Detener reproducción actual
    if (_mediaType == MediaType.audio) {
      await _audioPlayer.stop();
    } else if (_mediaType == MediaType.video) {
      _videoPlayerController?.pause();
      _videoPlayerController?.dispose();
      _chewieController?.dispose();
      _videoPlayerController = null;
      _chewieController = null;
    }

    // Cargar nuevo archivo
    setState(() {
      _filePath = item.filePath;
      _fileName = item.fileName;
      _mediaType = item.mediaType;
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    // Reproducir según el tipo
    if (_mediaType == MediaType.audio) {
      await _play();
    } else if (_mediaType == MediaType.video) {
      await _initializeVideo();
    }
  }

  /// Construye el área de visualización según el tipo de medio
  Widget _buildMediaDisplay() {
    if (_filePath == null) {
      return const EmptyMediaDisplay();
    }

    switch (_mediaType) {
      case MediaType.audio:
        return AudioDisplay(fileName: _fileName ?? '');

      case MediaType.video:
        if (_chewieController != null && _videoPlayerController != null) {
          return VideoDisplay(
            videoController: _videoPlayerController!,
            chewieController: _chewieController!,
          );
        }
        return const Center(child: CircularProgressIndicator());

      case MediaType.image:
        return ImageDisplay(filePath: _filePath!);

      default:
        return const Text('Tipo de archivo no soportado');
    }
  }

  /// Verifica si está reproduciendo
  bool get _isPlaying {
    if (_mediaType == MediaType.audio) {
      return _playerState == PlayerState.playing;
    } else if (_mediaType == MediaType.video &&
        _videoPlayerController != null) {
      return _videoPlayerController!.value.isPlaying;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reproductor Multimedia'),
            if (_playlist != null && _playlist!.isNotEmpty)
              Text(
                'Elemento ${_currentIndex + 1} de ${_playlist!.length}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            tooltip: 'Listas de Reproducción',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlaylistsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Área de visualización de contenido
          Expanded(
            child: Container(
              color: Colors.black12,
              child: Center(child: _buildMediaDisplay()),
            ),
          ),

          // Controles de navegación de lista (si hay lista)
          if (_playlist != null &&
              _playlist!.isNotEmpty &&
              _mediaType != MediaType.video)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    iconSize: 36,
                    onPressed: _playPrevious,
                    tooltip: 'Anterior',
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    iconSize: 36,
                    onPressed: _playNext,
                    tooltip: 'Siguiente',
                  ),
                ],
              ),
            ),

          // Panel de controles - Solo para audio e imágenes
          if (_mediaType != MediaType.video)
            MediaControlPanel(
              fileName: _fileName,
              isPlaying: _isPlaying,
              hasFile: _filePath != null,
              isImage: _mediaType == MediaType.image,
              onPlay: _play,
              onPause: _pause,
              onStop: _stop,
              onSeekForward: _seekForward,
              onSeekBackward: _seekBackward,
              progressBar: (_mediaType == MediaType.audio && _filePath != null)
                  ? AudioProgressBar(
                      position: _position,
                      duration: _duration,
                      onSeek: (position) => _audioPlayer.seek(position),
                    )
                  : null,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickFile,
        label: const Text('Abrir Archivo'),
        icon: const Icon(Icons.folder_open),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
