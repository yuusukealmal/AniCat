import 'dart:convert';

class AnimeValue {
  AnimeValue.map(List<dynamic> map) {
    if (map.length < 6) {
      throw ArgumentError('List must contain at least 6 elements.');
    }
    id = map[0];
    name = map[1];
    status = map[2];
    year = map[3];
    season = map[4];
    translate = map[5];
  }

  static List<AnimeValue> fromJson(String text) {
    final json = jsonDecode(text) as List<dynamic>;

    return json.map((e) => AnimeValue.map(e)).toList();
  }

  late final int id;
  late final String name;
  late final String status;
  late final String year;
  late final String season;
  late final String translate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeValue && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
