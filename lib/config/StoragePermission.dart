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
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Access Denied",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please enable storage access in settings.",
                    style: const TextStyle(color: Colors.white),
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
                          style: TextStyle(color: Colors.white),
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
