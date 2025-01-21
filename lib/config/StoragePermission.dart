import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

mixin StoragePermission {
  Future<String> _checkManageStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;
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
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Access Denied"),
        content: const Text("Please enable storage access in settings."),
        actions: [
          TextButton(
              child: const Text("Open Settings"),
              onPressed: () async {
                await Permission.manageExternalStorage.request();
              }),
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  Future<String?> _chooseSavingFolder(BuildContext context) async {
    return await FilesystemPicker.open(
      title: 'Save to folder',
      context: context,
      rootDirectory: Directory('/storage/emulated/0/'),
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
