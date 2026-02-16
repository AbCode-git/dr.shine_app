import 'dart:async';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/features/booking/repositories/booking_repository.dart';

class MockBookingRepository implements IBookingRepository {
  final List<BookingModel> _bookings = [
    BookingModel(
      id: 'b1',
      userId: 'customer_456',
      vehicleId: 'v1',
      serviceId: 'interior',
      status: 'pending',
      bookingDate: DateTime.now(),
      createdAt: DateTime.now(),
      price: 500,
    ),
    BookingModel(
      id: 'b2',
      userId: 'customer_555',
      vehicleId: 'v1',
      serviceId: 'full_wash',
      status: 'washing',
      bookingDate: DateTime.now(),
      createdAt: DateTime.now(),
      price: 1200,
    ),
  ];

  final _streamController = StreamController<List<BookingModel>>.broadcast();

  @override
  Stream<List<BookingModel>> getBookingsByDateRange(
      DateTime start, DateTime end) {
    _emit();
    return _streamController.stream.map((list) => list.where((b) {
          return b.createdAt.isAfter(start) && b.createdAt.isBefore(end);
        }).toList());
  }

  @override
  Future<void> createBooking(BookingModel booking) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _bookings.add(booking);
    _emit();
  }

  @override
  Future<void> updateBookingStatus(String id, String status,
      {DateTime? completedAt}) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: status,
        completedAt: completedAt,
      );
      _emit();
    }
  }

  @override
  Future<void> completeWash(BookingModel booking) async {
    await updateBookingStatus(booking.id, 'completed',
        completedAt: DateTime.now());
  }

  void _emit() => _streamController.add(List.from(_bookings));
}
