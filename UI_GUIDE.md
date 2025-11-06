# 📸 Guía Visual de la Interfaz

## Pantalla Principal (MediaPlayerScreen)

```
┌────────────────────────────────────┐
│ ← Reproductor Multimedia      🎵   │ ← Nuevo botón de listas
├────────────────────────────────────┤
│                                    │
│     [Área de Reproducción]         │
│                                    │
│    🎵 Audio / 🎬 Video / 🖼️ Imagen │
│                                    │
├────────────────────────────────────┤
│  Panel de Controles                │
│  ⏪  ⏸️  ▶️  ⏩  ⏹️                  │
│  ▬▬▬▬▬▬▬▬▬▬▬▬ (barra progreso)    │
└────────────────────────────────────┘
          [📂 Abrir Archivo]
```

**Características:**
- AppBar con título y botón de listas (🎵)
- Área de visualización adaptativa según tipo de medio
- Controles solo para audio e imágenes
- FAB para abrir archivos

---

## Pantalla de Listas (PlaylistsScreen)

```
┌────────────────────────────────────┐
│ ← Listas de Reproducción           │
├────────────────────────────────────┤
│                                    │
│  ┌──────────────────────────────┐ │
│  │ 🎵 Mi Lista Favorita       ⋮ │ │
│  │    Las mejores canciones     │ │
│  │    15 elemento(s)            │ │
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────────────────────┐ │
│  │ 🎵 Rock Clásico            ⋮ │ │
│  │    Música rock de los 80s    │ │
│  │    8 elemento(s)             │ │
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────────────────────┐ │
│  │ 🎵 Multimedia Mix          ⋮ │ │
│  │    Audio, video e imágenes   │ │
│  │    23 elemento(s)            │ │
│  └──────────────────────────────┘ │
│                                    │
└────────────────────────────────────┘
                 [+]
```

**Características:**
- Lista scrolleable de playlists
- Avatar con icono de lista
- Nombre, descripción y contador
- Menú contextual (⋮) para editar/eliminar
- FAB (+) para crear nueva lista

**Menú Contextual:**
```
┌─────────────────┐
│ ✏️  Editar      │
│ 🗑️  Eliminar    │
└─────────────────┘
```

---

## Diálogo de Crear Lista

```
┌────────────────────────────────────┐
│  Nueva Lista de Reproducción       │
├────────────────────────────────────┤
│                                    │
│  Nombre:                           │
│  ┌──────────────────────────────┐ │
│  │ Mi lista de reproducción     │ │
│  └──────────────────────────────┘ │
│                                    │
│  Descripción:                      │
│  ┌──────────────────────────────┐ │
│  │                              │ │
│  │ Descripción de la lista      │ │
│  │                              │ │
│  └──────────────────────────────┘ │
│                                    │
│           [Cancelar]  [Crear]      │
└────────────────────────────────────┘
```

---

## Pantalla de Detalles (PlaylistDetailScreen)

```
┌────────────────────────────────────┐
│ ← Rock Clásico                     │
├────────────────────────────────────┤
│ Música rock de los 80s             │
│ 3 elemento(s)                      │
├────────────────────────────────────┤
│  ┌──────────────────────────────┐ │
│  │ 🔵 Bohemian Rhapsody.mp3  🗑️≡│ │
│  │    05:55                     │ │
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────────────────────┐ │
│  │ 🔵 Stairway to Heaven.mp3 🗑️≡│ │
│  │    08:02                     │ │
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────────────────────┐ │
│  │ 🔵 Hotel California.mp3   🗑️≡│ │
│  │    06:30                     │ │
│  └──────────────────────────────┘ │
│                                    │
└────────────────────────────────────┘
        [📚]  [📂 Añadir Archivo]
```

**Características:**
- Header con descripción y contador
- Lista reordenable de elementos
- Avatares coloreados por tipo:
  - 🔵 Azul = Audio (🎵)
  - 🔴 Rojo = Video (🎬)
  - 🟢 Verde = Imagen (🖼️)
- Botón de eliminar (🗑️) por elemento
- Icono de arrastre (≡) para reordenar
- Dos FABs:
  - 📚 Biblioteca
  - 📂 Añadir Archivo

---

## Selector de Biblioteca (MediaLibrarySelector)

```
┌────────────────────────────────────┐
│ 📚 Biblioteca Multimedia        ✕  │
├────────────────────────────────────┤
│ [Todos] [Audio] [Video] [Imágenes] │
├────────────────────────────────────┤
│                                    │
│  ┌──────────────────────────────┐ │
│  │ 🔵 song1.mp3                 │ │
│  │    /storage/music/song1.mp3  │ │
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────────────────────┐ │
│  │ 🔴 video1.mp4                │ │
│  │    /storage/video1.mp4       │ │
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────────────────────┐ │
│  │ 🟢 photo1.jpg                │ │
│  │    /storage/photo1.jpg       │ │
│  └──────────────────────────────┘ │
│                                    │
└────────────────────────────────────┘
```

