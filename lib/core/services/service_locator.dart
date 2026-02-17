import 'package:dr_shine_app/features/booking/repositories/booking_repository.dart';
import 'package:dr_shine_app/features/admin/models/tenant_model.dart';
import 'package:dr_shine_app/features/booking/repositories/mock_booking_repository.dart';
import 'package:dr_shine_app/features/booking/repositories/supabase_booking_repository.dart';

import 'package:dr_shine_app/features/auth/repositories/user_repository.dart';
import 'package:dr_shine_app/features/auth/repositories/mock_user_repository.dart';
import 'package:dr_shine_app/features/auth/repositories/supabase_user_repository.dart';

import 'package:dr_shine_app/features/inventory/repositories/inventory_repository.dart';
import 'package:dr_shine_app/features/inventory/repositories/mock_inventory_repository.dart';
import 'package:dr_shine_app/features/inventory/repositories/supabase_inventory_repository.dart';

import 'package:dr_shine_app/features/status/repositories/status_repository.dart';
import 'package:dr_shine_app/features/status/repositories/mock_status_repository.dart';
import 'package:dr_shine_app/features/status/repositories/supabase_status_repository.dart';

import 'package:dr_shine_app/features/auth/repositories/auth_repository.dart';
import 'package:dr_shine_app/features/auth/repositories/mock_auth_repository.dart';
import 'package:dr_shine_app/features/auth/repositories/supabase_auth_repository.dart';

import 'package:dr_shine_app/features/admin/repositories/tenant_repository.dart';
import 'package:dr_shine_app/features/admin/repositories/supabase_tenant_repository.dart';

import 'package:dr_shine_app/features/admin/repositories/service_repository.dart';
import 'package:dr_shine_app/features/admin/repositories/package_repository.dart';

import 'package:dr_shine_app/features/customer/repositories/customer_repository_interface.dart';
import 'package:dr_shine_app/features/customer/repositories/supabase_customer_repository.dart';
import 'package:dr_shine_app/features/customer/repositories/mock_customer_repository.dart';

import 'package:dr_shine_app/bootstrap.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final IBookingRepository bookingRepository;
  late final IUserRepository userRepository;

  late final IInventoryRepository inventoryRepository;
  late final IStatusRepository statusRepository;
  late final IAuthRepository authRepository;
  late final ITenantRepository tenantRepository;
  late final IServiceRepository serviceRepository;
  late final IPackageRepository packageRepository;
  late final ICustomerRepository customerRepository;

  void setup() {
    if (isSupabaseInitialized) {
      bookingRepository = SupabaseBookingRepository();
      userRepository = SupabaseUserRepository();
      inventoryRepository = SupabaseInventoryRepository();
      statusRepository = SupabaseStatusRepository();
      authRepository = SupabaseAuthRepository();
      tenantRepository = SupabaseTenantRepository();
      serviceRepository = SupabaseServiceRepository();
      packageRepository = SupabasePackageRepository();
      customerRepository = SupabaseCustomerRepository();
    } else {
      // Fallback to mock repositories for offline/testing
      bookingRepository = MockBookingRepository();
      userRepository = MockUserRepository();
      inventoryRepository = MockInventoryRepository();
      statusRepository = MockStatusRepository();
      authRepository = MockAuthRepository();
      tenantRepository = MockTenantRepository();
      serviceRepository = MockServiceRepository();
      packageRepository = MockPackageRepository();
      customerRepository = MockCustomerRepository();
    }
  }
}

class MockTenantRepository implements ITenantRepository {
  @override
  Future<List<TenantModel>> getTenants() async => [];
  @override
  Future<void> createTenant(String name) async {}
  @override
  Future<void> deleteTenant(String id) async {}
}

final locator = ServiceLocator();
