import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:anicat/config/SharedPreferences.dart';
import 'package:anicat/functions/Calc.dart';
import 'package:anicat/functions/behavior/PathHandle.dart';
import 'package:anicat/functions/behavior/ImgCache.dart';
import 'package:anicat/functions/behavior/ScreenRotate.dart';
import 'package:anicat/pages/VideoPlayerScreen.dart';
import 'package:anicat/widget/FileListScreen/getFileLeading.dart';

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

class _FileListScreenState extends State<FileListScreen>
    with PathHandle, ImgCache, ScreenRotate {
  List<FileSystemEntity> _files = [];
  List<String> _fileCacheMap = [];

  @override
  void initState() {
    super.initState();
    loadFiles(widget.folderPath).then((value) {
      setState(() {
        _files = value;
      });
      _cacheImage(value);
    });
  }

  @override
  void dispose() {
    setPortraitMode();
    super.dispose();
  }

  Future<void> _cacheImage(List<FileSystemEntity> files) async {
    for (FileSystemEntity file in files) {
      String hash = sha256
          .convert(
              utf8.encode(file.path.split("/").last.replaceAll(".mp4", "")))
          .toString()
          .substring(0, 16);
      Directory cacheImgFolder = await ImgCache.getImgCacheFolder();
      String path = "${cacheImgFolder.path}/$hash.png";
      if (!await File(path).exists()) {
        debugPrint("Downloading ${file.path}");
        String thumbnailPath = await getThumbnail(file as File);
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
        final fileName = file.path.split('/').last;
        String titleMd5 = sha256
            .convert(utf8.encode(widget.folderPath.split("/").last))
            .toString()
            .substring(0, 16);
        final lastView = SharedPreferencesHelper.getInt("LASTVIEW.$titleMd5");
        return ListTile(
          title: index == lastView
              ? Text(fileName,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 6, 124, 235)))
              : Text(fileName),
          subtitle: Text(getFileSize(file.lengthSync())),
          leading: getFileLeading(fileName, index, _fileCacheMap),
          onTap: () async {
            debugPrint('Tapped file: $fileName');
            await SharedPreferencesHelper.setInt("LASTVIEW.$titleMd5", index);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(filePath: file.path),
              ),
            );
            setState(() {});
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
        onRefresh: () => loadFiles(widget.folderPath).then((value) {
          setState(() {
            _files = value;
          });
          _cacheImage(value);
        }),
        child: _fileListView(),
      ),
    );
  }
}
