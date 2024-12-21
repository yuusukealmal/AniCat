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

class _MyHomePageState extends State<MyHomePage> {
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
        .map((entity) => entity.path.split('/').last)
        .toList();
    setState(() {
      folders = folderList;
    });
  }

  void _showProgress(BuildContext context, MP4 anime) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StreamBuilder<double>(
          stream: anime.progressStream,
          initialData: 0.0,
          builder: (context, snapshot) {
            final progress = snapshot.data ?? 0.0;
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
                    if (mounted) {
                      _showProgress(super.context, anime);
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
            return ListTile(
              title: Text(folders[index]),
              leading: const Icon(Icons.folder),
              onTap: () {
                debugPrint('Tapped folder: ${folders[index]}');
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddButtonPressed,
        tooltip: 'Add Anime1 URL',
        child: const Icon(Icons.add),
      ),
    );
  }
}
