import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:anicat/routes.dart';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';

class Anime {
  String folder;
  String url;
  String realUrl = "https:";
  String? title;
  String? data;
  String xsend = "d=";
  String? cookies;

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

    cookies = "e=$e;p=$p;h=$h;";
  }

  Future<void> init() async {
    await _getData();
  }
}

class MP4 extends Anime {
  MP4({required super.folder, required super.url});

  int chunk = 1024;

  void download() async {
  }
}
