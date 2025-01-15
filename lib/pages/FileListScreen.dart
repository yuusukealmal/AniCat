import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:anicat/functions/behavior/PathLoad.dart';
import 'package:anicat/functions/behavior/ScreenRotate.dart';
import 'package:anicat/functions/Calc.dart';
import 'package:anicat/pages/VideoPlayerScreen.dart';

class FileListScreen extends StatefulWidget {
  final String folderPath;
  final List<FileSystemEntity> files;

  const FileListScreen({
    super.key,
    required this.folderPath,
    required this.files,
  });

  @override
  State<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> with Load, Rotate {
  List<FileSystemEntity> _files = [];
  Future<List<String>>? _fileCacheMap;

  @override
  void initState() {
    super.initState();
    loadFiles(widget.folderPath).then((value) => setState(() {
          _files = value;
          _fileCacheMap = _cacheImage(value);
        }));
  }

  @override
  void dispose() {
    setPortraitMode();
    super.dispose();
  }

  Future<List<String>> _cacheImage(List<FileSystemEntity> files) async {
    List<String> hashMap = [];
    for (var file in files) {
      String hash = sha256
          .convert(
              utf8.encode(file.path.split("/").last.replaceAll(".mp4", "")))
          .toString()
          .substring(0, 16);
      var cacheImgFolder = await getCacheImgFolder();
      var path = "${cacheImgFolder.path}/$hash.png";
      if (!await File(path).exists()) {
        debugPrint("Downloading ${file.path}");
        await getThumbnail(file as File).then((value) => {hashMap.add(value)});
      } else {
        debugPrint("Cached ${file.path}");
        hashMap.add(path);
      }
    }
    return hashMap;
  }

  ListView _fileListView([List<String>? cacheThumbnail]) {
    return ListView.builder(
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index] as File;
        final fileName = file.path.split('/').last;
        return ListTile(
          title: Text(fileName),
          subtitle: Text(getFileSize(file.lengthSync())),
          leading: {
                'mp4': cacheThumbnail?[index] != null &&
                        cacheThumbnail?[index] != ""
                    ? Image(image: FileImage(File(cacheThumbnail![index])))
                    : const Icon(Icons.video_file),
                'mkv': const Icon(Icons.video_file),
                'webm': const Icon(Icons.video_file),
                'jpg': const Icon(Icons.image),
                'png': const Icon(Icons.image),
                'jpeg': const Icon(Icons.image),
                'gif': const Icon(Icons.gif),
                'mp3': const Icon(Icons.music_note),
                'wav': const Icon(Icons.music_note),
                'aac': const Icon(Icons.music_note),
                'ogg': const Icon(Icons.music_note),
                'm4a': const Icon(Icons.music_note),
                'flac': const Icon(Icons.music_note),
                'mp4v': const Icon(Icons.video_file),
                'mov': const Icon(Icons.video_file),
                'wmv': const Icon(Icons.video_file),
                'avi': const Icon(Icons.video_file),
              }[fileName.split(".").last] ??
              Icon(Icons.insert_drive_file),
          onTap: () {
            debugPrint('Tapped file: $fileName');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(filePath: file.path)),
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
            icon: const Icon(Icons.keyboard_backspace_sharp)),
        title: Text(widget.folderPath.split('/').last),
      ),
      body: RefreshIndicator(
          onRefresh: () =>
              loadFiles(widget.folderPath).then((value) => setState(() {
                    _files = value;
                  })),
          child: FutureBuilder(
              future: _fileCacheMap,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _fileListView();
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded),
                      Text("Progress Thumbnail Cache Failed")
                    ],
                  ));
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return _fileListView(snapshot.data!);
                }
                return SizedBox.shrink();
              })),
    );
  }
}
