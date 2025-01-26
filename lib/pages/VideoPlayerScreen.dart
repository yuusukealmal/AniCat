import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_video_view/flutter_video_view.dart';
import 'package:anicat/functions/behavior/ScreenRotate.dart';
import 'package:anicat/config/SharedPreferences.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String filePath;
  const VideoPlayerScreen({super.key, required this.filePath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with ScreenRotate {
  VideoPlayerController? _videoPlayerController;
  bool atuoPlay = SharedPreferencesHelper.getBool("Video.AutoPlay") ?? false;
  bool fullScreen =
      SharedPreferencesHelper.getBool("Video.FullScreen") ?? false;
  double playbackSpeed =
      SharedPreferencesHelper.getDouble("Video.PlaybackSpeed") ?? 1.0;

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
    _videoPlayerController!.setPlaybackSpeed(playbackSpeed);

    return VideoView(
      controller: VideoController(
          videoPlayerController: _videoPlayerController!,
          videoConfig: VideoConfig(
              title: widget.filePath.split('/').last,
              showLock: true,
              autoPlay: atuoPlay,
              fullScreenByDefault: fullScreen)),
    );
  }
}
