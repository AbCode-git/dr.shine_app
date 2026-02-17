import 'package:flutter/material.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/features/admin/repositories/service_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';
import 'package:dr_shine_app/core/services/service_locator.dart';

class ServiceProvider extends ChangeNotifier {
  IServiceRepository? _repository;

  List<ServiceModel> _services = [];
  bool _isLoading = false;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;

  ServiceProvider() {
    _initRepository();
  }

  void _initRepository() {
    try {
      _repository = locator.serviceRepository;
      fetchServices();
    } catch (e) {
      LoggerService.error('ServiceProvider: Repository not ready yet', e);
    }
  }

  Future<void> fetchServices() async {
    if (_repository == null) {
      _repository = locator.serviceRepository;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _services = await _repository!.getServices();
      LoggerService.info('Services fetched: ${_services.length}');

      // Keep legacy default list in sync for any components still using it directly
      defaultServices.clear();
      defaultServices.addAll(_services);
    } catch (e) {
      LoggerService.error('Failed to fetch services', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addService(ServiceModel service) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository!.addService(service);
      await fetchServices(); // Refresh list to get generated IDs/etc
      LoggerService.info('Service added: ${service.name}');
    } catch (e) {
      LoggerService.error('Failed to add service', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateService(ServiceModel updatedService) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository!.updateService(updatedService);

      // Optimistic update for UI responsiveness
      final index = _services.indexWhere((s) => s.id == updatedService.id);
      if (index != -1) {
        _services[index] = updatedService;
      }

      await fetchServices(); // Full refresh to ensure consistency
    } catch (e) {
      LoggerService.error('Failed to update service', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteService(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository!.deleteService(id);
      _services.removeWhere((s) => s.id == id); // Optimistic UI update
      await fetchServices(); // Ensure sync
    } catch (e) {
      LoggerService.error('Failed to delete service', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
