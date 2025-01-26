import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Config {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    File config = File("$path/config.json");
    return config;
  }

  static Future<String> _readConfig() async {
    try {
      final file = await _localFile;
      return file.readAsString();
    } catch (e) {
      return '{}';
    }
  }

  static Future<File> _writeConfig(String desc, dynamic value,
      [bool isList = false]) async {
    dynamic json = jsonDecode(await _readConfig());
    if (isList) {
      json[desc].append(value);
    } else {
      json[desc] = value;
    }
    final file = await _localFile;
    return file.writeAsString(jsonEncode(json));
  }

  static Future<void> deleteConfig() async {
    final file = await _localFile;
    await file.delete();
  }
}
