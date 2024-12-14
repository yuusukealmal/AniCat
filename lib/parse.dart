import 'package:anicat/routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';

Future<List<String>> parse(String url) async {
  List<String> list = [];
  url =
      "https://anime1.me/category/2023%E5%B9%B4%E6%98%A5%E5%AD%A3/mix-%E7%AC%AC%E4%BA%8C%E5%AD%A3";
  RegExp esp = RegExp(r'anime1.me/[0-9]');
  RegExp season = RegExp(r'anime1.me/category/(.*?)');
  if (esp.hasMatch(url)) {
    list.add(url);
  } else if (season.hasMatch(url)) {
    await getEpisode(url).then((value) => list.addAll(value));
  }
  return list;
}

Future<List<String>> getEpisode(String url) async {
  List<String> urls = [];

  debugPrint('URL = $url');
  var u = Uri.parse(Uri.decodeFull(url));
  Map<String, String> headers = getHeader();
  var response = await http.get(u, headers: headers);

  BeautifulSoup soup = BeautifulSoup(response.body);

  var h2 = soup.findAll('h2', class_: 'entry-title');

  for (var element in h2) {
    var url = element
        .find('a', attrs: {'rel': "bookmark"})!.text; //getAttrValue('href')!;
    urls.add(url);
  }

  if (soup.find('div', class_: 'nav-previous') != null) {
    var eleDiv = soup.find('div', class_: 'nav-previous');
    var nextUrl = eleDiv!.find('a')!.getAttrValue('href')!;
    urls.addAll(await getEpisode(nextUrl));
  }

  var title = soup.find('h1', class_: 'page-title')!.text;
  urls.add(title);
  return urls;
}
