import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storageService;

  SettingsProvider(this._storageService);

  bool get isDarkMode => _storageService.isDarkMode;
  
  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  int get sortOrder => _storageService.sortOrder;

  Future<void> toggleTheme(bool isDark) async {
    await _storageService.setDarkMode(isDark);
    notifyListeners();
  }

  Future<void> setSortOrder(int order) async {
    await _storageService.setSortOrder(order);
    notifyListeners();
  }
}
