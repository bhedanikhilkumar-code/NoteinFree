import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService;
  bool _isAuthenticated = false;

  AuthProvider(this._storageService) {
    // If lock is not enabled, we are considered authenticated initially.
    _isAuthenticated = !_storageService.isLockEnabled;
  }

  bool get isLockEnabled => _storageService.isLockEnabled;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasPinSetup => _storageService.lockPin != null && _storageService.lockPin!.isNotEmpty;

  Future<void> enableLock(String pin) async {
    await _storageService.setLockPin(pin);
    await _storageService.setLockEnabled(true);
    notifyListeners();
  }

  Future<void> disableLock() async {
    await _storageService.setLockEnabled(false);
    await _storageService.setLockPin('');
    // Ensure we are authenticated if lock is disabled
    _isAuthenticated = true; 
    notifyListeners();
  }

  bool verifyPin(String enteredPin) {
    if (enteredPin == _storageService.lockPin) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void lockApp() {
    if (isLockEnabled) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }
}
