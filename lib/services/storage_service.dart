import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class StorageService {
  static const String _notesKey = 'notes_json';
  static const String _themeModeKey = 'theme_mode';
  static const String _sortOrderKey = 'sort_order';
  static const String _lockEnabledKey = 'lock_enabled';
  static const String _lockPinKey = 'lock_pin';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Notes ---
  Future<void> saveNotes(List<Note> notes) async {
    final List<Map<String, dynamic>> jsonList = notes.map((n) => n.toJson()).toList();
    await _prefs.setString(_notesKey, jsonEncode(jsonList));
  }

  List<Note> loadNotes() {
    final String? jsonString = _prefs.getString(_notesKey);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading notes: $e');
      return [];
    }
  }

  // --- Settings ---
  bool get isDarkMode => _prefs.getBool(_themeModeKey) ?? false;
  Future<void> setDarkMode(bool value) async => await _prefs.setBool(_themeModeKey, value);

  int get sortOrder => _prefs.getInt(_sortOrderKey) ?? 0;
  Future<void> setSortOrder(int value) async => await _prefs.setInt(_sortOrderKey, value);

  // --- Auth/Lock ---
  bool get isLockEnabled => _prefs.getBool(_lockEnabledKey) ?? false;
  Future<void> setLockEnabled(bool value) async => await _prefs.setBool(_lockEnabledKey, value);

  String? get lockPin => _prefs.getString(_lockPinKey);
  Future<void> setLockPin(String value) async => await _prefs.setString(_lockPinKey, value);
}
