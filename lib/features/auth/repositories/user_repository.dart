import 'package:dr_shine_app/features/auth/models/user_model.dart';

abstract class IUserRepository {
  Future<UserModel?> getCurrentUser(String uid);
  Future<void> createUser(UserModel user);
  Future<void> updateUserDetails(String uid,
      {String? displayName, String? phoneNumber, bool? isOnDuty});
  Future<List<UserModel>> fetchStaff();
  Future<List<UserModel>> fetchAllUsers();
}
