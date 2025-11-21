import 'package:anicat/src/rust/api/utils/anime_fetch.dart';

// Future<(String, List<String>)> parser(String url) async {
//   List<String> list = [];
//   RegExp esp = RegExp(r'anime1.me\/[0-9]');
//   RegExp season = RegExp(r'anime1.me\/category\/(.*?)');
//   RegExp cat = RegExp(r'anime1\.me\/\?cat=\d+');

//   if (esp.hasMatch(url)) {
//     String title = await getAnimeTitle(url: url);
//     list.add(url);
//     return (title, list);
//   } else if (season.hasMatch(url) || cat.hasMatch(url)) {
//     await getAnimeEpisode(url: url).then((value) => list.addAll(value.$2));
//     String title = await getAnimeTitle(url: list[0]);
//     return (title, list);
//   } else {
//     return ("", list);
//   }
// }
