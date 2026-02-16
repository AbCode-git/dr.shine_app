import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_shine_app/features/vehicle/models/vehicle_model.dart';
import 'package:dr_shine_app/features/vehicle/repositories/vehicle_repository.dart';
import 'package:dr_shine_app/core/error/app_exceptions.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class FirebaseVehicleRepository implements IVehicleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<VehicleModel>> getVehiclesForUser(String userId) async {
    try {
      final query = await _firestore
          .collection('vehicles')
          .where('ownerId', isEqualTo: userId)
          .get();
      return query.docs.map((doc) => VehicleModel.fromMap(doc.data())).toList();
    } catch (e) {
      LoggerService.error('Failed to fetch vehicles', e);
      throw DatabaseException('Failed to load your vehicles');
    }
  }

  @override
  Future<void> registerVehicle(VehicleModel vehicle) async {
    try {
      await _firestore
          .collection('vehicles')
          .doc(vehicle.id)
          .set(vehicle.toMap());
    } catch (e) {
      LoggerService.error('Failed to register vehicle', e);
      throw DatabaseException('Failed to save vehicle');
    }
  }
}
