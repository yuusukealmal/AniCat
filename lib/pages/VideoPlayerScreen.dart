import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_video_view/flutter_video_view.dart';
import 'package:anicat/functions/behavior/ScreenRotate.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String filePath;
  const VideoPlayerScreen({super.key, required this.filePath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with Rotate {
  @override
  void initState() {
    setLandscapeMode();
    super.initState();
  }

  @override
  void dispose() {
    setPortraitMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController videoPlayerController =
        VideoPlayerController.file(File(widget.filePath));

    return VideoView(
      controller: VideoController(
          videoPlayerController: videoPlayerController,
          videoConfig: VideoConfig()),
    );
  }
}
