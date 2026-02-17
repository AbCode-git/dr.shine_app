import 'package:flutter/material.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/repositories/auth_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider(this._authRepository) {
    _authRepository.authStateChanges.listen(_onAuthStateChanged);
    _checkMockSession();
  }

  Future<void> _checkMockSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('mock_user');
      if (userData != null) {
        _currentUser = UserModel.fromMap(jsonDecode(userData));
      }
    } catch (e) {
      LoggerService.error('Error loading mock session', e);
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _persistMockSession(UserModel? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user != null) {
        await prefs.setString('mock_user', jsonEncode(user.toMap()));
      } else {
        await prefs.remove('mock_user');
      }
    } catch (e) {
      LoggerService.error('Failed to persist session', e);
    }
  }

  Future<void> _onAuthStateChanged(String? uid) async {
    if (uid == null) {
      if (_currentUser != null && _currentUser!.id.startsWith('mock_')) {
        // Keep mock session if it exists
      } else {
        _currentUser = null;
      }
    } else {
      _isLoading = true;
      notifyListeners();
      try {
        _currentUser = await _authRepository.getUserData(uid);
      } catch (e) {
        LoggerService.error('Failed to sync user data', e);
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Simplified login: Phone and PIN entry directly triggers signIn.
  /// (Skipping SMS OTP as per requirements)
  Future<void> loginWithPhoneAndPin(String phoneNumber, String pin) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.signInWithPhoneAndPin(phoneNumber, pin);
      // Data sync handled by _onAuthStateChanged
    } catch (e) {
      LoggerService.error('Login failed', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.signOut();
      _currentUser = null;
      await _persistMockSession(null);
      notifyListeners();
    } catch (e) {
      LoggerService.error('Logout failed', e);
    }
  }

  Future<void> setPin(String pin) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.savePin(_currentUser!.id, pin);
      _currentUser = _currentUser!.copyWith(pin: pin);
      await _persistMockSession(_currentUser);
    } catch (e) {
      LoggerService.error('PIN setup failed', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verification for secondary actions (e.g. admin actions)
  Future<bool> verifyActionWithPin(String pin) async {
    if (_currentUser == null) return false;
    return _currentUser!.pin == pin;
  }
}
