import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/media_player_screen.dart';
import 'providers/playlist_provider.dart';
import 'providers/playlist_items_provider.dart';
import 'providers/media_library_provider.dart';
import 'providers/player_provider.dart';

void main() {
  runApp(const MyApp());
}

/// Aplicación principal del reproductor multimedia
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistItemsProvider()),
        ChangeNotifierProvider(create: (_) => MediaLibraryProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Reproductor Multimedia',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MediaPlayerScreen(),
      ),
    );
  }
}
