import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/features/booking/repositories/booking_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class SupabaseBookingRepository implements IBookingRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Stream<List<BookingModel>> getBookingsByDateRange(
      DateTime start, DateTime end) {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('createdAt', ascending: false)
        .map((data) => data
            .map((json) => BookingModel.fromMap(json))
            .where((booking) =>
                booking.bookingDate
                    .isAfter(start.subtract(const Duration(seconds: 1))) &&
                booking.bookingDate
                    .isBefore(end.add(const Duration(seconds: 1))))
            .toList());
  }

  @override
  Future<void> createBooking(BookingModel booking) async {
    try {
      await _client.from('bookings').insert(booking.toMap());
    } catch (e) {
      LoggerService.error('Supabase CreateBooking failed', e);
      rethrow;
    }
  }

  @override
  Future<void> updateBookingStatus(String id, String status) async {
    try {
      final updates = {
        'status': status,
      };
      await _client.from('bookings').update(updates).eq('id', id);
    } catch (e) {
      LoggerService.error('Supabase UpdateBookingStatus failed', e);
      rethrow;
    }
  }

  @override
  Future<void> completeWash(BookingModel booking) async {
    try {
      await updateBookingStatus(booking.id, 'completed');
    } catch (e) {
      LoggerService.error('Supabase CompleteWash failed', e);
      rethrow;
    }
  }
}
