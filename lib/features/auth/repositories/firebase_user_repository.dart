import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/repositories/user_repository.dart';
import 'package:dr_shine_app/core/error/app_exceptions.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class FirebaseUserRepository implements IUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel?> getCurrentUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      LoggerService.error('Failed to get user', e);
      throw DatabaseException('Failed to fetch user data');
    }
  }

  @override
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      LoggerService.error('Failed to create user', e);
      throw DatabaseException('Failed to register user in cloud');
    }
  }

  @override
  Future<void> updateUserDetails(String uid,
      {String? displayName, String? phoneNumber, bool? isOnDuty}) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null) data['displayName'] = displayName;
      if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
      if (isOnDuty != null) data['isOnDuty'] = isOnDuty;

      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      LoggerService.error('Failed to update user', e);
      throw DatabaseException('Update failed');
    }
  }

  @override
  Future<List<UserModel>> fetchStaff() async {
    try {
      final query = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();
      return query.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      LoggerService.error('Failed to fetch staff', e);
      throw DatabaseException('Could not load staff list');
    }
  }

  @override
  Future<List<UserModel>> fetchAllUsers() async {
    try {
      final query = await _firestore.collection('users').get();
      return query.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      LoggerService.error('Failed to fetch all users', e);
      throw DatabaseException('Could not load user list');
    }
  }
}
