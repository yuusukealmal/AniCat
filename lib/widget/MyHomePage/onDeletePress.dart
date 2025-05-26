import 'dart:io';
import 'package:flutter/material.dart';

Future<void> onFolderDeletePress(
    BuildContext context, String folderPath, List<FileSystemEntity> files) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Material(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "刪除資料夾",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "確定要 ${folderPath.split('/').last} 嗎?",
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "取消",
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        for (FileSystemEntity file in files) {
                          (file as File).deleteSync();
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "刪除",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
