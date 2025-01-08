import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:anicat/CookieHandle.dart';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:path_provider/path_provider.dart';

class Anime {
  String folder;
  String url;
  String realUrl = "https:";
  String? title;
  String? data;
  String xsend = "d=";
  Map<String, String> headers = getHeaderCookies();
  int length = 0;

  Anime({required this.folder, required this.url});

  Future<void> _getData() async {
    var u = Uri.parse(Uri.decodeFull(url));
    var response = await http.get(u, headers: getHeader());

    BeautifulSoup soup = BeautifulSoup(response.body);
    data = soup.find('video', class_: 'video-js')!.getAttrValue('data-apireq');
    title = soup.find('h2', class_: 'entry-title')!.text;

    var api = Uri.parse("https://v.anime1.me/api");

    xsend += data!;
    response = await http.post(api, headers: getHeader(), body: xsend);

    var json = jsonDecode(response.body);
    realUrl += json['s'][0]['src'];

    var set = response.headers['set-cookie']!;
    var e = RegExp(r"e=(.*?);").firstMatch(set)!.group(1);
    var p = RegExp(r"p=(.*?);").firstMatch(set)!.group(1);
    var h = RegExp(r"HttpOnly,h=(.*?);").firstMatch(set)!.group(1);

    headers["cookie"] = "e=$e;p=$p;h=$h;";
  }

  Future<void> init() async {
    await _getData();
  }
}

class MP4 extends Anime {
  MP4({required super.folder, required super.url});

  int chunk = 10240;
  int retry = 3;
  int _downloaded = 0;
  final StreamController<double> progressController =
      StreamController<double>();

  Future<Directory> getPath() async {
    final root = await getExternalStorageDirectory();
    var f = Directory('${root!.path}/$folder');
    if (!await f.exists()) {
      await f.create(recursive: true);
    }
    return f;
  }

  Future<void> download() async {
    try {
      var url = Uri.parse(realUrl);
      var request = http.Request('GET', url);
      request.headers.addAll(headers);

      var root = await getPath();
      final file = File('${root.path}/$title.mp4');
      http.StreamedResponse response = await request.send();

      length = response.contentLength!;
      _downloaded = 0;
      if (file.existsSync()) {
        if (file.lengthSync() == length) {
          debugPrint("File Exists $title, Size $length");
          progressController.add(1.0);
          await Future.delayed(const Duration(milliseconds: 100));
          progressController.close();
          return;
        } else {
          await file.delete();
        }
      }

      final sink = file.openWrite();
      await response.stream.listen((chunk) {
        _downloaded += chunk.length;
        sink.add(chunk);
        double progress = _downloaded / length;
        progressController.add(progress);
        if (_downloaded == length) {
          debugPrint("Download Finished for $title with force");
          progressController.close();
        }
      }, onDone: () async {
        debugPrint("Download Finished for $title with onDone");
        await sink.close();
        progressController.close();
      }, onError: (error) {
        debugPrint("Download Failed for $title, Cause by $error");
        progressController.close();
        sink.close();
        throw error;
      }, cancelOnError: true).asFuture();
    } catch (e) {
      debugPrint("Fail to Download $title, Cause by $e");
      if (retry > 0) {
        retry--;
        download();
      } else {
        debugPrint("Download Failed for $title");
        progressController.close();
      }
    }
  }

  int get current => _downloaded;
  int get size => length;
  Stream<double> get progressStream => progressController.stream;
}
