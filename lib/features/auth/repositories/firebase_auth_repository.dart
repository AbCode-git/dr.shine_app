import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/repositories/auth_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';
import 'package:dr_shine_app/core/error/app_exceptions.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<String?> get authStateChanges =>
      _auth.authStateChanges().map((u) => u?.uid);

  @override
  Future<void> signInWithPhoneAndPin(String phoneNumber, String pin) async {
    // Firebase doesn't supported PIN login out of the box in this way
    throw UnimplementedError('Firebase PIN login not implemented');
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      LoggerService.error('Failed to get user data', e);
      throw DatabaseException('Failed to load user profile');
    }
  }

  @override
  Future<void> saveUserData(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      LoggerService.error('Failed to save user data', e);
      throw DatabaseException('Failed to save profile');
    }
  }

  @override
  Future<void> savePin(String uid, String pin) async {
    try {
      await _firestore.collection('users').doc(uid).update({'pin': pin});
    } catch (e) {
      LoggerService.error('Failed to save pin', e);
      throw DatabaseException('Failed to secure account with PIN');
    }
  }
}
