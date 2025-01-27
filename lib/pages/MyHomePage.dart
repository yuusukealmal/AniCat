import 'dart:io';
import 'package:flutter/material.dart';
import 'package:anicat/functions/behavior/PathHandle.dart';
import 'package:anicat/functions/behavior/ImgCache.dart';
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

class _MyHomePageState extends State<MyHomePage>
    with PathHandle, ImgCache, ScreenRotate {
  List<String> folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    List<String> folderList = await loadFolders();
    setState(() {
      folders = folderList;
    });
  }

  void _onAddButtonPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController textController = TextEditingController();
        return Dialog(
          backgroundColor: Colors.transparent,
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
                  const Text(
                    'Enter Anime1 URL',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter URL here',
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(
                        color: Colors.white), // White text color
                    maxLines: 1,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'No Anime1 URL Found',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              const SizedBox(height: 8),
                                              const Text(
                                                'No valid URL matches were found. Please try again with a different URL.',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              const SizedBox(height: 8),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text(
                                                    'OK',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            }
                            urls = urls.reversed.toList();
                            String folder = urls.removeAt(0);
                            for (String url in urls) {
                              MP4 anime = MP4(folder: folder, url: url);
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
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Downloading ${anime.title}',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              const SizedBox(height: 8),
                                              LinearProgressIndicator(
                                                  value: _progress),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${convertMB(_current)}/${convertMB(anime.size)}  '
                                                '${(_progress * 100).toStringAsFixed(2)}% Completed',
                                                style: const TextStyle(
                                                    color: Colors.white),
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

                              anime.progressStream.listen((progress) async {
                                _progress = progress;
                                _current = anime.current;

                                updateOverlay();

                                if (_progress >= 1.0) {
                                  debugPrint("Download Completed");
                                  await _loadFolders();

                                  Directory animeFolder =
                                      await PathHandle.getDownloadPath();
                                  String path =
                                      "${animeFolder.path}/$folder/${anime.title}.mp4";
                                  Directory cacheImgFolder =
                                      await ImgCache.getImgCacheFolder();
                                  String imgCachepath =
                                      "${cacheImgFolder.path}/${getHash(anime.title!)}.png";
                                  if (!File(imgCachepath).existsSync()) {
                                    await getThumbnail(File(path));
                                  }

                                  ScaffoldMessenger.of(super.context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        "Download Completed ${anime.title}"),
                                    duration: Duration(seconds: 1),
                                  ));

                                  overlayEntry?.remove();
                                  _isOverlayVisible = false;
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
                        child: const Text(
                          'OK',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors.transparent,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          folderName,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "影片數量: ${files.length}\n總大小: ${convertMB(files.fold(0, (total, file) => total + (file as File).lengthSync()))}\n創建日期: ${(files.first as File).lastModifiedSync().toLocal()}",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        const SizedBox(height: 16),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text(
                                              "關閉",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors.transparent,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "刪除資料夾",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "確定要刪除資料夾嗎?",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text(
                                                "取消",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () {
                                                for (FileSystemEntity file
                                                    in files) {
                                                  (file as File).deleteSync();
                                                }
                                                Navigator.of(context).pop();
                                                setState(() {});
                                              },
                                              child: const Text(
                                                "刪除",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
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
