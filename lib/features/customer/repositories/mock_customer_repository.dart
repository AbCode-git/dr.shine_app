import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/features/customer/repositories/customer_repository_interface.dart';

class MockCustomerRepository implements ICustomerRepository {
  @override
  Future<List<BookingModel>> searchByPlate(String query) async => [];

  @override
  Future<List<BookingModel>> getCustomerHistory(String plateNumber) async => [];
}
