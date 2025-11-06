import 'package:permission_handler/permission_handler.dart';

/// Servicio para manejar los permisos de la aplicación
class PermissionService {
  /// Solicita el permiso necesario para acceder a los archivos de audio
  static Future<bool> requestAudioPermission() async {
    final status = await Permission.audio.request();
    return status.isGranted;
  }

  /// Solicita permisos de almacenamiento (si es necesario en el futuro)
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
}
