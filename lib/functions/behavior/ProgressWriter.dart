import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class Config {
  static Future<Duration> readDuration(File filePath) async {
    try {
      final file = File('${filePath.parent.path}/progress.json');
      final fileName = filePath.uri.pathSegments.last;
      if (!await file.exists()) {
        await file.create(recursive: true);
        await file.writeAsString(jsonEncode({
          fileName: {"duration": Duration.zero.inSeconds}
        }));
        return Duration.zero;
      }

      final json = jsonDecode(await file.readAsString());
      if (json is Map && json.containsKey(fileName)) {
        final seconds = json[fileName]['duration'];
        if (seconds is num) {
          return Duration(seconds: seconds.toInt());
        } else {
          debugPrint('格式錯誤：duration 不是數字');
          return Duration.zero;
        }
      } else {
        json[fileName] = {"duration": Duration.zero.inSeconds};
        await file.writeAsString(jsonEncode(json), flush: true);
        return Duration.zero;
      }
    } catch (e) {
      debugPrint("讀取進度失敗：$e");
      return Duration.zero;
    }
  }

  static Future writeDuration(File filePath, Duration duration) async {
    final file = File('${filePath.parent.path}/progress.json');
    final fileName = filePath.uri.pathSegments.last;
    final json = jsonDecode(await file.readAsString());
    json[fileName] = {'duration': duration.inSeconds};
    await file.writeAsString(jsonEncode(json), flush: true);
  }
}
