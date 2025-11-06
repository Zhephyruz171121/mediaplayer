import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../services/database_service.dart';
import 'playlist_detail_screen.dart';

/// Pantalla para mostrar y gestionar las listas de reproducción
class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  /// Carga las listas de reproducción desde la base de datos
  Future<void> _loadPlaylists() async {
    setState(() => _isLoading = true);
    final playlists = await _db.getPlaylists();
    setState(() {
      _playlists = playlists;
      _isLoading = false;
    });
  }

  /// Muestra el diálogo para crear una nueva lista
  Future<void> _showCreatePlaylistDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Lista de Reproducción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Mi lista de reproducción',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Descripción de la lista',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final now = DateTime.now();
      final playlist = Playlist(
        name: nameController.text,
        description: descriptionController.text,
        createdAt: now,
        updatedAt: now,
      );

      await _db.createPlaylist(playlist);
      _loadPlaylists();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lista creada exitosamente')),
        );
      }
    }
  }

  /// Muestra el diálogo para editar una lista
  Future<void> _showEditPlaylistDialog(Playlist playlist) async {
    final nameController = TextEditingController(text: playlist.name);
    final descriptionController = TextEditingController(
      text: playlist.description,
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Lista de Reproducción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final updatedPlaylist = playlist.copyWith(
        name: nameController.text,
        description: descriptionController.text,
        updatedAt: DateTime.now(),
      );

      await _db.updatePlaylist(updatedPlaylist);
      _loadPlaylists();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lista actualizada')));
      }
    }
  }

  /// Muestra el diálogo de confirmación para eliminar una lista
  Future<void> _showDeleteConfirmDialog(Playlist playlist) async {
    final count = await _db.getPlaylistItemCount(playlist.id!);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Lista'),
        content: Text(
          count > 0
              ? '¿Estás seguro de eliminar "${playlist.name}"?\n\nContiene $count elemento(s).'
              : '¿Estás seguro de eliminar "${playlist.name}"?',
        ),
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
      await _db.deletePlaylist(playlist.id!);
      _loadPlaylists();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lista eliminada')));
      }
    }
  }

  /// Navega a los detalles de una lista de reproducción
  Future<void> _navigateToPlaylistDetail(Playlist playlist) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailScreen(playlist: playlist),
      ),
    );
    _loadPlaylists(); // Recargar por si hubo cambios
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas de Reproducción'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _playlists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.playlist_play, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay listas de reproducción',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea una lista para comenzar',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _playlists.length,
              itemBuilder: (context, index) {
                final playlist = _playlists[index];
                return FutureBuilder<int>(
                  future: _db.getPlaylistItemCount(playlist.id!),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.queue_music,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          playlist.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (playlist.description.isNotEmpty)
                              Text(
                                playlist.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              '$count elemento(s)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _showEditPlaylistDialog(playlist);
                                break;
                              case 'delete':
                                _showDeleteConfirmDialog(playlist);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _navigateToPlaylistDetail(playlist),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlaylistDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
