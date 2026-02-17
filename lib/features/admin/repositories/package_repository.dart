import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dr_shine_app/features/admin/models/package_model.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

abstract class IPackageRepository {
  Future<List<PackageModel>> getPackages();
  Future<void> addPackage(PackageModel package);
  Future<void> updatePackage(PackageModel package);
  Future<void> deletePackage(String id);
}

class SupabasePackageRepository implements IPackageRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<PackageModel>> getPackages() async {
    try {
      final data = await _client
          .from('packages')
          .select()
          .eq('isActive', true)
          .order('name', ascending: true);
      return (data as List).map((json) => PackageModel.fromMap(json)).toList();
    } catch (e) {
      LoggerService.error('Supabase GetPackages failed', e);
      // Return empty list instead of rethrowing to prevent app crash if table is missing
      return [];
    }
  }

  @override
  Future<void> addPackage(PackageModel package) async {
    try {
      await _client.from('packages').insert(package.toMap());
    } catch (e) {
      LoggerService.error('Supabase AddPackage failed', e);
      rethrow;
    }
  }

  @override
  Future<void> updatePackage(PackageModel package) async {
    try {
      await _client
          .from('packages')
          .update(package.toMap())
          .eq('id', package.id);
    } catch (e) {
      LoggerService.error('Supabase UpdatePackage failed', e);
      rethrow;
    }
  }

  @override
  Future<void> deletePackage(String id) async {
    try {
      await _client.from('packages').update({'isActive': false}).eq('id', id);
    } catch (e) {
      LoggerService.error('Supabase DeletePackage failed', e);
      rethrow;
    }
  }
}

class MockPackageRepository implements IPackageRepository {
  final List<PackageModel> _mockPackages = [
    PackageModel(
      id: 'pkg_gold',
      name: 'Gold Package',
      description: 'Exterior + Interior + Wax',
      price: 600,
      includedServiceIds: ['srv_ext', 'srv_int', 'srv_wax'],
    ),
    PackageModel(
      id: 'pkg_silver',
      name: 'Silver Package',
      description: 'Exterior + Interior',
      price: 350,
      includedServiceIds: ['srv_ext', 'srv_int'],
    ),
  ];

  @override
  Future<List<PackageModel>> getPackages() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockPackages;
  }

  @override
  Future<void> addPackage(PackageModel package) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockPackages.add(package);
  }

  @override
  Future<void> updatePackage(PackageModel package) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockPackages.indexWhere((p) => p.id == package.id);
    if (index != -1) {
      _mockPackages[index] = package;
    }
  }

  @override
  Future<void> deletePackage(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockPackages.removeWhere((p) => p.id == id);
  }
}
