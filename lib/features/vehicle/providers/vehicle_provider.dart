import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_shine_app/features/vehicle/models/vehicle_model.dart';
import 'package:dr_shine_app/bootstrap.dart';
import 'package:dr_shine_app/core/utils/mock_data.dart';

class VehicleProvider extends ChangeNotifier {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  
  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;

  List<VehicleModel> get vehicles => _vehicles;
  bool get isLoading => _isLoading;

  // Fetch vehicles for a user
  Future<void> fetchVehicles(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!isFirebaseInitialized) {
        await Future.delayed(const Duration(milliseconds: 500));
        _vehicles = [MockData.vehicles.first]; // Default mock vehicle
        return;
      }
      final snapshot = await _firestore
          .collection('vehicles')
          .where('ownerId', isEqualTo: userId)
          .get();
      
      _vehicles = snapshot.docs
          .map((doc) => VehicleModel.fromMap(doc.data()))
          .toList();
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
      if (!isFirebaseInitialized) {
        await Future.delayed(const Duration(milliseconds: 500));
        _vehicles.add(vehicle);
        return;
      }
      await _firestore.collection('vehicles').doc(vehicle.id).set(vehicle.toMap());
      _vehicles.add(vehicle);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get specific vehicle by ID
  Future<VehicleModel?> getVehicleById(String vehicleId) async {
    if (!isFirebaseInitialized) {
      // Find in mock data or current list
      try {
        return MockData.vehicles.firstWhere((v) => v.id == vehicleId);
      } catch (_) {
        return _vehicles.cast<VehicleModel?>().firstWhere((v) => v?.id == vehicleId, orElse: () => null);
      }
    }
    final doc = await _firestore.collection('vehicles').doc(vehicleId).get();
    if (doc.exists) {
      return VehicleModel.fromMap(doc.data()!);
    }
    return null;
  }
}
