import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dr_shine_app/features/admin/models/tenant_model.dart';
import 'package:dr_shine_app/features/admin/repositories/tenant_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class SupabaseTenantRepository implements ITenantRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<TenantModel>> getTenants() async {
    try {
      final response = await _client
          .from('tenants')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => TenantModel.fromMap(data))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to fetch tenants', e);
      return [];
    }
  }

  @override
  Future<void> createTenant(String name) async {
    try {
      await _client.from('tenants').insert({'name': name});
    } catch (e) {
      LoggerService.error('Failed to create tenant', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteTenant(String id) async {
    try {
      await _client.from('tenants').delete().eq('id', id);
    } catch (e) {
      LoggerService.error('Failed to delete tenant', e);
      rethrow;
    }
  }
}
