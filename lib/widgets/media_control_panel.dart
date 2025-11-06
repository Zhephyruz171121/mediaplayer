import 'package:flutter/material.dart';

/// Widget que muestra el panel de controles de reproducción
class MediaControlPanel extends StatelessWidget {
  final String? fileName;
  final bool isPlaying;
  final bool hasFile;
  final bool isImage;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onStop;
  final VoidCallback? onSeekForward;
  final VoidCallback? onSeekBackward;
  final Widget? progressBar;

  const MediaControlPanel({
    super.key,
    this.fileName,
    required this.isPlaying,
    required this.hasFile,
    required this.isImage,
    this.onPlay,
    this.onPause,
    this.onStop,
    this.onSeekForward,
    this.onSeekBackward,
    this.progressBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nombre del archivo
          if (fileName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                fileName!,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Barra de progreso (si se proporciona)
          if (progressBar != null) progressBar!,

          const SizedBox(height: 16),

          // Controles de reproducción
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón de retroceder 5 segundos
              IconButton(
                icon: const Icon(Icons.replay_5),
                iconSize: 40.0,
                onPressed: (!hasFile || isImage) ? null : onSeekBackward,
                color: Colors.deepPurple,
                tooltip: 'Retroceder 5 segundos',
              ),

              const SizedBox(width: 12),

              // Botón de Play/Pause
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  iconSize: 48.0,
                  onPressed: (!hasFile || isImage)
                      ? null
                      : (isPlaying ? onPause : onPlay),
                  tooltip: isPlaying ? 'Pausar' : 'Reproducir',
                ),
              ),

              const SizedBox(width: 12),

              // Botón de Stop
              IconButton(
                icon: const Icon(Icons.stop),
                iconSize: 40.0,
                onPressed: !hasFile ? null : onStop,
                color: Colors.red,
                tooltip: 'Detener',
              ),

              const SizedBox(width: 12),

              // Botón de adelantar 5 segundos
              IconButton(
                icon: const Icon(Icons.forward_5),
                iconSize: 40.0,
                onPressed: (!hasFile || isImage) ? null : onSeekForward,
                color: Colors.deepPurple,
                tooltip: 'Adelantar 5 segundos',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
