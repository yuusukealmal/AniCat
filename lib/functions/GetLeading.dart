import 'dart:io';
import 'package:flutter/material.dart';

Widget getFileLeading(String filename, int index, List<String> _fileCacheMap) {
  String extension = filename.split('.').last;
  switch (extension) {
    case 'mp4':
    case 'mkv':
    case 'webm':
      return _fileCacheMap.length > index && _fileCacheMap[index].isNotEmpty
          ? Image(image: FileImage(File(_fileCacheMap[index])))
          : const Icon(Icons.video_file);
    case 'jpg':
    case 'png':
    case 'jpeg':
    case 'gif':
      return const Icon(Icons.image);
    case 'mp3':
    case 'wav':
    case 'aac':
    case 'ogg':
    case 'm4a':
    case 'flac':
      return const Icon(Icons.music_note);
    case 'mp4v':
    case 'mov':
    case 'wmv':
    case 'avi':
      return const Icon(Icons.video_file);
    default:
      return const Icon(Icons.insert_drive_file);
  }
}
