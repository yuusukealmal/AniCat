import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

String convertMB(int length) {
  double mb = length / 1024 / 1024;
  double fix = double.parse(mb.toStringAsFixed(2));
  return '$fix MB';
}

String getFileSize(int length) {
  if (length <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  int i = (log(length) / log(1024)).floor();
  return "${(length / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}";
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  final hours = duration.inHours;

  if (hours > 0) {
    return "$hours:$minutes:$seconds";
  } else {
    return "$minutes:$seconds";
  }
}

Future<Duration> getVideoDuration(File file) async {
  try {
    final metadata = await MetadataRetriever.fromFile(file);
    if (metadata.trackDuration != null) {
      return Duration(milliseconds: metadata.trackDuration!);
    }
  } catch (e) {
    debugPrint('無法讀取影片時間: $e');
  }
  return Duration.zero;
}

String getHash(File file, [Directory? folder]) {
  String toHash = folder == null
      ? file.uri.pathSegments.last.replaceAll(".mp4", "")
      : folder.uri.pathSegments.last;
  String hash = sha256.convert(utf8.encode(toHash)).toString().substring(0, 16);

  return hash;
}
