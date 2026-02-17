import 'package:dr_shine_app/features/admin/models/tenant_model.dart';

abstract class ITenantRepository {
  Future<List<TenantModel>> getTenants();
  Future<void> createTenant(String name);
  Future<void> deleteTenant(String id);
}
