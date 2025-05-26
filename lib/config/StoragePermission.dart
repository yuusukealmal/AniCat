import 'dart:io';
import 'package:flutter/material.dart';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:anicat/widget/StoragePermission/GetStorage.dart';
import 'package:anicat/widget/StoragePermission/AccessDenied.dart';

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

  static String getExternalStorageType(String path) {
    final isSDCard = RegExp(r'/storage/([0-9A-Fa-f]{4}-[0-9A-Fa-f]{4})');
    if (path.contains('/storage/emulated/')) {
      return 'Internal Storage';
    } else if (isSDCard.hasMatch(path)) {
      return 'SD Card (${isSDCard.firstMatch(path)![1]})';
    } else {
      return 'Unknown Storage $path';
    }
  }

  Future<String?> _chooseSavingFolder(BuildContext context) async {
    final result = await getExternalStorage(context);
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
      await askManageStoragePermission(context);
    } else if (access == "isPermanentlyDenied") {
      await openAppSettings();
    } else if (access == "Granted") {
      return await _chooseSavingFolder(context);
    }
    return null;
  }
}
