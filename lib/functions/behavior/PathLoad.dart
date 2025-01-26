import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:anicat/pages/FileListScreen.dart';
import 'package:anicat/config/SharedPreferences.dart';

mixin Load {
  Future<Directory> getDownloadPath() async {
    String path = SharedPreferencesHelper.getString("Anime.DownloadPath") ??
        (await getExternalStorageDirectory())!.path;
    return Directory(path);
  }

  Future<List<FileSystemEntity>> loadFiles(String folderPath) async {
    final directory = Directory(folderPath);
    var folders =
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

  static Future<Directory> getCacheImgFolder() async {
    final Directory cacheDir = await getApplicationCacheDirectory();
    var cachePath = Directory("${cacheDir.path}/img");
    if (!await cachePath.exists()) {
      await cachePath.create(recursive: true);
    }

    return cachePath;
  }

  Future<String> getThumbnail(File file) async {
    try {
      Uint8List? thumbnail = await VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.PNG,
        timeMs: 720000,
        quality: 100,
      );
      String result = await compute(_processThumbnail, [file.path, thumbnail]);
      return result;
    } catch (e) {
      debugPrint("Error ${e.toString()}");
      return "";
    }
  }

  Future<String> _processThumbnail(List<dynamic> args) async {
    String filePath = args[0];
    Uint8List thumbnail = args[1];

    img.Image image = img.decodeImage(thumbnail)!;

    String hash = sha256
        .convert(utf8.encode(filePath.split("/").last.replaceAll(".mp4", "")))
        .toString()
        .substring(0, 16);

    var cacheImgFolder = await getCacheImgFolder();
    var path = "${cacheImgFolder.path}/$hash.png";

    File(path).writeAsBytesSync(img.encodePng(image));
    debugPrint("Saving $path");
    return path;
  }
}
