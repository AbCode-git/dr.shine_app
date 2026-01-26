import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/bootstrap.dart';
import 'package:dr_shine_app/core/utils/mock_data.dart';

class UserProvider extends ChangeNotifier {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  
  List<UserModel> _allUsers = [];
  bool _isLoading = false;

  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;

  List<UserModel> get staff => _allUsers.where((u) => u.role == 'admin').toList();
  List<UserModel> get customers => _allUsers.where((u) => u.role == 'customer').toList();

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!isFirebaseInitialized) {
        await Future.delayed(const Duration(milliseconds: 500));
        _allUsers = [
          MockData.adminUser,
          MockData.customerUser,
          MockData.superAdminUser,
          UserModel(
            id: 'staff_1',
            phoneNumber: '+251911111111',
            displayName: 'John Staff',
            role: 'admin',
            createdAt: DateTime.now(),
          ),
          UserModel(
            id: 'customer_2',
            phoneNumber: '+251922222222',
            displayName: 'Jane Doe',
            role: 'customer',
            loyaltyPoints: 5,
            createdAt: DateTime.now(),
          ),
        ];
      } else {
        final snapshot = await _firestore.collection('users').get();
        _allUsers = snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    if (!isFirebaseInitialized) {
      final index = _allUsers.indexWhere((u) => u.id == userId);
      if (index != -1) {
        final user = _allUsers[index];
        _allUsers[index] = UserModel(
          id: user.id,
          phoneNumber: user.phoneNumber,
          displayName: user.displayName,
          role: newRole,
          loyaltyPoints: user.loyaltyPoints,
          createdAt: user.createdAt,
        );
        notifyListeners();
      }
      return;
    }
    await _firestore.collection('users').doc(userId).update({'role': newRole});
    await fetchUsers();
  }
}
