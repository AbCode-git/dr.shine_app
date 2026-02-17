import 'package:dr_shine_app/features/auth/models/user_model.dart';

abstract class IAuthRepository {
  /// Emits the current user's unique ID or null if unauthenticated.
  Stream<String?> get authStateChanges;

  /// Performs a simplified login using phone and PIN (No OTP).
  Future<void> signInWithPhoneAndPin(String phoneNumber, String pin);

  Future<void> signOut();

  Future<UserModel?> getUserData(String uid);

  Future<void> saveUserData(UserModel user);

  Future<void> savePin(String uid, String pin);
}
