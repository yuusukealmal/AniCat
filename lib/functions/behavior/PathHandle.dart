import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:anicat/config/SharedPreferences.dart';
import 'package:anicat/pages/FileListScreen.dart';

mixin PathHandle {
  static Future<Directory> getDownloadPath() async {
    String path = SharedPreferencesHelper.getString("Anime.DownloadPath") ??
        (await getExternalStorageDirectory())!.path;
    return Directory(path);
  }

  Future<List<String>> loadFolders() async {
    debugPrint("Loading Folders");
    final directory = await PathHandle.getDownloadPath();

    final folderList = await directory
        .list()
        .where((entity) => entity is Directory)
        .map((entity) => entity.path)
        .toList();
    folderList.sort((a, b) => a.compareTo(b));
    return folderList;
  }

  Future<List<FileSystemEntity>> loadFiles(String folderPath) async {
    final directory = Directory(folderPath);
    List<FileSystemEntity> folders =
        await directory.list().where((entity) => entity is File).toList();
    return folders;
  }

  Future<void> openFolder(BuildContext context, String folderPath) async {
    final files = await loadFiles(folderPath);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FileListScreen(folderPath: folderPath, files: files),
      ),
    );
  }
}
