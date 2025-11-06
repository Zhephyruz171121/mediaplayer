import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';
import '../services/database_service.dart';

/// Selector de elementos multimedia desde la biblioteca
class MediaLibrarySelector extends StatefulWidget {
  final Function(MediaItem) onMediaItemSelected;

  const MediaLibrarySelector({super.key, required this.onMediaItemSelected});

  @override
  State<MediaLibrarySelector> createState() => _MediaLibrarySelectorState();
}

class _MediaLibrarySelectorState extends State<MediaLibrarySelector> {
  final DatabaseService _db = DatabaseService.instance;
  List<MediaItem> _allItems = [];
  List<MediaItem> _filteredItems = [];
  bool _isLoading = true;
  MediaType? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadMediaItems();
  }

  /// Carga todos los elementos multimedia
  Future<void> _loadMediaItems() async {
    setState(() => _isLoading = true);
    final items = await _db.getAllMediaItems();
    setState(() {
      _allItems = items;
      _filteredItems = items;
      _isLoading = false;
    });
  }

  /// Filtra los elementos por tipo
  void _filterByType(MediaType? type) {
    setState(() {
      _selectedType = type;
      if (type == null) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems
            .where((item) => item.mediaType == type)
            .toList();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                const Icon(Icons.library_music),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Biblioteca Multimedia',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Filtros
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _selectedType == null,
                    onSelected: (_) => _filterByType(null),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Audio'),
                    selected: _selectedType == MediaType.audio,
                    onSelected: (_) => _filterByType(MediaType.audio),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Video'),
                    selected: _selectedType == MediaType.video,
                    onSelected: (_) => _filterByType(MediaType.video),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Imágenes'),
                    selected: _selectedType == MediaType.image,
                    onSelected: (_) => _filterByType(MediaType.image),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Lista de elementos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                ? const Center(child: Text('No hay elementos en la biblioteca'))
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return ListTile(
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
                          item.filePath,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                        onTap: () {
                          widget.onMediaItemSelected(item);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
