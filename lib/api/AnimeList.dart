import 'dart:convert';
import 'package:http/http.dart' as http;

class AnimeValue {
  final int id;
  final String name;
  final String status;
  final String year;
  final String season;
  final String translate;

  AnimeValue({
    required this.id,
    required this.name,
    required this.status,
    required this.year,
    required this.season,
    required this.translate,
  });

  factory AnimeValue.fromList(List<dynamic> data) {
    if (data.length < 6) {
      throw ArgumentError('List must contain at least 6 elements.');
    }
    return AnimeValue(
      id: data[0],
      name: data[1].toString(),
      status: data[2],
      year: data[3],
      season: data[4],
      translate: data[5],
    );
  }
}

Future<List<AnimeValue>> getAnimeList() async {
  String time = DateTime.now().millisecondsSinceEpoch.toString();
  Uri url = Uri.parse("https://d1zquzjgwo9yb.cloudfront.net/?_=$time");

  http.Response response = await http.get(url);

  List<List<dynamic>> rawList = List<List<dynamic>>.from(
    jsonDecode(response.body),
  );

  return rawList.map((anime) => AnimeValue.fromList(anime)).toList();
}
