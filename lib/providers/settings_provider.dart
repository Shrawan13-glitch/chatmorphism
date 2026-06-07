import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _apiBaseUrl = '';
  bool _useMarkdown = true;

  ThemeMode get themeMode => _themeMode;
  String get apiBaseUrl => _apiBaseUrl;
  bool get useMarkdown => _useMarkdown;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setApiBaseUrl(String url) {
    _apiBaseUrl = url;
    notifyListeners();
  }

  void setUseMarkdown(bool value) {
    _useMarkdown = value;
    notifyListeners();
  }
}
