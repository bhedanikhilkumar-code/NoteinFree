import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService;
  bool _isAuthenticated = false;

  AuthProvider(this._storageService) {
    _isAuthenticated = !_storageService.isLockEnabled;
  }

  bool get isLockEnabled => _storageService.isLockEnabled;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasPinSetup => _storageService.hasPinSetup;

  Future<void> enableLock(String pin) async {
    await _storageService.setLockPin(pin);
    await _storageService.setLockEnabled(true);
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> disableLock() async {
    await _storageService.setLockEnabled(false);
    await _storageService.setLockPin('');
    _isAuthenticated = true;
    notifyListeners();
  }

  bool verifyPin(String enteredPin) {
    final bool isValid = _storageService.verifyPin(enteredPin);
    if (isValid) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return isValid;
  }

  void lockApp() {
    if (isLockEnabled && _storageService.autoLockEnabled) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }
}
