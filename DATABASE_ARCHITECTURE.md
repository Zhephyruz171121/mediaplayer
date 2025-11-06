# Diagrama de Arquitectura - Base de Datos SQLite

## Estructura de Tablas

```
┌─────────────────────────────────┐
│        PLAYLISTS                │
├─────────────────────────────────┤
│ • id (PK)                       │
│ • name                          │
│ • description                   │
│ • created_at                    │
│ • updated_at                    │
└──────────────┬──────────────────┘
               │
               │ 1:N
               │
               ↓
┌─────────────────────────────────┐
│      PLAYLIST_ITEMS             │
├─────────────────────────────────┤
│ • id (PK)                       │
│ • playlist_id (FK)              │
│ • media_item_id (FK)            │
│ • position                      │
│ • added_at                      │
└──────────────┬──────────────────┘
               │
               │ N:1
               │
               ↓
┌─────────────────────────────────┐
│       MEDIA_ITEMS               │
├─────────────────────────────────┤
│ • id (PK)                       │
│ • file_name                     │
│ • file_path (UNIQUE)            │
│ • media_type                    │
│ • duration                      │
│ • added_at                      │
└─────────────────────────────────┘
```

## Flujo de Datos

```
┌──────────────────┐
│   UI Layer       │
│  (Screens)       │
└────────┬─────────┘
         │
         │ Interacción del Usuario
         ↓
┌──────────────────┐
│ Service Layer    │
│ DatabaseService  │
└────────┬─────────┘
         │
         │ Operaciones CRUD
         ↓
┌──────────────────┐
│  Data Layer      │
│   SQLite DB      │
└──────────────────┘
```

## Relaciones entre Componentes

```
MediaPlayerScreen
    ├── PlaylistsScreen
    │       ├── Mostrar todas las listas
    │       ├── Crear nueva lista
    │       ├── Editar lista
    │       ├── Eliminar lista
    │       └── Navegar a PlaylistDetailScreen
    │
PlaylistDetailScreen
    ├── Mostrar elementos de la lista
    ├── Añadir desde archivo
    ├── Añadir desde biblioteca (MediaLibrarySelector)
    ├── Reproducir elemento
    ├── Eliminar elemento
    └── Reordenar elementos

MediaLibrarySelector
    ├── Mostrar todos los elementos
    ├── Filtrar por tipo
    └── Seleccionar elemento

DatabaseService
    ├── Playlists
    │   ├── create
    │   ├── read (all/by id)
    │   ├── update
    │   └── delete
    ├── MediaItems
    │   ├── createOrGet
    │   ├── read (all/by type)
    │   └── delete
    └── PlaylistItems
        ├── add
        ├── get
        ├── remove
        ├── count
        └── reorder
```

## Flujo de Uso Típico

### 1. Crear Lista y Añadir Elementos

```
Usuario → PlaylistsScreen
    ↓ Clic en "+"
    ↓ Ingresar datos
    ↓
DatabaseService.createPlaylist()
    ↓
SQLite: INSERT INTO playlists
    ↓
PlaylistDetailScreen
    ↓ Clic en "Añadir Archivo"
    ↓
FilePickerService.pickMediaFile()
    ↓
DatabaseService.createOrGetMediaItem()
    ↓
SQLite: INSERT INTO media_items (si no existe)
    ↓
DatabaseService.addItemToPlaylist()
    ↓
SQLite: INSERT INTO playlist_items
```

### 2. Reproducir desde Lista

```
Usuario → PlaylistDetailScreen
    ↓ Clic en elemento
    ↓
Verificar File.exists()
    ↓
MediaPlayerScreen (con parámetros)
    ↓
Reproducir archivo
```

### 3. Reordenar Elementos

```
Usuario → PlaylistDetailScreen
    ↓ Drag & Drop
    ↓
DatabaseService.reorderPlaylistItem()
    ↓
SQLite: UPDATE playlist_items SET position
    ↓
Actualizar updated_at de playlist
```

## Índices para Optimización

```sql
-- Índice en playlist_items.playlist_id
CREATE INDEX idx_playlist_items_playlist_id 
ON playlist_items (playlist_id);

-- Índice compuesto para ordenamiento
CREATE INDEX idx_playlist_items_position 
ON playlist_items (playlist_id, position);
```

Estos índices mejoran el rendimiento en:
- Consultas de elementos por lista
- Ordenamiento de elementos
- Operaciones de reordenamiento

## Convenciones de Nomenclatura

- **Tablas**: snake_case, plural (playlists, media_items)
- **Columnas**: snake_case (file_name, created_at)
- **Clases Dart**: PascalCase (Playlist, MediaItem)
- **Propiedades Dart**: camelCase (fileName, createdAt)

## Manejo de Integridad Referencial

```sql
FOREIGN KEY (playlist_id) 
  REFERENCES playlists (id) 
  ON DELETE CASCADE

FOREIGN KEY (media_item_id) 
  REFERENCES media_items (id) 
  ON DELETE CASCADE
```

**Comportamiento:**
- Si se elimina una playlist → se eliminan sus playlist_items
- Si se elimina un media_item → se eliminan sus referencias en playlist_items
- Los media_items no se eliminan automáticamente al sacarlos de una lista

## Restricciones Únicas

```sql
-- Un archivo no puede duplicarse en la biblioteca
media_items.file_path UNIQUE

-- Un elemento no puede estar dos veces en la misma lista
UNIQUE (playlist_id, media_item_id)
```
