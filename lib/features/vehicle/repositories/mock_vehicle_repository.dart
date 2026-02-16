import 'package:dr_shine_app/features/vehicle/models/vehicle_model.dart';
import 'package:dr_shine_app/features/vehicle/repositories/vehicle_repository.dart';

class MockVehicleRepository implements IVehicleRepository {
  final List<VehicleModel> _vehicles = [];

  @override
  Future<List<VehicleModel>> getVehiclesForUser(String userId) async {
    return _vehicles.where((v) => v.ownerId == userId).toList();
  }

  @override
  Future<void> registerVehicle(VehicleModel vehicle) async {
    _vehicles.add(vehicle);
  }
}
