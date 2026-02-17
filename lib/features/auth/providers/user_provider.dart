import 'package:flutter/material.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/repositories/user_repository.dart';
import 'package:dr_shine_app/features/auth/repositories/auth_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class UserProvider extends ChangeNotifier {
  final IUserRepository _repository;

  List<UserModel> _allUsers = [];
  bool _isLoading = false;

  UserProvider(this._repository);

  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;

  List<UserModel> get admins =>
      _allUsers.where((u) => u.role == 'admin').toList();
  List<UserModel> get staff =>
      _allUsers.where((u) => u.role == 'staff').toList();
  List<UserModel> get washers =>
      _allUsers.where((u) => u.role == 'washer').toList();
  List<UserModel> get workers =>
      _allUsers.where((u) => u.role == 'staff' || u.role == 'washer').toList();
  List<UserModel> get customers =>
      _allUsers.where((u) => u.role == 'customer').toList();

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allUsers = await _repository.fetchAllUsers();
      print(
          'UserProvider: Fetched ${_allUsers.length} users. Workers: ${workers.length}');
      for (var user in workers) {
        print(
            'UserProvider: Worker: ${user.displayName} (${user.role}), Tenant: ${user.tenantId}');
      }
    } catch (e) {
      LoggerService.error('Error fetching users in provider', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _repository.createUser(user);
      await fetchUsers();
    } catch (e) {
      LoggerService.error('User creation failed', e);
      rethrow;
    }
  }

  /// Creates a staff member who CAN login independently with a PIN.
  Future<void> createStaffAccount(UserModel user, String pin,
      {required IAuthRepository authRepository}) async {
    try {
      await authRepository.registerStaff(
        user.phoneNumber,
        pin,
        user.displayName ?? 'Staff',
        user.role,
        tenantId: user.tenantId,
      );
      await fetchUsers();
    } catch (e) {
      LoggerService.error('Staff account creation failed', e);
      rethrow;
    }
  }

  /// Creates a washer or operational staff who does NOT need to login.
  /// Standardized to use registration RPC for schema/RLS safety.
  Future<void> createWasherAccount(UserModel user,
      {required IAuthRepository authRepository}) async {
    try {
      await authRepository.registerStaff(
        user.phoneNumber,
        '0000', // Default PIN for non-login accounts
        user.displayName ?? 'Washer',
        user.role,
        tenantId: user.tenantId,
      );
      await fetchUsers();
    } catch (e) {
      LoggerService.error('Washer account creation failed', e);
      rethrow;
    }
  }

  Future<void> updateUserDetails(String userId,
      {String? displayName, String? phoneNumber, bool? isOnDuty}) async {
    try {
      await _repository.updateUserDetails(userId,
          displayName: displayName,
          phoneNumber: phoneNumber,
          isOnDuty: isOnDuty);
      await fetchUsers();
    } catch (e) {
      LoggerService.error('User update failed', e);
      rethrow;
    }
  }

  Future<void> updateOnDuty(String userId, bool isOnDuty) async {
    await updateUserDetails(userId, isOnDuty: isOnDuty);
  }
}
