import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/repositories/auth_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';
import 'package:dr_shine_app/core/utils/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _verificationId;
  String? _phoneNumber;

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

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      if (_currentUser != null && _currentUser!.id.startsWith('mock_')) {
        // Keep mock session if it exists
      } else {
        _currentUser = null;
      }
    } else {
      _isLoading = true;
      notifyListeners();
      try {
        _currentUser = await _authRepository.getUserData(firebaseUser.uid);
      } catch (e) {
        LoggerService.error('Failed to sync user data', e);
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> verifyPhone(String phoneNumber) async {
    _phoneNumber = phoneNumber;
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.verifyPhone(
        phoneNumber: phoneNumber,
        onCodeSent: (id) {
          _verificationId = id;
          _isLoading = false;
          notifyListeners();
        },
        onVerificationFailed: (e) {
          _isLoading = false;
          notifyListeners();
          LoggerService.error('Verification failed', e);
        },
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      LoggerService.error('verifyPhone error', e);
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    if (_verificationId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (_verificationId == 'mock_verification_id') {
        await Future.delayed(const Duration(seconds: 1));

        // Whitelisting logic
        if (_phoneNumber != null && _phoneNumber!.endsWith('00')) {
          _currentUser = MockData.superAdminUser;
        } else if (_phoneNumber != null && _phoneNumber!.endsWith('44')) {
          _currentUser = MockData.adminUser;
        } else {
          // Default to a guest/new admin if needed, but not customer
          _currentUser = null;
        }

        await _persistMockSession(_currentUser);
        return;
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await _authRepository.signInWithCredential(credential);
    } catch (e) {
      LoggerService.error('OTP verify error', e);
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

  Future<bool> verifyWithPin(String phoneNumber, String pin) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mock bypass
      if (phoneNumber.endsWith('00') || phoneNumber.endsWith('44')) {
        await Future.delayed(const Duration(seconds: 1));
        UserModel? user;
        if (phoneNumber.endsWith('00')) {
          user = MockData.superAdminUser;
        } else {
          user = MockData.adminUser;
        }

        if (pin == '1111') {
          _currentUser = user;
          await _persistMockSession(_currentUser);
          return true;
        }
      }
      return false;
    } catch (e) {
      LoggerService.error('PIN verify error', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
