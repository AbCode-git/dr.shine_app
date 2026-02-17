import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/repositories/user_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class SupabaseUserRepository implements IUserRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<UserModel?> getCurrentUser(String uid) async {
    try {
      final response =
          await _client.from('profiles').select().eq('id', uid).maybeSingle();
      if (response != null) {
        return UserModel.fromMap(response);
      }
      return null;
    } catch (e) {
      LoggerService.error('Supabase getCurrentUser failed', e);
      return null;
    }
  }

  @override
  Future<void> createUser(UserModel user) async {
    try {
      await _client.from('profiles').insert(user.toMap());
    } catch (e) {
      LoggerService.error('Supabase createUser failed', e);
      rethrow;
    }
  }

  @override
  Future<void> updateUserDetails(String uid,
      {String? displayName, String? phoneNumber, bool? isOnDuty}) async {
    try {
      final updates = {
        if (displayName != null) 'displayName': displayName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (isOnDuty != null) 'isOnDuty': isOnDuty,
      };
      await _client.from('profiles').update(updates).eq('id', uid);
    } catch (e) {
      LoggerService.error('Supabase updateUserDetails failed', e);
      rethrow;
    }
  }

  @override
  Future<List<UserModel>> fetchStaff() async {
    try {
      // Assuming staff have a specific characteristic or we just fetch all non-customers
      final response =
          await _client.from('profiles').select().not('role', 'eq', 'customer');
      return (response as List).map((json) => UserModel.fromMap(json)).toList();
    } catch (e) {
      LoggerService.error('Supabase fetchStaff failed', e);
      return [];
    }
  }

  @override
  Future<List<UserModel>> fetchAllUsers() async {
    try {
      final response = await _client.from('profiles').select();
      return (response as List).map((json) => UserModel.fromMap(json)).toList();
    } catch (e) {
      LoggerService.error('Supabase fetchAllUsers failed', e);
      return [];
    }
  }
}
