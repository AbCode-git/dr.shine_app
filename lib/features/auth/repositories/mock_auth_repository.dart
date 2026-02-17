import 'dart:async';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/repositories/auth_repository.dart';
import 'package:dr_shine_app/core/utils/mock_data.dart';

class MockAuthRepository implements IAuthRepository {
  final _authStateController = StreamController<String?>.broadcast();
  UserModel? _mockUser;

  @override
  Stream<String?> get authStateChanges => _authStateController.stream;

  @override
  Future<void> signInWithPhoneAndPin(String phoneNumber, String pin) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simple mock validation
    if (phoneNumber.endsWith('00')) {
      _mockUser = MockData.superAdminUser;
    } else if (phoneNumber.endsWith('44')) {
      _mockUser = MockData.adminUser;
    } else {
      _mockUser = UserModel(
        id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        phoneNumber: phoneNumber,
        role: 'customer',
        createdAt: DateTime.now(),
      );
    }

    _authStateController.add(_mockUser?.id);
  }

  @override
  Future<void> signOut() async {
    _mockUser = null;
    _authStateController.add(null);
  }

  @override
  Future<UserModel?> getUserData(String uid) async {
    if (uid == 'mock_admin_uid') return MockData.adminUser;
    if (_mockUser?.id == uid) return _mockUser;
    return null;
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

  @override
  Future<void> signUp(
      String phoneNumber, String pin, String displayName, String role,
      {String? tenantId}) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockUser = UserModel(
      id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      phoneNumber: phoneNumber,
      displayName: displayName,
      role: role,
      pin: pin,
      createdAt: DateTime.now(),
    );
    _authStateController.add(_mockUser?.id);
  }

  @override
  Future<void> registerStaff(
      String phoneNumber, String pin, String displayName, String role,
      {String? tenantId}) async {
    await Future.delayed(const Duration(seconds: 1));
    print('Mock: Staff $displayName registered successfully.');
  }
}
