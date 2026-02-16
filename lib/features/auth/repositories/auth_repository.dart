import 'package:firebase_auth/firebase_auth.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';

abstract class IAuthRepository {
  Stream<User?> get authStateChanges;
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(Exception e) onVerificationFailed,
  });
  Future<UserCredential> signInWithCredential(AuthCredential credential);
  Future<void> signOut();
  Future<UserModel?> getUserData(String uid);
  Future<void> saveUserData(UserModel user);
  Future<void> savePin(String uid, String pin);
}
