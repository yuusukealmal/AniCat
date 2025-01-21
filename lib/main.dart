import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anicat/config/SharedPreferences.dart';
import 'package:anicat/functions/behavior/PathLoad.dart';
import 'package:anicat/functions/behavior/ScreenRotate.dart';
import 'package:anicat/downloader/UrlParse.dart';
import 'package:anicat/downloader/AnimeDownloader.dart';
import 'package:anicat/functions/Calc.dart';
import 'package:anicat/pages/SettingScreen.dart';
import 'package:anicat/config/notifier/HomeColorNotifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesHelper.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            final colorNotifier = ColorNotifier();
            colorNotifier.init();
            return colorNotifier;
          }),
        ],
        builder: (context, child) {
          final color = Provider.of<ColorNotifier>(context);
          return MaterialApp(
            title: "AniCat Downloader",
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: color.color ?? Color.fromARGB(255, 183, 58, 156)),
              useMaterial3: true,
            ),
            home: const MyHomePage(title: "AniCat"),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with Load, Rotate {
  List<String> folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final directory = await getDownloadPath();

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
        leading: IconButton(
            tooltip: "Open Settings",
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingScreen()),
              );
            },
            icon: const Icon(Icons.menu)),
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
              future: loadFiles(folderPath),
              builder: (context, snapshot) {
                final files = snapshot.data;
                if (files == null || files.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ListTile(
                  title: Text(folderName),
                  subtitle: Text("${files.length} Files"),
                  leading: const Icon(Icons.folder),
                  onTap: () => openFolder(context, folderPath),
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
        tooltip: "Add Anime1 URL",
        child: const Icon(Icons.add),
      ),
    );
  }
}
