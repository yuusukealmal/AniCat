import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper with ChangeNotifier {
  static final SharedPreferencesHelper _instance =
      SharedPreferencesHelper._internal();
  factory SharedPreferencesHelper() => _instance;
  SharedPreferencesHelper._internal();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setString(String key, String value) async {
    return _prefs?.setString(key, value) ?? Future.value(false);
  }

  static Future<bool> setInt(String key, int value) async {
    return _prefs?.setInt(key, value) ?? Future.value(false);
  }

  static Future<bool> setDouble(String key, double value) async {
    return _prefs?.setDouble(key, value) ?? Future.value(false);
  }

  static Future<bool> setBool(String key, bool value) async {
    return _prefs?.setBool(key, value) ?? Future.value(false);
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    return _prefs?.setStringList(key, value) ?? Future.value(false);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  static double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  static Future<bool> remove(String key) async {
    return _prefs?.remove(key) ?? Future.value(false);
  }

  static Future<bool> delete() async {
    return _prefs?.clear() ?? Future.value(false);
  }

  static Future<void> reset() async {
    _prefs?.clear();
    _prefs?.setInt("Home.Color", Color.fromARGB(255, 183, 58, 156).value);
  }
}
