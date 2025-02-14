import 'dart:io';
import 'package:flutter/material.dart';
import 'package:anicat/functions/Calc.dart';

dynamic onFolderPropertiesPress(
    BuildContext context, String folderName, List files) async {
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
                  folderName,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  "影片數量: ${files.length}\n總大小: ${convertMB(files.fold(0, (total, file) => total + (file as File).lengthSync()))}\n創建日期: ${(files.first as File).lastModifiedSync().toLocal()}",
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "關閉",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
