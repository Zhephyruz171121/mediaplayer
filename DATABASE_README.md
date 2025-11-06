# Base de Datos SQLite - Listas de Reproducción

## Descripción

Se ha integrado una base de datos SQLite al reproductor multimedia para permitir la creación y gestión de listas de reproducción de audio, video e imágenes.

## Características Implementadas

### 1. **Modelos de Datos**

#### Playlist (`lib/models/playlist.dart`)
- Modelo para las listas de reproducción
- Campos: id, name, description, createdAt, updatedAt

#### MediaItem (`lib/models/media_item.dart`)
- Modelo para elementos multimedia individuales
- Campos: id, fileName, filePath, mediaType, duration, addedAt
- Soporta audio, video e imágenes

#### PlaylistItem (`lib/models/playlist_item.dart`)
- Modelo para la relación entre listas y elementos
- Campos: id, playlistId, mediaItemId, position, addedAt

### 2. **Servicio de Base de Datos** (`lib/services/database_service.dart`)

El servicio incluye operaciones CRUD completas:

#### Operaciones con Listas de Reproducción:
- `createPlaylist()` - Crear nueva lista
- `getPlaylists()` - Obtener todas las listas
- `getPlaylistById()` - Obtener lista por ID
- `updatePlaylist()` - Actualizar lista
- `deletePlaylist()` - Eliminar lista

#### Operaciones con Elementos Multimedia:
- `createOrGetMediaItem()` - Crear o recuperar elemento
- `getAllMediaItems()` - Obtener todos los elementos
- `getMediaItemsByType()` - Filtrar por tipo (audio/video/imagen)
- `deleteMediaItem()` - Eliminar elemento

#### Operaciones con Elementos de Lista:
- `addItemToPlaylist()` - Añadir elemento a lista
- `getPlaylistMediaItems()` - Obtener elementos de una lista
- `removeItemFromPlaylist()` - Quitar elemento de lista
- `getPlaylistItemCount()` - Contar elementos en lista
- `reorderPlaylistItem()` - Reordenar elementos en lista

### 3. **Pantallas**

#### PlaylistsScreen (`lib/screens/playlists_screen.dart`)
- Muestra todas las listas de reproducción
- Permite crear, editar y eliminar listas
- Muestra el contador de elementos en cada lista
- Acceso rápido a los detalles de cada lista

#### PlaylistDetailScreen (`lib/screens/playlist_detail_screen.dart`)
- Muestra los elementos de una lista específica
- Permite añadir archivos desde el dispositivo
- Permite añadir archivos desde la biblioteca multimedia
- Reproduce elementos individuales
- Elimina elementos de la lista
- Reordena elementos con drag & drop
- Verificación de existencia de archivos antes de reproducir

### 4. **Widgets Auxiliares**

#### MediaLibrarySelector (`lib/widgets/media_library_selector.dart`)
- Diálogo para seleccionar archivos de la biblioteca
- Filtros por tipo de medio (audio, video, imagen)
- Visualización organizada con iconos y colores

### 5. **Integración con el Reproductor**

#### MediaPlayerScreen actualizado:
- Nuevo botón en AppBar para acceder a listas de reproducción
- Soporte para reproducir archivos directamente desde listas
- Parámetros opcionales para iniciar con archivo específico

## Estructura de la Base de Datos

### Tabla: playlists
```sql
id INTEGER PRIMARY KEY AUTOINCREMENT
name TEXT NOT NULL
description TEXT NOT NULL
created_at TEXT NOT NULL
updated_at TEXT NOT NULL
```

### Tabla: media_items
```sql
id INTEGER PRIMARY KEY AUTOINCREMENT
file_name TEXT NOT NULL
file_path TEXT NOT NULL UNIQUE
media_type TEXT NOT NULL
duration INTEGER
added_at TEXT NOT NULL
```

### Tabla: playlist_items
```sql
id INTEGER PRIMARY KEY AUTOINCREMENT
playlist_id INTEGER NOT NULL
media_item_id INTEGER NOT NULL
position INTEGER NOT NULL
added_at TEXT NOT NULL
FOREIGN KEY (playlist_id) REFERENCES playlists (id) ON DELETE CASCADE
FOREIGN KEY (media_item_id) REFERENCES media_items (id) ON DELETE CASCADE
UNIQUE (playlist_id, media_item_id)
```

## Dependencias Añadidas

```yaml
sqflite: ^2.3.3+2        # Base de datos SQLite
path: ^1.9.0             # Manejo de rutas
path_provider: ^2.1.4    # Acceso a directorios del sistema
```

## Uso

### Crear una Lista de Reproducción

1. Abrir el reproductor multimedia
2. Tocar el icono de listas de reproducción en el AppBar
3. Tocar el botón flotante "+"
4. Ingresar nombre y descripción
5. Tocar "Crear"

### Añadir Elementos a una Lista

Desde la pantalla de detalles de una lista:

**Opción 1: Desde archivo**
1. Tocar "Añadir Archivo"
2. Seleccionar archivo del dispositivo

**Opción 2: Desde biblioteca**
1. Tocar el botón de biblioteca (icono de música)
2. Filtrar por tipo si es necesario
3. Seleccionar el archivo deseado

### Reproducir desde una Lista

1. Entrar a los detalles de una lista
2. Tocar cualquier elemento
3. Se abrirá el reproductor con el archivo seleccionado

### Reordenar Elementos

1. Mantener presionado el icono de arrastre (≡)
2. Mover el elemento a la posición deseada
3. El orden se guarda automáticamente

### Eliminar Elementos

- Para eliminar de la lista: Tocar el icono de papelera junto al elemento
- Para eliminar la lista completa: Menú de opciones (⋮) → Eliminar

## Características Técnicas

- **Persistencia de Datos**: Los datos se guardan localmente usando SQLite
- **Integridad Referencial**: Eliminación en cascada de elementos relacionados
- **Optimización**: Índices en columnas frecuentemente consultadas
- **Validación**: Verificación de archivos antes de reproducir
- **UX Mejorada**: Iconos por tipo de medio, colores distintivos
- **Gestión de Estado**: Actualización automática de UI tras cambios

## Notas Importantes

1. Los archivos NO se copian a la app, solo se guarda la ruta
2. Si un archivo se mueve o elimina del dispositivo, no se podrá reproducir
3. Los elementos multimedia se reutilizan entre listas (no se duplican)
4. Una lista puede contener diferentes tipos de medios (audio, video, imagen)
5. El orden de reproducción se mantiene según el orden en la lista

## Mejoras Futuras Sugeridas

- [ ] Reproducción continua de toda la lista
- [ ] Modo aleatorio y repetición
- [ ] Búsqueda de archivos en listas
- [ ] Exportar/Importar listas
- [ ] Estadísticas de reproducción
- [ ] Carátulas personalizadas para listas
- [ ] Compartir listas entre dispositivos
- [ ] Sincronización con servicios en la nube
