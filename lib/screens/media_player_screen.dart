import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';

import '../models/media_type.dart';
import '../services/permission_service.dart';
import '../services/file_picker_service.dart';
import '../widgets/audio_display.dart';
import '../widgets/video_display.dart';
import '../widgets/image_display.dart';
import '../widgets/empty_media_display.dart';
import '../widgets/media_control_panel.dart';
import '../widgets/audio_progress_bar.dart';

/// Pantalla principal del reproductor multimedia
class MediaPlayerScreen extends StatefulWidget {
  const MediaPlayerScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _setupAudioListeners();
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
        title: const Text('Reproductor Multimedia'),
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
