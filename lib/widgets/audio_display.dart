import 'package:flutter/material.dart';

/// Widget que muestra la visualización del reproductor de audio
class AudioDisplay extends StatelessWidget {
  final String fileName;

  const AudioDisplay({super.key, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.music_note, size: 120, color: Colors.deepPurple),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            fileName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
