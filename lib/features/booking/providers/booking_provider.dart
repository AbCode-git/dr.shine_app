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
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    _bookingsSubscription =
        _repository.getBookingsByDateRange(startOfDay, endOfDay).listen(
      (list) {
        _bookings.clear();
        _bookings.addAll(list);
        notifyListeners();
      },
      onError: (e) => LoggerService.error('BookingProvider stream error', e),
    );
  }

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  // Stream today's bookings (for admin)
  Stream<List<BookingModel>> getTodayBookings() {
    final now = DateTime.now();
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
    } catch (e) {
      LoggerService.error('Status update failed', e);
      rethrow;
    }
  }

  // Complete wash
  Future<void> completeWash(BookingModel booking) async {
    try {
      await _repository.completeWash(booking);
    } catch (e) {
      LoggerService.error('Wash completion failed', e);
      rethrow;
    }
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    super.dispose();
  }
}
