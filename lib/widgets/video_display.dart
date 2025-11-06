import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

/// Widget que muestra el reproductor de video con controles integrados
class VideoDisplay extends StatelessWidget {
  final VideoPlayerController videoController;
  final ChewieController chewieController;

  const VideoDisplay({
    super.key,
    required this.videoController,
    required this.chewieController,
  });

  @override
  Widget build(BuildContext context) {
    if (videoController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: videoController.value.aspectRatio,
        child: Chewie(controller: chewieController),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
