import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:anicat/api/AnimeList.dart';
import 'package:anicat/downloader/UrlParse.dart';
import 'package:anicat/downloader/AnimeDownloader.dart';
import 'package:anicat/functions/behavior/ImgCache.dart';
import 'package:anicat/config/notifier/OverlayProvider.dart';
import 'package:anicat/widget/AnimeSearch/AnimeInvalid.dart';
import 'package:anicat/widget/AnimeSearch/ShowSelectAnime.dart';

class AnimeSearch extends StatefulWidget {
  const AnimeSearch({super.key});

  @override
  State<AnimeSearch> createState() => _AnimeSearch();
}

class _AnimeSearch extends State<AnimeSearch> with ImgCache {
  List<AnimeValue> animes = [];
  List<AnimeValue> selectedAnimes = [];
  TextEditingController _textController = TextEditingController();

  Future<void> _getManifest() async {
    List<AnimeValue> animeList = await getAnimeList();
    if (!mounted) return;
    setState(() {
      animes = animeList.where((e) => !e.name.contains("https://")).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _getManifest();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        List<AnimeValue> filteredAnimes = animes
            .where((anime) => anime.name
                .toString()
                .toLowerCase()
                .contains(_textController.text.toLowerCase()))
            .toList();
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _textController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  hintText: 'Enter Anime URL or Title here',
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
                  Text("已選擇數量 : ${selectedAnimes.length}"),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredAnimes.isEmpty ? 1 : filteredAnimes.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (filteredAnimes.isEmpty) {
                      String text = _textController.text.startsWith("https")
                          ? "使用https連結下載"
                          : "找不到符合條件的動漫";
                      return ListTile(
                        title: Text(
                          text,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }
                    AnimeValue anime = filteredAnimes[index];
                    return ListTile(
                      title: Text(
                        anime.name.toString(),
                        style: TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        "${anime.year} ${anime.season} ${anime.status}",
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: selectedAnimes.contains(anime)
                            ? Icon(Icons.remove)
                            : Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            selectedAnimes.contains(anime)
                                ? selectedAnimes.remove(anime)
                                : selectedAnimes.add(anime);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () async {
                      if (!context.read<OverlayProvider>().isDownloading) {
                        await _getManifest();
                      }
                    },
                    child: const Text("重新取得動漫"),
                  ),
                  TextButton(
                    child: const Text('顯示已選取'),
                    onPressed: () {
                      if (selectedAnimes.isNotEmpty) {
                        showSelected(context, selectedAnimes);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("沒有選擇任何動漫"),
                          ),
                        );
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (context.read<OverlayProvider>().isDownloading) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("正在下載中，請等待下載完再嘗試"),
                          ),
                        );
                      } else {
                        List<String> finalSelectedAnimes =
                            selectedAnimes.isNotEmpty
                                ? selectedAnimes
                                    .map((anime) =>
                                        "https://anime1.me/?cat=${anime.id}")
                                    .toList()
                                : [_textController.text];
                        context.read<OverlayProvider>().setIsDownloading(true);
                        for (String inputUrl in finalSelectedAnimes) {
                          await parse(inputUrl).then((urls) async {
                            if (urls.isEmpty) {
                              if (mounted) {
                                animeInvalidDialog(context);
                              }
                            }
                            urls = urls.reversed.toList();
                            String folder = urls.removeAt(0);
                            for (String url in urls) {
                              MP4 anime = MP4(folder: folder, url: url);
                              await anime.init();
                              debugPrint("Get Started for ${anime.title}");

                              double _progress = 0.0;

                              anime.progressStream.listen((progress) async {
                                _progress = progress;

                                if (_progress >= 1.0) {
                                  debugPrint("Download Completed");
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
                        context.read<OverlayProvider>().setIsDownloading(false);
                      }
                    },
                    child: const Text('開始下載'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
