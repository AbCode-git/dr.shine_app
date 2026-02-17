import 'package:dr_shine_app/features/booking/models/booking_model.dart';

abstract class ICustomerRepository {
  Future<List<BookingModel>> searchByPlate(String query);
  Future<List<BookingModel>> getCustomerHistory(String plateNumber);
}
