import 'dart:io';
import 'package:flutter/material.dart';

Widget getFileLeading(
    String extension, int index, List<String> _fileCacheMap, String? duration) {
  switch (extension) {
    case '.mp4':
    case '.mkv':
    case '.webm':
      return _fileCacheMap.length > index && _fileCacheMap[index].isNotEmpty
          ? Stack(
              children: [
                Stack(
                  children: [
                    Image(image: FileImage(File(_fileCacheMap[index]))),
                    duration != null
                        ? Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 2.0,
                              ),
                              color: Colors.black54,
                              child: Text(
                                duration,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ],
            )
          : const Icon(Icons.video_file);
    case '.jpg':
    case '.png':
    case '.jpeg':
    case '.gif':
      return const Icon(Icons.image);
    case '.mp3':
    case '.wav':
    case '.aac':
    case '.ogg':
    case '.m4a':
    case '.flac':
      return const Icon(Icons.music_note);
    case '.mp4v':
    case '.mov':
    case '.wmv':
    case '.avi':
      return const Icon(Icons.video_file);
    default:
      return const Icon(Icons.insert_drive_file);
  }
}
