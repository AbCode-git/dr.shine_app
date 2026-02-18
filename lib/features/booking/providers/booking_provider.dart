import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/features/booking/repositories/booking_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class BookingProvider extends ChangeNotifier {
  final IBookingRepository _repository;

  final List<BookingModel> _bookings = [];
  bool _isLoading = false;
  StreamSubscription? _bookingsSubscription;

  BookingProvider(this._repository) {
    _init();
  }

  void _init() {
    // Listen to today's bookings by default to keep local list updated
    final now = DateTime.now().toUtc();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    _bookingsSubscription =
        _repository.getBookingsByDateRange(startOfDay, endOfDay).listen(
      (incomingList) {
        // Merge strategy: Keep existing items if they are newer or currently being updated
        // but generally favor the stream for the source of truth.
        for (var incoming in incomingList) {
          final index = _bookings.indexWhere((b) => b.id == incoming.id);
          if (index != -1) {
            _bookings[index] = incoming;
          } else {
            _bookings.add(incoming);
          }
        }

        // Remove items not in the incoming list (except those we just created and are waiting for)
        _bookings.removeWhere((existing) =>
                !incomingList.any((incoming) => incoming.id == existing.id) &&
                existing.status !=
                    'washing' // Don't remove active washes we might have just added
            );

        // Sort by createdAt descending
        _bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        notifyListeners();
      },
      onError: (e) => LoggerService.error('BookingProvider stream error', e),
    );
  }

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  // Stream today's bookings (for admin)
  Stream<List<BookingModel>> getTodayBookings() {
    final now = DateTime.now().toUtc();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getBookingsByDateRange(startOfDay, endOfDay);
  }

  // Stream bookings by date range
  Stream<List<BookingModel>> getBookingsByDateRange(
      DateTime start, DateTime end) {
    return _repository.getBookingsByDateRange(start, end);
  }

  // Create booking
  Future<void> createBooking(BookingModel booking) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.createBooking(booking);
      // Proactively add to local list for immediate feedback
      if (!_bookings.any((b) => b.id == booking.id)) {
        _bookings.insert(0, booking);
      }
      LoggerService.info('Booking created successfully');
    } catch (e) {
      LoggerService.error('Failed to create booking in provider', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String id, String status) async {
    try {
      await _repository.updateBookingStatus(id, status);

      // Proactively update local list
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: status,
        );
      }

      notifyListeners();
    } catch (e) {
      LoggerService.error('Status update failed', e);
      rethrow;
    }
  }

  // Complete wash
  Future<void> completeWash(BookingModel booking) async {
    try {
      await _repository.completeWash(booking);

      // Proactively update local list
      final index = _bookings.indexWhere((b) => b.id == booking.id);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: 'completed',
        );
      }

      notifyListeners();
    } catch (e) {
      LoggerService.error('Wash completion failed', e);
      rethrow;
    }
  }

  // Analytics Helpers
  double get totalRevenueToday => _bookings
      .where((b) => b.status == 'completed' || b.status == 'ready')
      .fold(0.0, (sum, b) => sum + b.price);

  int get completedCountToday => _bookings
      .where((b) => b.status == 'completed' || b.status == 'ready')
      .length;

  int get activeWashesCount => _bookings
      .where((b) => b.status == 'washing' || b.status == 'accepted')
      .length;

  Map<String, int> get washerPerformanceToday {
    final performance = <String, int>{};
    for (var b in _bookings
        .where((b) => b.status == 'completed' || b.status == 'ready')) {
      final name = b.washerStaffName ?? 'Unassigned';
      performance[name] = (performance[name] ?? 0) + 1;
    }
    return performance;
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    super.dispose();
  }
}
