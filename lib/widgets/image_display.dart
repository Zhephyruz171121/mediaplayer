import 'package:flutter/material.dart';
import 'dart:io';

/// Widget que muestra una imagen con zoom interactivo
class ImageDisplay extends StatelessWidget {
  final String filePath;

  const ImageDisplay({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      panEnabled: true,
      minScale: 0.5,
      maxScale: 4.0,
      child: Image.file(File(filePath), fit: BoxFit.contain),
    );
  }
}
