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
    _initSession();
  }

  Future<void> _initSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('mock_user');
      if (userData != null) {
        _currentUser = UserModel.fromMap(jsonDecode(userData));
        print(
            'AuthProvider: Restored mock context for ${_currentUser?.displayName}');
      }

      // DO NOT signOut() Supabase here. We want to preserve the session if it exists.
      // The _onAuthStateChanged listener will handle syncing the profile once Supabase initializes.
      print('AuthProvider: Checking for existing Supabase session...');
    } catch (e) {
      LoggerService.error('Error during session init', e);
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
    print('AuthProvider: Auth state changed. UID=$uid');
    if (uid == null) {
      // If Supabase has no user, but we have a mock user, we decide whether to keep it.
      // Usually, we want to sync with Supabase, so we clear the guest/mock state if no session exists.
      if (_currentUser != null && !_currentUser!.id.startsWith('mock_')) {
        print('AuthProvider: No session found. Clearing user state.');
        _currentUser = null;
        await _persistMockSession(null);
      }
    } else {
      _isLoading = true;
      notifyListeners();
      try {
        _currentUser = await _authRepository.getUserData(uid);
        if (_currentUser != null) {
          print(
              'AuthProvider: Profile loaded: ${_currentUser!.displayName} (${_currentUser!.role})');
          await _persistMockSession(_currentUser);
        } else {
          print(
              'AuthProvider: WARNING - No profile found for UID $uid. Signing out.');
          // If we have a session but no profile, the user might be deleted from our DB.
          // Sign out to prevent weird 401/500 errors.
          await logout();
        }
      } catch (e) {
        LoggerService.error('Failed to sync user data', e);
        print('AuthProvider: ERROR fetching profile for UID $uid: $e');
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
    print(
        'AuthProvider: loginWithPhoneAndPin called. Phone=$phoneNumber PIN=$pin');

    try {
      await _authRepository.signInWithPhoneAndPin(phoneNumber, pin);
      print(
          'AuthProvider: signInWithPhoneAndPin succeeded. Waiting for auth state change...');
      // Data sync handled by _onAuthStateChanged
    } catch (e) {
      print('AuthProvider: Login FAILED: $e');
      LoggerService.error('Login failed', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user with phone, PIN, name, role, and optional branch.
  Future<void> register(
      String phoneNumber, String pin, String displayName, String role,
      {String? tenantId}) async {
    _isLoading = true;
    notifyListeners();
    print(
        'AuthProvider: register called. Phone=$phoneNumber Name=$displayName Role=$role Tenant=$tenantId');

    try {
      await _authRepository.signUp(phoneNumber, pin, displayName, role,
          tenantId: tenantId);
      print('AuthProvider: signUp succeeded. User is now logged in.');
      // Supabase signUp auto-logs in, so _onAuthStateChanged will fire
    } catch (e) {
      print('AuthProvider: Register FAILED: $e');
      LoggerService.error('Registration failed', e);
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
