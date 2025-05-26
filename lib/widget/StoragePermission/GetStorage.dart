import 'package:anicat/config/StoragePermission.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

Future<String?> getExternalStorage(BuildContext context) async {
  final directories = await getExternalStorageDirectories();

  if (directories == null || directories.isEmpty) {
    return null;
  }

  return await showDialog<String>(
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
                const Text(
                  "Select Folder",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                directories.isNotEmpty
                    ? Flexible(
                        child: ListView.builder(
                          itemCount: directories.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(
                                Icons.folder,
                              ),
                              title: Text(
                                StoragePermission.getExternalStorageType(
                                  directories[index].path,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                Navigator.of(context).pop(
                                  StoragePermission.getExternalStorageType(
                                    directories[index].path,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Text(
                          "No directories found",
                        ),
                      ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "Cancel",
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
