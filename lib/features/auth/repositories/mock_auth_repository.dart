import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/repositories/auth_repository.dart';
import 'package:dr_shine_app/core/utils/mock_data.dart';

class MockAuthRepository implements IAuthRepository {
  final _authStateController = StreamController<User?>.broadcast();
  UserModel? _mockUser;

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(Exception e) onVerificationFailed,
  }) async {
    // Mock bypass for demo numbers
    if (phoneNumber.endsWith('00') ||
        phoneNumber.endsWith('44') ||
        phoneNumber.endsWith('55')) {
      await Future.delayed(const Duration(seconds: 1));
      onCodeSent('mock_verification_id');
    } else {
      onVerificationFailed(
          Exception('Mock verification only supports known demo numbers.'));
    }
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    // Return empty mock credential
    return _FakeUserCredential();
  }

  @override
  Future<void> signOut() async {
    _mockUser = null;
    _authStateController.add(null);
  }

  @override
  Future<UserModel?> getUserData(String uid) async {
    // In mock mode, we usually return a hardcoded user based on whitelisting in Provider
    // or we can simulate firestore fetch here.
    if (uid == 'mock_admin_uid') return MockData.adminUser;
    if (uid == 'mock_customer_uid') return MockData.customerUser;
    return _mockUser;
  }

  @override
  Future<void> saveUserData(UserModel user) async {
    _mockUser = user;
  }

  @override
  Future<void> savePin(String uid, String pin) async {
    if (_mockUser != null && _mockUser!.id == uid) {
      _mockUser = _mockUser!.copyWith(pin: pin);
    }
  }
}

class _FakeUserCredential implements UserCredential {
  @override
  final User? user = null;
  @override
  final AuthCredential? credential = null;
  @override
  final AdditionalUserInfo? additionalUserInfo = null;
}
