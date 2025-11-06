import 'package:flutter/material.dart';

/// Widget que muestra el estado inicial cuando no hay archivos seleccionados
class EmptyMediaDisplay extends StatelessWidget {
  const EmptyMediaDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.music_note, size: 100, color: Colors.grey.shade400),
        const SizedBox(height: 20),
        Text(
          'No hay ningún archivo seleccionado',
          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 10),
        Text(
          'Toca el botón "Abrir Archivo" para comenzar',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
