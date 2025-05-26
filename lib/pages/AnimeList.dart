import 'package:flutter/material.dart';

import 'package:anicat/pages/MyHomePage.dart';
import 'package:anicat/functions/behavior/ImgCache.dart';
import 'package:anicat/functions/behavior/PathHandle.dart';
import 'package:anicat/widget/MyHomePage/onDeletePress.dart';
import 'package:anicat/widget/MyHomePage/onPropertiesPress.dart';

class AnimeList extends StatefulWidget {
  const AnimeList({super.key});

  @override
  State<AnimeList> createState() => _AnimeList();
}

class _AnimeList extends State<AnimeList>
    with RouteAware, PathHandle, ImgCache {
  List<String> folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    List<String> folderList = await loadFolders();
    setState(() {
      folders = folderList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      (value) {
                        if (value == 'properties') {
                          onFolderPropertiesPress(context, folderName, files);
                        } else if (value == 'delete') {
                          onFolderDeletePress(context, folderPath, files);
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
