import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

abstract class IServiceRepository {
  Future<List<ServiceModel>> getServices();
  Future<void> addService(ServiceModel service);
  Future<void> updateService(ServiceModel service);
  Future<void> deleteService(String id);
}

class SupabaseServiceRepository implements IServiceRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<ServiceModel>> getServices() async {
    try {
      final data = await _client
          .from('services')
          .select()
          .order('name', ascending: true);
      return (data as List).map((json) => ServiceModel.fromMap(json)).toList();
    } catch (e) {
      LoggerService.error('Supabase GetServices failed', e);
      rethrow;
    }
  }

  @override
  Future<void> addService(ServiceModel service) async {
    try {
      await _client.from('services').insert(service.toMap());
    } catch (e) {
      LoggerService.error('Supabase AddService failed', e);
      rethrow;
    }
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    try {
      await _client
          .from('services')
          .update(service.toMap())
          .eq('id', service.id);
    } catch (e) {
      LoggerService.error('Supabase UpdateService failed', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteService(String id) async {
    try {
      await _client.from('services').delete().eq('id', id);
    } catch (e) {
      LoggerService.error('Supabase DeleteService failed', e);
      rethrow;
    }
  }
}

class MockServiceRepository implements IServiceRepository {
  final List<ServiceModel> _mockServices = List.from(defaultServices);

  @override
  Future<List<ServiceModel>> getServices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockServices;
  }

  @override
  Future<void> addService(ServiceModel service) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockServices.add(service);
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockServices.indexWhere((s) => s.id == service.id);
    if (index != -1) {
      _mockServices[index] = service;
    }
  }

  @override
  Future<void> deleteService(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockServices.removeWhere((s) => s.id == id);
  }
}
