import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:path/path.dart';

import 'package:anicat/functions/utils.dart';
import 'package:anicat/functions/behavior/ProgressHandle.dart';
import 'package:anicat/functions/behavior/PathHandle.dart';
import 'package:anicat/functions/behavior/ImgCache.dart';
import 'package:anicat/functions/behavior/ScreenRotate.dart';
import 'package:anicat/pages/VideoPlayerScreen.dart';
import 'package:anicat/widget/FileListScreen/getFileLeading.dart';

class FileListScreen extends StatefulWidget {
  final String folderPath;

  const FileListScreen({
    super.key,
    required this.folderPath,
  });

  @override
  State<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen>
    with PathHandle, ImgCache, ScreenRotate {
  List<FileSystemEntity> _files = [];
  List<String> _fileCacheMap = [];
  Map<String, Duration?> _durations = {};

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    setPortraitMode();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    final files = await loadFolderFiles(widget.folderPath);
    setState(() {
      _files = files;
      _durations = {};
    });
    for (final file in files) {
      if (file is File) {
        getVideoDuration(file).then((duration) {
          if (mounted) {
            setState(() {
              _durations[file.path] = duration;
            });
          }
        });
      }
    }
    _cacheImage(files);
  }

  Future<void> _cacheImage(List<FileSystemEntity> files) async {
    for (FileSystemEntity file in files) {
      String hash = getHash(file as File);
      Directory cacheImgFolder = await ImgCache.getImgCacheFolder();
      String path = "${cacheImgFolder.path}/$hash.png";
      if (!await File(path).exists()) {
        debugPrint("Downloading ${file.path}");
        String thumbnailPath = await getThumbnail(file);
        setState(() {
          _fileCacheMap.add(thumbnailPath);
        });
      } else {
        debugPrint("Cached ${file.path}");
        setState(() {
          _fileCacheMap.add(path);
        });
      }
    }
  }

  ListView _fileListView() {
    return ListView.builder(
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index] as File;
        final duration = _durations[file.path];
        final size = getFileSize(file.lengthSync());
        return FutureBuilder<String?>(
          future: Config.getLastView(file),
          builder: (context, snapshot) {
            final lastView = snapshot.data;
            return ListTile(
              title: lastView == getHash(file)
                  ? Text(
                      file.uri.pathSegments.last,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 6, 124, 235),
                      ),
                    )
                  : Text(file.uri.pathSegments.last),
              subtitle: Text(size),
              leading: getFileLeading(
                extension(file.uri.pathSegments.last),
                index,
                _fileCacheMap,
                formatDuration(duration),
              ),
              onTap: () async {
                debugPrint('Tapped file: ${file.uri.pathSegments.last}');
                await Config.writeLastView(file);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(filePath: file),
                  ),
                );
                setState(() {});
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.keyboard_backspace_sharp,
          ),
        ),
        title: Text(widget.folderPath.split('/').last),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadFiles();
        },
        child: _fileListView(),
      ),
    );
  }
}
