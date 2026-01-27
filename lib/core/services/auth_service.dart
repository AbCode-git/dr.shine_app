import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/bootstrap.dart';
import 'package:dr_shine_app/core/utils/mock_data.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get user {
    if (!isFirebaseInitialized) return const Stream.empty();
    return _auth.authStateChanges();
  }

  // Verify phone number
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
  }) async {
    // Mock bypass for demo numbers
    if (phoneNumber.endsWith('00') || phoneNumber.endsWith('44') || phoneNumber.endsWith('55')) {
      await Future.delayed(const Duration(seconds: 1));
      onCodeSent('mock_verification_id');
      return;
    }

    if (!isFirebaseInitialized) {
      // Return error for unknown numbers if Firebase is not initialized
      onVerificationFailed(FirebaseAuthException(code: 'network-request-failed', message: 'Firebase not initialized. Use a demo number.'));
      return;
    }
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: onVerificationFailed,
      codeSent: (String vid, int? resendToken) {
        onCodeSent(vid);
      },
      codeAutoRetrievalTimeout: (String vid) {},
    );
  }

  // Sign in with credential
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  // Sign out
  Future<void> signOut() async {
    if (!isFirebaseInitialized) return;
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    if (!isFirebaseInitialized) {
      // Return mock admin for testing if uid matches, else null
      if (uid == 'mock_admin_uid') return MockData.adminUser;
      return MockData.customerUser;
    }
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Create or update user data
  Future<void> saveUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  // Save PIN for user
  Future<void> savePin(String uid, String pin) async {
    if (!isFirebaseInitialized) return;
    await _firestore.collection('users').doc(uid).update({'pin': pin});
  }
}
