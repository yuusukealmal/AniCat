import 'dart:io';
import 'package:flutter/material.dart';
import 'package:anicat/functions/behavior/PathLoad.dart';
import 'package:anicat/functions/behavior/ScreenRotate.dart';
import 'package:anicat/downloader/UrlParse.dart';
import 'package:anicat/downloader/AnimeDownloader.dart';
import 'package:anicat/functions/Calc.dart';
import 'package:anicat/pages/SettingScreen.dart';

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
                  for (var url in urls) {
                    var anime = MP4(folder: folder, url: url);
                    await anime.init();
                    debugPrint("Get Started for ${anime.title}");

                    double _progress = 0.0;
                    int _current = 0;
                    bool _isOverlayVisible = false;

                    OverlayEntry? overlayEntry;

                    void updateOverlay() {
                      overlayEntry?.markNeedsBuild();
                    }

                    if (!_isOverlayVisible) {
                      _isOverlayVisible = true;

                      overlayEntry = OverlayEntry(
                        builder: (context) {
                          return Positioned(
                            bottom: 50,
                            left: 20,
                            right: 20,
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Downloading ${anime.title}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(value: _progress),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${convertMB(_current)}/${convertMB(anime.size)}  '
                                      '${(_progress * 100).toStringAsFixed(2)}% Completed',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );

                      Overlay.of(super.context).insert(overlayEntry);
                    }

                    anime.progressStream.listen((progress) {
                      _progress = progress;
                      _current = anime.current;

                      updateOverlay();

                      if (_progress >= 1.0) {
                        debugPrint("Download Completed");

                        overlayEntry?.remove();
                        _isOverlayVisible = false;

                        ScaffoldMessenger.of(super.context)
                            .showSnackBar(const SnackBar(
                          content: Text("Download Completed"),
                          duration: Duration(seconds: 3),
                        ));
                      }
                    });

                    await anime.download();

                    if (_isOverlayVisible) {
                      overlayEntry.remove();
                      _isOverlayVisible = false;
                    }
                  }
                  debugPrint("Download Completed");
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
                return GestureDetector(
                    child: ListTile(
                      title: Text(folderName),
                      subtitle: Text("${files.length} Files"),
                      leading: const Icon(Icons.folder),
                      onTap: () => openFolder(context, folderPath),
                    ),
                    onLongPressStart: (details) {
                      final Offset position = details.globalPosition;
                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(
                            position.dx, position.dy, position.dx, 0),
                        items: [
                          PopupMenuItem(
                              value: 'properties',
                              child: ListTile(
                                title: Text('屬性'),
                                leading: const Icon(Icons.info),
                              )),
                          PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                title: Text('刪除資料夾'),
                                leading: const Icon(Icons.delete),
                              )),
                        ],
                      ).then((value) {
                        if (value == 'properties') {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: Text(folderName),
                                    content: Text(
                                      "影片數量: ${files.length}\n總大小: ${convertMB(files.fold(0, (total, file) => total + (file as File).lengthSync()))}",
                                    ),
                                    actions: [
                                      TextButton(
                                          child: Text("關閉"),
                                          onPressed: () =>
                                              Navigator.of(context).pop()),
                                    ],
                                  ));
                        } else if (value == 'delete') {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: Text("刪除資料夾"),
                                    content: Text("確定要刪除資料夾嗎?"),
                                    actions: [
                                      TextButton(
                                          child: Text("取消"),
                                          onPressed: () =>
                                              Navigator.of(context).pop()),
                                      TextButton(
                                          child: Text("刪除"),
                                          onPressed: () {
                                            for (var file in files) {
                                              (file as File).deleteSync();
                                            }
                                            Navigator.of(context).pop();
                                          }),
                                    ],
                                  ));
                        }
                      });
                    });
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
