import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:anicat/parse.dart';
import 'package:anicat/handle.dart';
import 'package:anicat/calc.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
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
}

class _MyHomePageState extends State<MyHomePage> with _Load {
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
                        return StreamBuilder<double>(
                          stream: anime.progressStream,
                          initialData: 0.0,
                          builder: (context, snapshot) {
                            final progress = snapshot.data ?? 0.0;
                            if (progress >= 1.0) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
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
            return ListTile(
              title: Text(folderName),
              leading: const Icon(Icons.folder),
              onTap: () => _openFolder(context, folderPath),
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

class FileListScreenState extends State<FileListScreen> with _Load {
  List<FileSystemEntity> _files = [];

  @override
  void initState() {
    super.initState();
    _loadFiles(widget.folderPath).then((value) => setState(() {
          _files = value;
        }));
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
        child: ListView.builder(
          itemCount: _files.length,
          itemBuilder: (context, index) {
            final file = _files[index] as File;
            final fileName = file.path.split('/').last;
            return ListTile(
              title: Text(fileName),
              leading: {
                    'mp4': const Icon(Icons.video_file),
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
                  }[fileName.split('.').last] ??
                  const Icon(Icons.insert_drive_file),
              onTap: () {
                debugPrint('Tapped file: $fileName');
              },
            );
          },
        ),
      ),
    );
  }
}
