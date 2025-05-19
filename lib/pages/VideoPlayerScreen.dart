import 'dart:async';
import 'dart:io';
import 'package:anicat/config/notifier/OverlayProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_view/flutter_video_view.dart';
import 'package:anicat/config/SharedPreferences.dart';
import 'package:anicat/functions/behavior/ScreenRotate.dart';
import 'package:provider/provider.dart';
import 'package:anicat/functions/behavior/ProgressWriter.dart';

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
  Duration? startTime;

  @override
  void initState() {
    super.initState();
    setLandscapeMode();
    Provider.of<OverlayProvider>(context, listen: false).setIsVideoScreen(true);

    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    _videoPlayerController!.setPlaybackSpeed(playbackSpeed);

    _initStartTime();
  }

  Future<void> _initStartTime() async {
    final duration = await Config.readDuration(File(widget.filePath));
    setState(() {
      startTime = duration;
    });
  }

  @override
  void dispose() {
    final pauseTime = _videoPlayerController?.value.position;
    unawaited(Config.writeDuration(File(widget.filePath), pauseTime!));
    _videoPlayerController?.dispose();
    setPortraitMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (startTime == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final overlayprovider =
        Provider.of<OverlayProvider>(context, listen: false);
    overlayprovider.removeOverlay();
    const red = '\x1B[31m';
    const reset = '\x1B[0m';
    debugPrint("startTime: $red$startTime$reset");

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          overlayprovider.setIsVideoScreen(false);
          overlayprovider.showOverlay(context);
        }
      },
      child: VideoView(
        controller: VideoController(
          videoPlayerController: _videoPlayerController!,
          videoConfig: VideoConfig(
            title: widget.filePath.split('/').last,
            showLock: true,
            autoPlay: atuoPlay,
            fullScreenByDefault: fullScreen,
            canCloseOnBack: true,
            startAt: startTime,
          ),
        ),
      ),
    );
  }
}
