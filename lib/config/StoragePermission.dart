import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

mixin StoragePermission {
  Future<String> _checkManageStoragePermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.status;
    if (status.isRestricted) {
      return "isRestricted";
    }

    if (status.isDenied) {
      return "isDenied";
    }
    if (status.isPermanentlyDenied) {
      return "isPermanentlyDenied";
    }
    return "Granted";
  }

  Future<void> _askManageStoragePermission(BuildContext context) async {
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
                    "Access Denied",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please enable storage access in settings.",
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await Permission.manageExternalStorage.request();
                        },
                        child: const Text(
                          "Open Settings",
                        ),
                      ),
                      const SizedBox(width: 8),
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

  String _getExternalStorageType(String path) {
    final isSDCard = RegExp(r'/storage/([0-9A-Fa-f]{4}-[0-9A-Fa-f]{4})');
    if (path.contains('/storage/emulated/')) {
      return 'Internal Storage';
    } else if (isSDCard.hasMatch(path)) {
      return 'SD Card (${isSDCard.firstMatch(path)![1]})';
    } else {
      return 'Unknown Storage $path';
    }
  }

  Future<String?> _getExternalStorage(BuildContext context) async {
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
                                  _getExternalStorageType(
                                      directories[index].path),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.of(context).pop(
                                      _getExternalStorageType(
                                          directories[index].path));
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

  Future<String?> _chooseSavingFolder(BuildContext context) async {
    final result = await _getExternalStorage(context);
    String? target;

    if (result == "Internal Storage") {
      target = "/storage/emulated/0";
    } else if (result!.startsWith("SD Card")) {
      String id = result.split(" ")[2].replaceAll(RegExp(r'\(|\)'), "");
      target = "/storage/$id";
    } else {
      target = result.split(" ")[2];
    }

    return await FilesystemPicker.open(
      title: 'Save to folder',
      context: context,
      rootDirectory: Directory(target),
      fsType: FilesystemType.folder,
      pickText: 'Save file to this folder',
    );
  }

  Future<String?> checkPermission(BuildContext context) async {
    String access = await _checkManageStoragePermission();
    if (access == "isRestricted" || access == "isDenied") {
      await _askManageStoragePermission(context);
    } else if (access == "isPermanentlyDenied") {
      await openAppSettings();
    } else if (access == "Granted") {
      return await _chooseSavingFolder(context);
    }
    return null;
  }
}
