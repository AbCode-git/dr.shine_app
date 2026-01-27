import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dr_shine_app/core/services/auth_service.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/bootstrap.dart';
import 'package:dr_shine_app/core/utils/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _verificationId;
  String? _phoneNumber; // Store phone for mock role assignment

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _authService.user.listen(_onAuthStateChanged);
    _checkMockSession();
  }

  Future<void> _checkMockSession() async {
    if (!isFirebaseInitialized) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userData = prefs.getString('mock_user');
        if (userData != null) {
          try {
            _currentUser = UserModel.fromMap(jsonDecode(userData));
            notifyListeners();
          } catch (e) {
            debugPrint('Error loading mock session: $e');
          }
        }
      } catch (e) {
        debugPrint('Session persistence not ready: $e');
        // This usually happens when a new plugin is added but the app needs a full restart.
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _persistMockSession(UserModel? user) async {
    if (!isFirebaseInitialized) {
      final prefs = await SharedPreferences.getInstance();
      if (user != null) {
        await prefs.setString('mock_user', jsonEncode(user.toMap()));
      } else {
        await prefs.remove('mock_user');
      }
    }
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      _isLoading = true;
      notifyListeners();
      _currentUser = await _authService.getUserData(firebaseUser.uid);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> verifyPhone(String phoneNumber) async {
    _phoneNumber = phoneNumber; // Store for mock mode
    _isLoading = true;
    notifyListeners();
    
    await _authService.verifyPhone(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        _isLoading = false;
        notifyListeners();
      },
      onVerificationFailed: (e) {
        _isLoading = false;
        notifyListeners();
        // Handle error in UI
      },
    );
  }

  Future<void> verifyOtp(String smsCode) async {
    if (_verificationId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (_verificationId == 'mock_verification_id') {
        await Future.delayed(const Duration(seconds: 1));
        
        // WHITELISTING LOGIC (MOCK)
        if (_phoneNumber != null && _phoneNumber!.endsWith('00')) {
          _currentUser = MockData.superAdminUser; // Whitelisted Super Admin
        } else if (_phoneNumber != null && _phoneNumber!.endsWith('44')) {
          _currentUser = MockData.adminUser; // Whitelisted Staff/Admin
        } else if (_phoneNumber != null && _phoneNumber!.endsWith('55')) {
          _currentUser = MockData.customerUser; // Whitelisted Returning Customer
        } else {
          // Non-whitelisted numbers start as new users (No PIN initially)
          _currentUser = MockData.newCustomerUser;
        }
        
        _isLoading = false;
        await _persistMockSession(_currentUser);
        notifyListeners();
        return;
      }
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await _authService.signInWithCredential(credential);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    if (!isFirebaseInitialized) {
      _currentUser = null;
      await _persistMockSession(null);
      notifyListeners();
    }
  }

  Future<void> setPin(String pin) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.savePin(_currentUser!.id, pin);
      // Update local user
      _currentUser = UserModel(
        id: _currentUser!.id,
        phoneNumber: _currentUser!.phoneNumber,
        displayName: _currentUser!.displayName,
        role: _currentUser!.role,
        pin: pin,
        loyaltyPoints: _currentUser!.loyaltyPoints,
        createdAt: _currentUser!.createdAt,
      );
      await _persistMockSession(_currentUser);
    } catch (e) {
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
      // Mock bypass for demo numbers
      if (phoneNumber.endsWith('00') || phoneNumber.endsWith('44') || phoneNumber.endsWith('55')) {
        await Future.delayed(const Duration(seconds: 1));
        UserModel? user;
        if (phoneNumber.endsWith('00')) {
          user = MockData.superAdminUser;
        } else if (phoneNumber.endsWith('44')) {
          user = MockData.adminUser;
        } else {
          user = MockData.customerUser;
        }

        if (pin == '1111') {
          _currentUser = user;
          await _persistMockSession(_currentUser);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      if (!isFirebaseInitialized) {
        return false;
      }
      
      // Real firebase logic would involve fetching user by phone first
      // For now, in demo mode, we only support the mock numbers above.
      return false; 
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
