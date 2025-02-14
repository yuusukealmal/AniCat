import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<List<dynamic>>> getAnimeList() async {
  String time = DateTime.now().millisecondsSinceEpoch.toString();
  Uri url = Uri.parse("https://d1zquzjgwo9yb.cloudfront.net/?_=$time");
  http.Response response = await http.get(url);
  List<List<dynamic>> animeList = List<List<dynamic>>.from(
    jsonDecode(response.body),
  );
  return animeList;
}
