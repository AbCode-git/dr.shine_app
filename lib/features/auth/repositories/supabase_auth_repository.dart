import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/repositories/auth_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class SupabaseAuthRepository implements IAuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Stream<String?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((data) => data.session?.user.id);

  @override
  Future<void> signInWithPhoneAndPin(String phoneNumber, String pin) async {
    try {
      // Virtual Email Strategy: Derive email and password from phone and PIN
      final email = _generateVirtualEmail(phoneNumber);
      final password = _generatePassword(pin);

      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      LoggerService.error('Supabase SignIn failed', e);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserModel?> getUserData(String uid) async {
    try {
      final response =
          await _client.from('profiles').select().eq('id', uid).maybeSingle();

      if (response != null) {
        return UserModel.fromMap(response);
      }
      return null;
    } catch (e) {
      LoggerService.error('Failed to get user data from Supabase', e);
      return null;
    }
  }

  @override
  Future<void> saveUserData(UserModel user) async {
    try {
      await _client.from('profiles').upsert(user.toMap());
    } catch (e) {
      LoggerService.error('Failed to save user data to Supabase', e);
      rethrow;
    }
  }

  @override
  Future<void> savePin(String uid, String pin) async {
    try {
      // For Supabase Auth, we also need to update the password if the PIN changes
      // but for now let's just update the profile
      await _client.from('profiles').update({'pin': pin}).eq('id', uid);

      // Update Auth Password if session is active
      await _client.auth
          .updateUser(UserAttributes(password: _generatePassword(pin)));
    } catch (e) {
      LoggerService.error('Failed to save PIN in Supabase', e);
      rethrow;
    }
  }

  String _generateVirtualEmail(String phoneNumber) {
    // Normalize phone number and create a virtual email
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return 'user_$cleanPhone@drshine.com';
  }

  String _generatePassword(String pin) {
    // Simple salt for the PIN to meet password requirements if any
    return 'ds_auth_$pin';
  }
}
