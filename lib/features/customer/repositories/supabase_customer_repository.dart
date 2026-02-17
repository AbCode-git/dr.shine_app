import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/features/customer/repositories/customer_repository_interface.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class SupabaseCustomerRepository implements ICustomerRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<BookingModel>> searchByPlate(String query) async {
    try {
      if (query.length < 2) return [];

      // Search for bookings with matching plate number
      // We limit to 20 to avoid over-fetching
      final response = await _client
          .from('bookings')
          .select()
          .ilike('plateNumber', '%$query%')
          .order('bookingDate', ascending: false)
          .limit(50);

      final bookings =
          (response as List).map((json) => BookingModel.fromMap(json)).toList();

      // Deduplicate by plate number, keeping the most recent one
      final Map<String, BookingModel> uniquePlates = {};
      for (var booking in bookings) {
        if (booking.plateNumber != null &&
            !uniquePlates.containsKey(booking.plateNumber)) {
          uniquePlates[booking.plateNumber!] = booking;
        }
      }

      return uniquePlates.values.toList();
    } catch (e) {
      LoggerService.error('SearchByPlate failed', e);
      return [];
    }
  }

  @override
  Future<List<BookingModel>> getCustomerHistory(String plateNumber) async {
    try {
      final response = await _client
          .from('bookings')
          .select()
          .eq('plateNumber', plateNumber)
          .order('bookingDate', ascending: false);

      return (response as List)
          .map((json) => BookingModel.fromMap(json))
          .toList();
    } catch (e) {
      LoggerService.error('GetCustomerHistory failed', e);
      return [];
    }
  }
}
