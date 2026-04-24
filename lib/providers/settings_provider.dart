import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_fonts.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storageService;

  SettingsProvider(this._storageService);

  static const int sortNewestFirst = 0;
  static const int sortOldestFirst = 1;
  static const int sortAlphabetical = 2;

  bool get isDarkMode => _storageService.isDarkMode;
  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  int get sortOrder => _storageService.sortOrder;
  String get fontPresetId => _storageService.fontPreset;
  FontOption get fontOption => AppFonts.byId(fontPresetId);
  double get fontScale => _storageService.fontScale;
  bool get autoLockEnabled => _storageService.autoLockEnabled;

  Future<void> toggleTheme(bool isDark) async {
    await _storageService.setDarkMode(isDark);
    notifyListeners();
  }

  Future<void> setSortOrder(int order) async {
    await _storageService.setSortOrder(order);
    notifyListeners();
  }

  Future<void> setFontPreset(String fontPresetId) async {
    await _storageService.setFontPreset(fontPresetId);
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    await _storageService.setFontScale(scale.clamp(0.9, 1.3));
    notifyListeners();
  }

  Future<void> setAutoLockEnabled(bool enabled) async {
    await _storageService.setAutoLockEnabled(enabled);
    notifyListeners();
  }

  String sortLabel(int order) {
    switch (order) {
      case sortOldestFirst:
        return 'Oldest first';
      case sortAlphabetical:
        return 'Title A–Z';
      case sortNewestFirst:
      default:
        return 'Recently edited';
    }
  }
}
