import 'package:dr_shine_app/features/booking/models/booking_model.dart';

abstract class IBookingRepository {
  Stream<List<BookingModel>> getBookingsByDateRange(
      DateTime start, DateTime end);
  Future<void> createBooking(BookingModel booking);
  Future<void> updateBookingStatus(String id, String status,
      {DateTime? completedAt});
  Future<void> completeWash(BookingModel booking);
}