**Características:**
- Diálogo modal
- Chips de filtro por tipo
- Lista scrolleable de elementos
- Muestra nombre y ruta del archivo
- Tap para seleccionar

---

## Estados Especiales

### Lista Vacía (PlaylistsScreen)
```
┌────────────────────────────────────┐
│ ← Listas de Reproducción           │
├────────────────────────────────────┤
│                                    │
│            🎵                      │
│                                    │
│   No hay listas de reproducción   │
│   Crea una lista para comenzar    │
│                                    │
└────────────────────────────────────┘
                 [+]
```

### Lista sin Elementos (PlaylistDetailScreen)
```
┌────────────────────────────────────┐
│ ← Mi Lista                         │
├────────────────────────────────────┤
│                                    │
│            🎼                      │
│                                    │
│        La lista está vacía         │
│     Añade archivos multimedia     │
│                                    │
└────────────────────────────────────┘
        [📚]  [📂 Añadir Archivo]
```

### Biblioteca Vacía
```
┌────────────────────────────────────┐
│ 📚 Biblioteca Multimedia        ✕  │
├────────────────────────────────────┤
│ [Todos] [Audio] [Video] [Imágenes] │
├────────────────────────────────────┤
│                                    │
│   No hay elementos en la biblioteca│
│                                    │
└────────────────────────────────────┘
```

---

## Interacciones del Usuario

### 1. Crear Lista
```
Tap en [+] → Diálogo → Ingresar datos → [Crear]
    ↓
SnackBar: "Lista creada exitosamente"
    ↓
Volver a PlaylistsScreen (actualizada)
```

### 2. Añadir Elemento desde Archivo
```
Tap en [Añadir Archivo] → Selector de archivos → Seleccionar
    ↓
SnackBar: "Archivo añadido a la lista"
    ↓
Lista actualizada con nuevo elemento
```

### 3. Añadir desde Biblioteca
```
Tap en [📚] → MediaLibrarySelector → Filtrar/Buscar → Tap elemento
    ↓
SnackBar: "Archivo añadido a la lista"
    ↓
Diálogo se cierra, lista actualizada
```

### 4. Reproducir Elemento
```
Tap en elemento → Verificar archivo existe
    ↓
Si existe: Navegar a MediaPlayerScreen (con archivo)
Si no existe: SnackBar: "El archivo no existe o fue movido"
```

### 5. Reordenar Elementos
```
Mantener presionado [≡] → Arrastrar → Soltar
    ↓
Actualización inmediata en UI y BD
```

### 6. Eliminar Elemento
```
Tap en [🗑️] → Diálogo confirmación → [Eliminar]
    ↓
SnackBar: "Elemento eliminado de la lista"
    ↓
Lista actualizada
```

### 7. Eliminar Lista
```
Tap en [⋮] → [Eliminar] → Diálogo confirmación
    ↓
"¿Estás seguro de eliminar 'X'?"
"Contiene N elemento(s)."
    ↓
[Eliminar] → SnackBar: "Lista eliminada"
```

---

## Códigos de Color por Tipo

```
🔵 AZUL   - MediaType.audio   - #2196F3
🔴 ROJO   - MediaType.video   - #F44336
🟢 VERDE  - MediaType.image   - #4CAF50
```

---

## Iconos Utilizados

```
🎵  playlist_play       - Listas de reproducción
🎼  library_music       - Biblioteca
📂  folder_open         - Abrir archivo
➕  add                 - Crear nuevo
⋮   more_vert           - Menú opciones
✏️  edit                - Editar
🗑️  delete              - Eliminar
🔙  arrow_back          - Volver
✕   close               - Cerrar
🎶  queue_music         - Avatar de lista
🎵  music_note          - Audio
🎬  videocam            - Video
🖼️  image               - Imagen
≡   drag_handle         - Arrastrar
⏪  skip_previous       - Retroceder
⏸️  pause               - Pausar
▶️  play_arrow          - Reproducir
⏩  skip_next           - Adelantar
⏹️  stop                - Detener
```

---

## Flujo de Navegación

```
MediaPlayerScreen (Inicio)
    │
    ├─→ [🎵] → PlaylistsScreen
    │           │
    │           ├─→ [+] → Diálogo Crear
    │           │
    │           └─→ Tap Lista → PlaylistDetailScreen
    │                           │
    │                           ├─→ [📂] → Selector Archivos
    │                           │
    │                           ├─→ [📚] → MediaLibrarySelector
    │                           │
    │                           └─→ Tap Elemento → MediaPlayerScreen
    │
    └─→ [📂] → Selector Archivos → Reproducir
```

---

## Responsive Design

Las pantallas se adaptan automáticamente a diferentes tamaños:

- **Teléfonos**: Stack vertical, FABs en esquina
- **Tablets**: Más ancho, mejor uso del espacio
- **Landscape**: Ajuste automático de AspectRatio

---

## Temas y Colores

La app utiliza Material Design 3 con:
- ColorScheme basado en `seedColor: Colors.deepPurple`
- Modo claro (por defecto)
- Soporte para modo oscuro (automático por sistema)

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
  ),
  useMaterial3: true,
),
```
