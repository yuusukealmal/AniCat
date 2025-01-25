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
  VideoPlayerController? _videoPlayerController;
  @override
  void initState() {
    setLandscapeMode();
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    setPortraitMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));

    return VideoView(
      controller: VideoController(
          videoPlayerController: _videoPlayerController!,
          videoConfig: VideoConfig(
              title: widget.filePath.split('/').last,
              showLock: true,
              autoPlay: true,
              fullScreenByDefault: true)),
    );
  }
}
