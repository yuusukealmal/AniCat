import 'package:flutter/material.dart';

import 'package:anicat/functions/behavior/ImgCache.dart';
import 'package:anicat/functions/behavior/PathHandle.dart';
import 'package:anicat/widget/MyHomePage/onDeletePress.dart';
import 'package:anicat/widget/MyHomePage/onPropertiesPress.dart';

class AnimeList extends StatefulWidget {
  const AnimeList({super.key});

  @override
  AnimeListState createState() => AnimeListState();
}

class AnimeListState extends State<AnimeList> with PathHandle, ImgCache {
  List<String> folders = [];

  @override
  void initState() {
    super.initState();
    loadFolders();
  }

  Future<void> loadFolders() async {
    List<String> folderList = await loadStorageFolders();
    setState(() {
      folders = folderList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadFolders,
        child: ListView.builder(
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folderPath = folders[index];
            final folderName = folderPath.split('/').last;
            return FutureBuilder(
              future: loadFolderFiles(folderPath),
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
                    onTap: () => openAnimeFolder(context, folderPath),
                  ),
                  onLongPressStart: (details) {
                    final Offset position = details.globalPosition;
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        position.dx,
                        position.dy,
                        position.dx,
                        0,
                      ),
                      items: [
                        PopupMenuItem(
                          value: 'properties',
                          child: ListTile(
                            title: Text('屬性'),
                            leading: const Icon(Icons.info),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            title: Text('刪除資料夾'),
                            leading: const Icon(Icons.delete),
                          ),
                        ),
                      ],
                    ).then(
                      (value) async {
                        if (value == 'properties') {
                          onFolderPropertiesPress(context, folderName, files);
                        } else if (value == 'delete') {
                          await onFolderDeletePress(context, folderPath, files);
                          setState(() {});
                        }
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
