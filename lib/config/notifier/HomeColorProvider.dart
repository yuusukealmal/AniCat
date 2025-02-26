import 'package:flutter/material.dart';
import 'package:anicat/config/SharedPreferences.dart';

class ColorProvider with ChangeNotifier {
  Color? _color;
  Color? get color => _color ?? Color.fromARGB(255, 183, 58, 156);

  ColorProvider() {
    init();
  }

  Future<void> init() async {
    final colorValue = SharedPreferencesHelper.getInt("Home.Color");
    if (colorValue != null) {
      _color = Color(colorValue);
    } else {
      const defaultColor = Color.fromARGB(255, 183, 58, 156);
      await SharedPreferencesHelper.setInt('Home.Color', defaultColor.value);
      _color = defaultColor;
    }
    notifyListeners();
  }

  Future<void> setColor(Color color) async {
    await SharedPreferencesHelper.setInt("Home.Color", color.value);
    _color = color;
    notifyListeners();
  }
}
