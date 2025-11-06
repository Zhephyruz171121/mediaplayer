import 'package:flutter/material.dart';
import 'dart:io';
import '../models/playlist.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';
import '../services/database_service.dart';
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
  final DatabaseService _db = DatabaseService.instance;
  List<MediaItem> _mediaItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylistItems();
  }

  /// Carga los elementos de la lista de reproducción
  Future<void> _loadPlaylistItems() async {
    setState(() => _isLoading = true);
    final items = await _db.getPlaylistMediaItems(widget.playlist.id!);
    setState(() {
      _mediaItems = items;
      _isLoading = false;
    });
  }

  /// Muestra el selector de biblioteca
  Future<void> _showLibrarySelector() async {
    await showDialog(
      context: context,
      builder: (context) => MediaLibrarySelector(
        onMediaItemSelected: (mediaItem) async {
          try {
            await _db.addItemToPlaylist(widget.playlist.id!, mediaItem.id!);
            _loadPlaylistItems();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Archivo añadido a la lista')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Este archivo ya está en la lista'),
                ),
              );
            }
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
    if (result == null || result.filePath == null || result.mediaType == null)
      return;

    // Crear el elemento multimedia
    final mediaItem = MediaItem(
      fileName: result.fileName,
      filePath: result.filePath!,
      mediaType: result.mediaType!,
      addedAt: DateTime.now(),
    );

    try {
      // Insertar o obtener el ID del elemento
      final mediaItemId = await _db.createOrGetMediaItem(mediaItem);

      // Añadir a la lista de reproducción
      await _db.addItemToPlaylist(widget.playlist.id!, mediaItemId);

      // Recargar la lista
      _loadPlaylistItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Archivo añadido a la lista')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al añadir archivo: $e')));
      }
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
      await _db.removeItemFromPlaylist(widget.playlist.id!, item.id!);
      _loadPlaylistItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Elemento eliminado de la lista')),
        );
      }
    }
  }

  /// Reproduce un elemento de la lista
  Future<void> _playItem(MediaItem item) async {
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

    // Navegar al reproductor con el archivo
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MediaPlayerScreen(
            filePath: item.filePath,
            fileName: item.fileName,
            mediaType: item.mediaType,
          ),
        ),
      );
    }
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
      ),
      body: Column(
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
                    '${_mediaItems.length} elemento(s)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          // Lista de elementos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _mediaItems.isEmpty
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
                    itemCount: _mediaItems.length,
                    onReorder: (oldIndex, newIndex) async {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      setState(() {
                        final item = _mediaItems.removeAt(oldIndex);
                        _mediaItems.insert(newIndex, item);
                      });
                      await _db.reorderPlaylistItem(
                        widget.playlist.id!,
                        oldIndex,
                        newIndex,
                      );
                    },
                    itemBuilder: (context, index) {
                      final item = _mediaItems[index];
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
                          onTap: () => _playItem(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'library',
            onPressed: _showLibrarySelector,
            tooltip: 'Biblioteca',
            child: const Icon(Icons.library_music),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: _addFileToPlaylist,
            label: const Text('Añadir Archivo'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
