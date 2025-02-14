import 'package:flutter/material.dart';
import 'package:anicat/config/SharedPreferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode? _themeMode;
  ThemeMode get themeMode => _themeMode ?? ThemeMode.light;

  ThemeProvider() {
    init();
  }

  Future<void> init() async {
    String? theme = SharedPreferencesHelper.getString('theme');
    if (theme != null) {
      _themeMode = theme == 'light' ? ThemeMode.light : ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
      await SharedPreferencesHelper.setString('theme', 'light');
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await SharedPreferencesHelper.setString(
        'theme', _themeMode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }
}
