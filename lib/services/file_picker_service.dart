import 'package:file_picker/file_picker.dart';
import '../models/media_type.dart';

/// Resultado del selector de archivos
class FilePickerResult {
  final String? filePath;
  final String fileName;
  final MediaType? mediaType;

  FilePickerResult({
    required this.filePath,
    required this.fileName,
    required this.mediaType,
  });
}

/// Servicio para seleccionar archivos multimedia
class FilePickerService {
  /// Abre el selector de archivos y retorna el resultado
  static Future<FilePickerResult?> pickMediaFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: MediaTypeExtension.allExtensions,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final filePath = file.path;
    final fileName = file.name;
    final extension = fileName.split('.').last.toLowerCase();
    final mediaType = MediaTypeExtension.fromExtension(extension);

    return FilePickerResult(
      filePath: filePath,
      fileName: fileName,
      mediaType: mediaType,
    );
  }
}
