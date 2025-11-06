import 'package:flutter/material.dart';
import 'screens/media_player_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Aplicación principal del reproductor multimedia
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reproductor Multimedia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MediaPlayerScreen(),
    );
  }
}
