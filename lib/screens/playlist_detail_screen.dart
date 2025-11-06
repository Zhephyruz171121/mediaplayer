import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/playlist.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';
import '../providers/playlist_items_provider.dart';
import '../services/file_picker_service.dart';
import '../services/permission_service.dart';
import '../widgets/media_library_selector.dart';
import 'media_player_screen.dart';

/// Pantalla para ver y gestionar los detalles de una lista de reproducción
class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistItemsProvider>().setPlaylist(widget.playlist.id!);
    });
  }

  /// Muestra el selector de biblioteca
  Future<void> _showLibrarySelector() async {
    final provider = context.read<PlaylistItemsProvider>();
    await showDialog(
      context: context,
      builder: (context) => MediaLibrarySelector(
        onMediaItemSelected: (mediaItem) async {
          final success = await provider.addMediaItem(
            mediaItem.fileName,
            mediaItem.filePath,
            mediaItem.mediaType,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Archivo añadido a la lista'
                      : 'Este archivo ya está en la lista',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  /// Añade un archivo a la lista de reproducción
  Future<void> _addFileToPlaylist() async {
    // Solicitar permisos
    final hasPermission = await PermissionService.requestAudioPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso denegado para acceder a archivos.'),
          ),
        );
      }
      return;
    }

    // Seleccionar archivo
    final result = await FilePickerService.pickMediaFile();
    if (result == null || result.filePath == null || result.mediaType == null) {
      return;
    }

    // Añadir el archivo a través del provider
    final provider = context.read<PlaylistItemsProvider>();
    final success = await provider.addMediaItem(
      result.fileName,
      result.filePath!,
      result.mediaType!,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Archivo añadido a la lista' : 'Error al añadir archivo',
          ),
        ),
      );
    }
  }

  /// Elimina un elemento de la lista de reproducción
  Future<void> _removeFromPlaylist(MediaItem item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar de la lista'),
        content: Text('¿Eliminar "${item.fileName}" de esta lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await context
          .read<PlaylistItemsProvider>()
          .removeMediaItem(item.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Elemento eliminado de la lista' : 'Error al eliminar',
            ),
          ),
        );
      }
    }
  }

  /// Reproduce un elemento de la lista
  Future<void> _playItem(
    MediaItem item,
    List<MediaItem> playlist, [
    int? startIndex,
  ]) async {
    // Verificar si el archivo existe
    final file = File(item.filePath);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El archivo no existe o fue movido')),
        );
      }
      return;
    }

    // Navegar al reproductor con el archivo y la lista completa
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MediaPlayerScreen(
            filePath: item.filePath,
            fileName: item.fileName,
            mediaType: item.mediaType,
            playlist: playlist,
            initialIndex: startIndex ?? playlist.indexOf(item),
          ),
        ),
      );
    }
  }

  /// Reproduce toda la lista desde el inicio
  Future<void> _playAllFromStart(List<MediaItem> mediaItems) async {
    if (mediaItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('La lista está vacía')));
      return;
    }

    // Verificar que al menos el primer archivo existe
    final firstFile = File(mediaItems.first.filePath);
    if (!await firstFile.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El primer archivo no existe o fue movido'),
          ),
        );
      }
      return;
    }

    _playItem(mediaItems.first, mediaItems, 0);
  }

  /// Obtiene el icono según el tipo de medio
  IconData _getMediaIcon(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.audio:
        return Icons.music_note;
      case MediaType.video:
        return Icons.videocam;
      case MediaType.image:
        return Icons.image;
    }
  }

  /// Obtiene el color según el tipo de medio
  Color _getMediaColor(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.audio:
        return Colors.blue;
      case MediaType.video:
        return Colors.red;
      case MediaType.image:
        return Colors.green;
    }
  }

  /// Formatea la duración
  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<PlaylistItemsProvider>(
            builder: (context, provider, child) {
              if (provider.hasItems) {
                return IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  tooltip: 'Reproducir lista',
                  onPressed: () => _playAllFromStart(provider.items),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_file') {
                _addFileToPlaylist();
              } else if (value == 'add_library') {
                _showLibrarySelector();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_file',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Añadir archivo'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_library',
                child: Row(
                  children: [
                    Icon(Icons.library_music),
                    SizedBox(width: 8),
                    Text('Añadir desde biblioteca'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<PlaylistItemsProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Información de la lista
              if (widget.playlist.description.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.playlist.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${provider.items.length} elemento(s)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

              // Lista de elementos
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : !provider.hasItems
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.library_music_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'La lista está vacía',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Añade archivos multimedia',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        itemCount: provider.items.length,
                        onReorder: (oldIndex, newIndex) async {
                          await provider.reorderItems(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final item = provider.items[index];
                          return Card(
                            key: ValueKey(item.id),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getMediaColor(item.mediaType),
                                child: Icon(
                                  _getMediaIcon(item.mediaType),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                item.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                _formatDuration(item.duration),
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () => _removeFromPlaylist(item),
                                  ),
                                  const Icon(Icons.drag_handle),
                                ],
                              ),
                              onTap: () =>
                                  _playItem(item, provider.items, index),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
