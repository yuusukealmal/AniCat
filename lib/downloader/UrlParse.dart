import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';

import 'package:anicat/downloader/CookieHandle.dart';

Future<List<String>> parse(String url) async {
  List<String> list = [];
  RegExp esp = RegExp(r'anime1.me\/[0-9]');
  RegExp season = RegExp(r'anime1.me\/category\/(.*?)');
  RegExp cat = RegExp(r'anime1\.me\/\?cat=\d+');
  if (esp.hasMatch(url)) {
    list.add(url);
    list.add(await getTitle(url));
  } else if (season.hasMatch(url) || cat.hasMatch(url)) {
    await getEpisode(url).then((value) => list.addAll(value));
  }
  return list;
}

Future<List<String>> getEpisode(String url) async {
  List<String> urls = [];

  Uri u = Uri.parse(Uri.decodeFull(url));
  Map<String, String> headers = getHeader();
  http.Response response = await http.get(u, headers: headers);

  BeautifulSoup soup = BeautifulSoup(response.body);

  List<Bs4Element> h2 = soup.findAll('h2', class_: 'entry-title');

  for (Bs4Element element in h2) {
    String url =
        element.find('a', attrs: {'rel': "bookmark"})!.getAttrValue('href')!;
    urls.add(url);
  }

  if (soup.find('div', class_: 'nav-previous') != null) {
    Bs4Element? eleDiv = soup.find('div', class_: 'nav-previous');
    String nextUrl = eleDiv!.find('a')!.getAttrValue('href')!;
    urls.addAll(await getEpisode(nextUrl));
  } else {
    String title = soup.find('h1', class_: 'page-title')!.text;
    urls.add(title);
  }
  return urls;
}

Future<String> getTitle(String url) async {
  Uri u = Uri.parse(Uri.decodeFull(url));
  Map<String, String> headers = getHeader();
  http.Response response = await http.get(u, headers: headers);
  BeautifulSoup soup = BeautifulSoup(response.body);
  String title =
      soup.find('span', class_: "cat-links")!.text.split("分類: ").last;
  return title;
}
