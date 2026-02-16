import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/features/booking/repositories/booking_repository.dart';
import 'package:dr_shine_app/core/error/app_exceptions.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class FirebaseBookingRepository implements IBookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<BookingModel>> getBookingsByDateRange(
      DateTime start, DateTime end) {
    return _firestore
        .collection('bookings')
        .where('createdAt', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('createdAt', isLessThanOrEqualTo: end.toIso8601String())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data()))
            .toList())
        .handleError((e) {
      LoggerService.error('Failed to stream bookings', e);
      throw DatabaseException('Failed to fetch bookings from cloud');
    });
  }

  @override
  Future<void> createBooking(BookingModel booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .set(booking.toMap());
      LoggerService.info('Booking created: ${booking.id}');
    } catch (e) {
      LoggerService.error('Failed to create booking', e);
      throw DatabaseException('Could not save booking to database');
    }
  }

  @override
  Future<void> updateBookingStatus(String id, String status,
      {DateTime? completedAt}) async {
    try {
      final data = {'status': status};
      if (completedAt != null) {
        data['completedAt'] = completedAt.toIso8601String();
      }
      await _firestore.collection('bookings').doc(id).update(data);
    } catch (e) {
      LoggerService.error('Failed to update status', e);
      throw DatabaseException('Failed to update booking status');
    }
  }

  @override
  Future<void> completeWash(BookingModel booking) async {
    try {
      final batch = _firestore.batch();
      final bookingRef = _firestore.collection('bookings').doc(booking.id);

      batch.update(bookingRef, {
        'status': 'completed',
        'completedAt': DateTime.now().toIso8601String(),
      });

      final userRef = _firestore.collection('users').doc(booking.userId);
      batch.update(userRef, {'loyaltyPoints': FieldValue.increment(1)});

      await batch.commit();
      LoggerService.info(
          'Wash completed & points awarded for booking: ${booking.id}');
    } catch (e) {
      LoggerService.error('Failed to complete wash batch', e);
      throw DatabaseException('Transaction failed');
    }
  }
}
