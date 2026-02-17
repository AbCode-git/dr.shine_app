import 'package:flutter/material.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class ServiceProvider extends ChangeNotifier {
  final List<ServiceModel> _services = List.from(defaultServices);
  bool _isLoading = false;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;

  Future<void> addService(ServiceModel service) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would be a repository call
      await Future.delayed(const Duration(milliseconds: 300));
      _services.add(service);
      // Also update the static list to maintain session consistency if anything still uses it
      if (!defaultServices.any((s) => s.id == service.id)) {
        defaultServices.add(service);
      }
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
      await Future.delayed(const Duration(milliseconds: 200));
      final index = _services.indexWhere((s) => s.id == updatedService.id);
      if (index != -1) {
        _services[index] = updatedService;

        // Update static defaults for session persistence
        final defaultIndex =
            defaultServices.indexWhere((s) => s.id == updatedService.id);
        if (defaultIndex != -1) {
          defaultServices[defaultIndex] = updatedService;
        }
      }
    } catch (e) {
      LoggerService.error('Failed to update service', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
