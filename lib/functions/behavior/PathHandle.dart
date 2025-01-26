import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:anicat/pages/FileListScreen.dart';
import 'package:anicat/config/SharedPreferences.dart';

mixin PathHandle {
  static Future<Directory> getDownloadPath() async {
    String path = SharedPreferencesHelper.getString("Anime.DownloadPath") ??
        (await getExternalStorageDirectory())!.path;
    return Directory(path);
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
