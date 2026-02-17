import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/repositories/auth_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class SupabaseAuthRepository implements IAuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Stream<String?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((data) => data.session?.user.id);

  @override
  Future<void> signInWithPhoneAndPin(String phoneNumber, String pin) async {
    try {
      final email = _generateVirtualEmail(phoneNumber);
      final password = _generatePassword(pin);

      print(
          'SupabaseAuth: Attempting login with email=$email password=$password');

      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('SupabaseAuth: Login SUCCESS');
    } catch (e) {
      print('SupabaseAuth: Login FAILED: $e');
      LoggerService.error('Supabase SignIn failed', e);
      rethrow;
    }
  }

  @override
  Future<void> signUp(
      String phoneNumber, String pin, String displayName, String role,
      {String? tenantId}) async {
    try {
      print(
          'SupabaseAuth: Attempting bypass v9 signUp for $phoneNumber tenant=$tenantId');

      await registerStaff(phoneNumber, pin, displayName, role,
          tenantId: tenantId);

      print(
          'SupabaseAuth: Bypass registration success. Performing auto-login...');

      // Step 2: Manually sign in the user to establish the session
      await signInWithPhoneAndPin(phoneNumber, pin);

      print('SupabaseAuth: Auto-login success for $displayName');
    } catch (e) {
      print('SupabaseAuth: SignUp FAILED: $e');
      LoggerService.error('Supabase SignUp failed', e);
      rethrow;
    }
  }

  /// Registers a staff member without logging in as them.
  /// Used by Admins to create team accounts.
  Future<void> registerStaff(
      String phoneNumber, String pin, String displayName, String role,
      {String? tenantId}) async {
    final response = await _client.rpc('register_user_bypass_v9', params: {
      'p_phone': phoneNumber,
      'p_pin': pin,
      'p_display_name': displayName,
      'p_role': role,
      'p_tenant_id': tenantId,
    });

    final bool success = response['success'] ?? false;
    if (!success) {
      final error = response['error'] ?? 'Unknown registration error';
      throw Exception('Staff registration failed: $error');
    }
    print('SupabaseAuth: Staff $displayName registered successfully via RPC.');
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
      await _client.from('profiles').update({'pin': pin}).eq('id', uid);
      await _client.auth
          .updateUser(UserAttributes(password: _generatePassword(pin)));
    } catch (e) {
      LoggerService.error('Failed to save PIN in Supabase', e);
      rethrow;
    }
  }

  String _generateVirtualEmail(String phoneNumber) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return '$cleanPhone@drshine.app';
  }

  String _generatePassword(String pin) {
    return 'ds_auth_$pin';
  }
}
