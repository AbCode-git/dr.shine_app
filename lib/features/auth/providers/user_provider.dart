import 'package:flutter/material.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/repositories/user_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class UserProvider extends ChangeNotifier {
  final IUserRepository _repository;

  List<UserModel> _allUsers = [];
  bool _isLoading = false;

  UserProvider(this._repository);

  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;

  List<UserModel> get staff =>
      _allUsers.where((u) => u.role == 'admin').toList();
  List<UserModel> get customers =>
      _allUsers.where((u) => u.role == 'customer').toList();

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allUsers = await _repository.fetchAllUsers();
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
