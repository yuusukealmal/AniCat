import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';

import 'package:anicat/downloader/CookieHandle.dart';
import 'package:anicat/functions/behavior/PathHandle.dart';
import 'package:anicat/config/notifier/OverlayProvider.dart';

class Anime {
  String folder;
  String url;
  String realUrl = "https:";
  String? title;
  String? data;
  String xsend = "d=";
  Map<String, String> headers = getHeaderCookies();
  int _length = 0;

  Anime({required this.folder, required this.url});

  Future<void> _getData() async {
    Uri u = Uri.parse(Uri.decodeFull(url));
    http.Response response = await http.get(u, headers: getHeader());

    BeautifulSoup soup = BeautifulSoup(response.body);
    data = soup.find('video', class_: 'video-js')!.getAttrValue('data-apireq');
    title = soup.find('h2', class_: 'entry-title')!.text;

    Uri api = Uri.parse("https://v.anime1.me/api");

    xsend += data!;
    response = await http.post(api, headers: getHeader(), body: xsend);

    dynamic json = jsonDecode(response.body);
    int index = json['s'][0]['type'] == "application/x-mpegURL" ? 1 : 0;
    realUrl += json['s'][index]['src'];

    String set = response.headers['set-cookie']!;
    String? e = RegExp(r"e=(.*?);").firstMatch(set)!.group(1);
    String? p = RegExp(r"p=(.*?);").firstMatch(set)!.group(1);
    String? h = RegExp(r"HttpOnly,h=(.*?);").firstMatch(set)!.group(1);

    headers["cookie"] = "e=$e;p=$p;h=$h;";
  }

  Future<void> init() async {
    await _getData();
  }
}

class MP4 extends Anime with PathHandle {
  MP4({required super.folder, required super.url});

  int chunk = 10240;
  int retry = 3;
  int _downloaded = 0;
  final StreamController<double> progressController =
      StreamController<double>();

  Future<Directory> getPath() async {
    final root = await PathHandle.getDownloadPath();
    Directory f = Directory('${root.path}/$folder');
    if (!await f.exists()) {
      await f.create(recursive: true);
      await File('${f.path}/progress.json').create(recursive: true);
    }
    return f;
  }

  Future<void> download(BuildContext context) async {
    final overlayProvider =
        Provider.of<OverlayProvider>(context, listen: false);
    try {
      Uri url = Uri.parse(realUrl);
      http.Request request = http.Request('GET', url);
      request.headers.addAll(headers);

      Directory root = await getPath();
      final file = File('${root.path}/$title.mp4');

      if (file.existsSync()) {
        int fileLength = file.lengthSync();
        request.headers["Range"] = "bytes=$fileLength-";
        _downloaded = fileLength;
      }

      http.StreamedResponse response = await request.send();

      _length = _downloaded + (response.contentLength ?? 0);

      if (file.existsSync() && file.lengthSync() >= _length) {
        debugPrint("File Exists $title, Size $_length");
        progressController.add(1.0);
        await Future.delayed(const Duration(milliseconds: 100));
        progressController.close();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File Exists $title"),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }

      final sink = file.openWrite(mode: FileMode.append);
      overlayProvider.showOverlay(context, title: title, length: _length);
      await response.stream.listen((chunk) {
        _downloaded += chunk.length;
        sink.add(chunk);
        double progress = _downloaded / _length;
        progressController.add(progress);
        overlayProvider.updateOverlayIfNeeded(
            progress: progress, downloaded: _downloaded);
        if (_downloaded == _length) {
          debugPrint("Download Finished for $title with force");
          progressController.close();
          overlayProvider.removeOverlay();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Download Finished $title"),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }, onDone: () async {
        debugPrint("Download Finished for $title with onDone");
        await sink.close();
        progressController.close();
        overlayProvider.removeOverlay();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Download Finished $title"),
            duration: Duration(seconds: 1),
          ),
        );
      }, onError: (error) {
        debugPrint("Download Failed for $title, Cause by $error");
        progressController.close();
        sink.close();
        overlayProvider.removeOverlay();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Download Failed $title, Cause by $error"),
            duration: Duration(seconds: 1),
          ),
        );
        throw error;
      }, cancelOnError: true).asFuture();
    } catch (e) {
      debugPrint("Fail to Download $title, Cause by $e");
      overlayProvider.removeOverlay();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Download Failed $title, Cause by $e"),
          duration: Duration(seconds: 1),
        ),
      );
      if (retry > 0) {
        retry--;
        await download(context);
      } else {
        debugPrint("Download Failed for $title");
        progressController.close();
        overlayProvider.removeOverlay();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Download Failed $title"),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Stream<double> get progressStream => progressController.stream;
}
