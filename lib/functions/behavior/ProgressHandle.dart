import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:anicat/functions/utils.dart';

class Config {
  static Future<Map<String, dynamic>> _readProgress(File file) async {
    try {
      if (!await file.exists()) {
        await file.create(recursive: true);
        await file.writeAsString(jsonEncode({}));
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) return {};

      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      debugPrint("無法讀取 progress.json: $e");
      return {};
    }
  }

  static Future<Duration> getDuration(File filePath) async {
    try {
      final file = File('${filePath.parent.path}/progress.json');
      final hash = getHash(filePath);

      final json = await _readProgress(file);

      if (json.containsKey(hash)) {
        final seconds = json[hash];
        if (seconds is num) {
          return Duration(seconds: seconds.toInt());
        }
      }
      json[hash] = 0;
      await file.writeAsString(jsonEncode(json), flush: true);
      return Duration.zero;
    } catch (e) {
      debugPrint("讀取 duration 失敗：$e");
      return Duration.zero;
    }
  }

  static Future<String?> getLastView(File filePath) async {
    final file = File('${filePath.parent.path}/progress.json');
    final json = await _readProgress(file);

    final last = json['lastView'];
    return last == null ? null : last as String;
  }

  static Future writeDuration(File filePath, Duration duration) async {
    final file = File('${filePath.parent.path}/progress.json');
    final hash = getHash(filePath);
    final json = jsonDecode(await file.readAsString());
    json[hash] = duration.inSeconds;
    await file.writeAsString(jsonEncode(json), flush: true);
  }

  static Future writeLastView(File filePath) async {
    final file = File('${filePath.parent.path}/progress.json');
    final json = jsonDecode(await file.readAsString());
    json['lastView'] = getHash(filePath);
    await file.writeAsString(jsonEncode(json), flush: true);
  }
}
