import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/repositories/user_repository.dart';

class MockUserRepository implements IUserRepository {
  final List<UserModel> _users = [
    UserModel(
        id: 'u1',
        phoneNumber: '+25112345678',
        displayName: 'Mock Staff 1',
        role: 'admin',
        isOnDuty: true,
        createdAt: DateTime.now()),
    UserModel(
        id: 'u2',
        phoneNumber: '+25187654321',
        displayName: 'Mock Staff 2',
        role: 'admin',
        isOnDuty: false,
        createdAt: DateTime.now()),
  ];

  @override
  Future<UserModel?> getCurrentUser(String uid) async {
    try {
      return _users.firstWhere((u) => u.id == uid);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createUser(UserModel user) async {
    _users.add(user);
  }

  @override
  Future<void> updateUserDetails(String uid,
      {String? displayName, String? phoneNumber, bool? isOnDuty}) async {
    final index = _users.indexWhere((u) => u.id == uid);
    if (index != -1) {
      _users[index] = _users[index].copyWith(
        displayName: displayName,
        phoneNumber: phoneNumber,
        isOnDuty: isOnDuty,
      );
    }
  }

  @override
  Future<List<UserModel>> fetchStaff() async {
    return _users.where((u) => u.role == 'admin').toList();
  }

  @override
  Future<List<UserModel>> fetchAllUsers() async {
    return List.from(_users);
  }
}
