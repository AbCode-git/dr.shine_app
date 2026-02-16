import 'package:dr_shine_app/features/vehicle/models/vehicle_model.dart';

abstract class IVehicleRepository {
  Future<List<VehicleModel>> getVehiclesForUser(String userId);
  Future<void> registerVehicle(VehicleModel vehicle);
}
