import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_video_view/flutter_video_view.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:anicat/UrlParse.dart';
import 'package:anicat/AnimeDownloader.dart';
import 'package:anicat/Calc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniCat Downloader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 183, 58, 156)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'AniCat'),
    );
  }
}

mixin _Load {
  Future<List<FileSystemEntity>> _loadFiles(String folderPath) async {
    final directory = Directory(folderPath);
    var folders =
        await directory.list().where((entity) => entity is File).toList();
    return folders;
  }

  Future<void> _openFolder(BuildContext context, String folderPath) async {
    final files = await _loadFiles(folderPath);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FileListScreen(folderPath: folderPath, files: files),
      ),
    );
  }

  Future<String> _getThumbnail(File file) async {
    try {
      Uint8List? thumbnail = await VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.PNG,
        timeMs: 720000,
        quality: 100,
      );
      img.Image image = img.decodeImage(thumbnail!)!;
      final cache = await getApplicationCacheDirectory();
      String hash = sha256
          .convert(
              utf8.encode(file.path.split("/").last.replaceAll(".mp4", "")))
          .toString()
          .substring(0, 16);
      var path = "${cache.path}/$hash.png";
      debugPrint("Saving $path");
      File(path).writeAsBytesSync(img.encodePng(image));
      return path;
    } catch (e) {
      debugPrint("Error ${e.toString()}");
      return "";
    }
  }
}

mixin _Rotate {
  void setPortraitMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void setLandscapeMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void enableRotation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with _Load, _Rotate {
  List<String> folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final root = await getExternalStorageDirectory();
    if (root == null) {
      debugPrint('No external storage found.');
      return;
    }

    final directory = Directory(root.path);
    final folderList = await directory
        .list()
        .where((entity) => entity is Directory)
        .map((entity) => entity.path)
        .toList();
    setState(() {
      folders = folderList;
    });
  }

  void _onAddButtonPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController textController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Anime1 URL'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter URL here',
            ),
            maxLines: 1,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final inputUrl = textController.text;
                Navigator.of(context).pop();
                parse(inputUrl).then((urls) async {
                  if (urls.isEmpty) {
                    if (mounted) {
                      showDialog(
                        context: super.context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('No Anime1 URL Found'),
                            content: const Text(
                                'No valid URL matches were found. Please try again with a different URL.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                  urls = urls.reversed.toList();
                  var folder = urls.removeAt(0);
                  if (mounted) {
                    showDialog(
                      context: super.context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Downloading Anime: $folder'),
                          content: const LinearProgressIndicator(),
                        );
                      },
                    );
                  }
                  for (var url in urls) {
                    var anime = MP4(folder: folder, url: url);
                    await anime.init();
                    debugPrint("Get Started for ${anime.title}");
                    Future.delayed(const Duration(seconds: 3), () {});
                    if (mounted) {
                      showDialog(
                        context: super.context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          bool dialogClosed = false;
                          return StreamBuilder<double>(
                            stream: anime.progressStream,
                            initialData: 0.0,
                            builder: (context, snapshot) {
                              final progress = snapshot.data ?? 0.0;
                              if (progress >= 1.0 && !dialogClosed) {
                                dialogClosed = true;
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (Navigator.canPop(context)) {
                                    Navigator.of(context).pop();
                                  }
                                });
                              }
                              return AlertDialog(
                                title: Text('Downloading ${anime.title}'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    LinearProgressIndicator(value: progress),
                                    const SizedBox(height: 10),
                                    Text(
                                        '${convertMB(anime.current)}/${convertMB(anime.size)}  ${(progress * 100).toStringAsFixed(2)}% Completed'),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    await anime.download();
                  }
                  if (mounted && Navigator.canPop(super.context)) {
                    debugPrint("Download Completed");
                    Navigator.of(super.context).pop();
                  }
                }).catchError((error) {
                  debugPrint(error.toString());
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFolders,
        child: ListView.builder(
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folderPath = folders[index];
            final folderName = folderPath.split('/').last;
            return FutureBuilder(
              future: _loadFiles(folderPath),
              builder: (context, snapshot) {
                final files = snapshot.data;
                if (files == null || files.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ListTile(
                  title: Text(folderName),
                  subtitle: Text("${files.length} Files"),
                  leading: const Icon(Icons.folder),
                  onTap: () => _openFolder(context, folderPath),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onAddButtonPressed();
        },
        tooltip: 'Add Anime1 URL',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FileListScreen extends StatefulWidget {
  final String folderPath;
  final List<FileSystemEntity> files;

  const FileListScreen({
    super.key,
    required this.folderPath,
    required this.files,
  });

  @override
  FileListScreenState createState() => FileListScreenState();
}

class FileListScreenState extends State<FileListScreen> with _Load, _Rotate {
  List<FileSystemEntity> _files = [];
  Future<List<String>>? _fileCacheMap;

  @override
  void initState() {
    super.initState();
    _loadFiles(widget.folderPath).then((value) => setState(() {
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
    final cache = await getApplicationCacheDirectory();
    for (var file in files) {
      String hash = sha256
          .convert(
              utf8.encode(file.path.split("/").last.replaceAll(".mp4", "")))
          .toString()
          .substring(0, 16);
      var path = "${cache.path}/$hash.png";
      if (!await File(path).exists()) {
        debugPrint("Downloading ${file.path}");
        await _getThumbnail(file as File).then((value) => {hashMap.add(value)});
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
              _loadFiles(widget.folderPath).then((value) => setState(() {
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

class VideoPlayerScreen extends StatefulWidget {
  final String filePath;
  const VideoPlayerScreen({super.key, required this.filePath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with _Rotate {
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
