import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import '../theme/app_fonts.dart';

class StorageService {
  static const String _notesKey = 'notes_json';
  static const String _themeModeKey = 'theme_mode';
  static const String _sortOrderKey = 'sort_order';
  static const String _fontPresetKey = 'font_preset';
  static const String _fontScaleKey = 'font_scale';
  static const String _autoLockKey = 'auto_lock_enabled';
  static const String _lockEnabledKey = 'lock_enabled';
  static const String _legacyLockPinKey = 'lock_pin';
  static const String _lockPinHashKey = 'lock_pin_hash';
  static const String _lockPinSaltKey = 'lock_pin_salt';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final StorageService service = StorageService(prefs);
    await service._migrateLegacyPinIfNeeded();
    return service;
  }

  Future<void> _migrateLegacyPinIfNeeded() async {
    final String? legacyPin = _prefs.getString(_legacyLockPinKey);
    final String? pinHash = _prefs.getString(_lockPinHashKey);

    if ((pinHash == null || pinHash.isEmpty) &&
        legacyPin != null &&
        legacyPin.isNotEmpty) {
      await setLockPin(legacyPin);
    }

    if (_prefs.containsKey(_legacyLockPinKey)) {
      await _prefs.remove(_legacyLockPinKey);
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    final List<Map<String, dynamic>> jsonList = notes.map((note) => note.toJson()).toList();
    await _prefs.setString(_notesKey, jsonEncode(jsonList));
  }

  List<Note> loadNotes() {
    final String? jsonString = _prefs.getString(_notesKey);
    if (jsonString == null) {
      return <Note>[];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((dynamic item) => Note.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <Note>[];
    }
  }

  bool get isDarkMode => _prefs.getBool(_themeModeKey) ?? false;
  Future<void> setDarkMode(bool value) async => _prefs.setBool(_themeModeKey, value);

  int get sortOrder => _prefs.getInt(_sortOrderKey) ?? 0;
  Future<void> setSortOrder(int value) async => _prefs.setInt(_sortOrderKey, value);

  String get fontPreset => _prefs.getString(_fontPresetKey) ?? AppFonts.system;
  Future<void> setFontPreset(String value) async => _prefs.setString(_fontPresetKey, value);

  double get fontScale => _prefs.getDouble(_fontScaleKey) ?? 1.0;
  Future<void> setFontScale(double value) async => _prefs.setDouble(_fontScaleKey, value);

  bool get autoLockEnabled => _prefs.getBool(_autoLockKey) ?? true;
  Future<void> setAutoLockEnabled(bool value) async => _prefs.setBool(_autoLockKey, value);

  bool get isLockEnabled => _prefs.getBool(_lockEnabledKey) ?? false;
  Future<void> setLockEnabled(bool value) async => _prefs.setBool(_lockEnabledKey, value);

  Future<void> setLockPin(String value) async {
    if (value.isEmpty) {
      await _prefs.remove(_lockPinHashKey);
      await _prefs.remove(_lockPinSaltKey);
      await _prefs.remove(_legacyLockPinKey);
      return;
    }

    final String salt = _generateSalt();
    final String hash = _hashPin(value, salt);
    await _prefs.setString(_lockPinSaltKey, salt);
    await _prefs.setString(_lockPinHashKey, hash);
    await _prefs.remove(_legacyLockPinKey);
  }

  bool verifyPin(String enteredPin) {
    final String? salt = _prefs.getString(_lockPinSaltKey);
    final String? storedHash = _prefs.getString(_lockPinHashKey);

    if (salt == null || storedHash == null || storedHash.isEmpty) {
      return false;
    }

    return _hashPin(enteredPin, salt) == storedHash;
  }

  bool get hasPinSetup {
    final String? storedHash = _prefs.getString(_lockPinHashKey);
    return storedHash != null && storedHash.isNotEmpty;
  }

  String _generateSalt() {
    final Random random = Random.secure();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt::$pin')).toString();
  }
}
