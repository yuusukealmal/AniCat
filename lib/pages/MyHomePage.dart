import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anicat/api/AnimeList.dart';
import 'package:anicat/config/notifier/ThemeProvider.dart';
import 'package:anicat/config/notifier/OverlayProvider.dart';
import 'package:anicat/downloader/UrlParse.dart';
import 'package:anicat/downloader/AnimeDownloader.dart';
import 'package:anicat/functions/behavior/PathHandle.dart';
import 'package:anicat/functions/behavior/ImgCache.dart';
import 'package:anicat/functions/behavior/ScreenRotate.dart';
import 'package:anicat/pages/SettingScreen.dart';
import 'package:anicat/widget/MyHomePage/onPropertiesPress.dart';
import 'package:anicat/widget/MyHomePage/onDeletePress.dart';
import 'package:anicat/widget/MyHomePage/onAddButtonPressed/AnimeInvalid.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class _MyHomePageState extends State<MyHomePage>
    with PathHandle, ImgCache, ScreenRotate, RouteAware {
  List<String> folders = [];
  List<List<dynamic>> animes = [];
  late OverlayProvider overlayProvider;

  @override
  void initState() {
    super.initState();
    _getManifest();
    _loadFolders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  Future<void> _loadFolders() async {
    List<String> folderList = await loadFolders();
    setState(() {
      folders = folderList;
    });
  }

  Future<void> _getManifest() async {
    List<List<dynamic>> animeList = await getAnimeList();
    setState(() {
      animes = animeList.where((e) => !e[1].contains("https://")).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Got ${animes.length} animes")),
    );
  }

  @override
  void didPopNext() {
    _loadFolders();
  }

  void _toggleTheme() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.toggleTheme();
  }

  void _onAddButtonPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _textController = TextEditingController();
        List<List<dynamic>> catId = [];

        return StatefulBuilder(
          builder: (context, setState) {
            List<List<dynamic>> filteredAnimes = animes
                .where((anime) => anime[1]
                    .toString()
                    .toLowerCase()
                    .contains(_textController.text.toLowerCase()))
                .toList();
            return Dialog(
              child: Material(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Anime Selector',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _textController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter Anime URL or Title here',
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(),
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("符合條件的數量: ${filteredAnimes.length}"),
                          SizedBox(width: 16),
                          Text("已選擇數量 : ${catId.length}"),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            child: Text("顯示選擇清單"),
                            onPressed: () {
                              if (catId.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListView.builder(
                                            itemCount: catId.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              List<String> anime = catId[index]
                                                  .map((e) => e.toString())
                                                  .toList();
                                              return ListTile(
                                                title: Text(
                                                  anime[1],
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                subtitle: Text(
                                                  "${anime[3]} ${anime[4]} ${anime[2]}",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                child: Text("關閉"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              SizedBox(width: 16),
                                            ],
                                          ),
                                          SizedBox(height: 16),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("沒有選擇任何動漫"),
                                  ),
                                );
                              }
                            },
                          )
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredAnimes.isEmpty
                              ? 1
                              : filteredAnimes.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (filteredAnimes.isEmpty) {
                              String text =
                                  _textController.text.startsWith("https")
                                      ? "使用https連結下載"
                                      : "找不到符合條件的動漫";
                              return ListTile(
                                title: Text(
                                  text,
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                            }
                            List<dynamic> anime = filteredAnimes[index];
                            return ListTile(
                              title: Text(
                                anime[1].toString(),
                                style: TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                "${anime[3]} ${anime[4]} ${anime[2]}",
                                style: TextStyle(fontSize: 14),
                              ),
                              trailing: IconButton(
                                icon: catId.contains(anime)
                                    ? Icon(Icons.remove)
                                    : Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    catId.contains(anime)
                                        ? catId.remove(anime)
                                        : catId.add(anime);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              overlayProvider.setIsDownloading(false);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              List<String> inputList = catId.isNotEmpty
                                  ? catId
                                      .map((id) =>
                                          "https://anime1.me/?cat=${id[0]}")
                                      .toList()
                                  : [_textController.text];
                              overlayProvider.setIsDownloading(true);
                              Navigator.of(context).pop();
                              for (String inputUrl in inputList) {
                                await parse(inputUrl).then((urls) async {
                                  if (urls.isEmpty) {
                                    if (mounted) {
                                      animeInvalidDialog(context);
                                      return;
                                    }
                                  }
                                  urls = urls.reversed.toList();
                                  String folder = urls.removeAt(0);
                                  for (String url in urls) {
                                    MP4 anime = MP4(folder: folder, url: url);
                                    await anime.init();
                                    debugPrint(
                                        "Get Started for ${anime.title}");

                                    double _progress = 0.0;

                                    anime.progressStream
                                        .listen((progress) async {
                                      _progress = progress;

                                      if (_progress >= 1.0) {
                                        debugPrint("Download Completed");

                                        await _loadFolders();
                                        await checkCache(folder, anime);
                                      }
                                    });

                                    await anime.download(super.context);
                                  }
                                  debugPrint("Download Completed");
                                }).catchError((error) {
                                  debugPrint("Error: $error");
                                });
                              }
                              overlayProvider.setIsDownloading(false);
                            },
                            child: const Text('OK'),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    overlayProvider = Provider.of<OverlayProvider>(context, listen: false);
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
          icon: const Icon(Icons.menu),
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.light_mode_outlined),
            tooltip: 'Toggle Theme',
            onPressed: _toggleTheme,
          ),
        ],
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
                          onFolderPropertiesPress(context, folderName, files);
                        } else if (value == 'delete') {
                          onFolderDeletePress(context, folderPath, files);
                          setState(() {});
                        }
                      });
                    });
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: overlayProvider.isDownloading ? null : _onAddButtonPressed,
        tooltip: "Add Anime1 URL",
        child: const Icon(Icons.add),
      ),
    );
  }
}
