import 'package:flutter/material.dart';
import 'package:dr_shine_app/features/vehicle/models/vehicle_model.dart';
import 'package:dr_shine_app/features/vehicle/repositories/vehicle_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class VehicleProvider extends ChangeNotifier {
  final IVehicleRepository _repository;

  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;

  VehicleProvider(this._repository);

  List<VehicleModel> get vehicles => _vehicles;
  bool get isLoading => _isLoading;

  // Fetch vehicles for a user
  Future<void> fetchVehicles(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _vehicles = await _repository.getVehiclesForUser(userId);
    } catch (e) {
      LoggerService.error('Failed to fetch vehicles in provider', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register a new vehicle
  Future<void> registerVehicle(VehicleModel vehicle) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.registerVehicle(vehicle);
      _vehicles.add(vehicle);
    } catch (e) {
      LoggerService.error('Vehicle registration failed', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get specific vehicle by ID
  Future<VehicleModel?> getVehicleById(String vehicleId) async {
    try {
      // In a senior app, we might have a getVehicleById in repo,
      // or we just find in the current list if already fetched.
      return _vehicles.firstWhere((v) => v.id == vehicleId);
    } catch (_) {
      // If not found in local list, we could fetch from repo if needed
      return null;
    }
  }
}
