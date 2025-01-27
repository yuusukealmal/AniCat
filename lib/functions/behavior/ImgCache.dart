import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:anicat/downloader/AnimeDownloader.dart';
import 'package:anicat/functions/behavior/PathHandle.dart';

mixin ImgCache {
  static Future<Directory> getImgCacheFolder() async {
    final Directory cacheDir = await getApplicationCacheDirectory();
    Directory cachePath = Directory("${cacheDir.path}/img");
    if (!await cachePath.exists()) {
      await cachePath.create(recursive: true);
    }

    return cachePath;
  }

  String getHash(String filePath) {
    String hash = sha256
        .convert(utf8.encode(filePath.split("/").last.replaceAll(".mp4", "")))
        .toString()
        .substring(0, 16);
    return hash;
  }

  Future<String> getThumbnail(File file) async {
    try {
      Uint8List? thumbnail = await VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.PNG,
        timeMs: 720000,
        quality: 100,
      );

      String hash = getHash(file.path);
      Directory cacheImgFolder = await getImgCacheFolder();
      String path = "${cacheImgFolder.path}/$hash.png";
      debugPrint("Saving $path");
      File(path).writeAsBytes(thumbnail!);
      return path;
    } catch (e) {
      debugPrint("Error ${e.toString()}");
      return "";
    }
  }

  Future<void> checkCache(String folder, MP4 anime) async {
    Directory animeFolder = await PathHandle.getDownloadPath();
    String path = "${animeFolder.path}/$folder/${anime.title}.mp4";
    Directory cacheImgFolder = await ImgCache.getImgCacheFolder();
    String imgCachepath = "${cacheImgFolder.path}/${getHash(anime.title!)}.png";
    if (!File(imgCachepath).existsSync()) {
      await getThumbnail(File(path));
    }
  }
}
