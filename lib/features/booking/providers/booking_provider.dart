import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/bootstrap.dart';

class BookingProvider extends ChangeNotifier {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  
  final List<BookingModel> _bookings = [];
  bool _isLoading = false;
  
  // For reactive mock updates
  StreamController<List<BookingModel>>? _mockStreamController;

  BookingProvider() {
    if (!isFirebaseInitialized) {
      _bookings.addAll([
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
      ]);
    }
  }

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  // Stream today's bookings (for admin)
  Stream<List<BookingModel>> getTodayBookings() {
    if (!isFirebaseInitialized) {
      _mockStreamController ??= StreamController<List<BookingModel>>.broadcast();
      // Initial push
      Future.delayed(Duration.zero, () {
        _mockStreamController?.add(List.from(_bookings));
      });
      return _mockStreamController!.stream;
    }
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('bookings')
        .where('bookingDate', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('bookingDate', isLessThan: endOfDay.toIso8601String())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data()))
            .toList());
  }

  // Create booking
  Future<void> createBooking(BookingModel booking) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!isFirebaseInitialized) {
        await Future.delayed(const Duration(milliseconds: 500));
        _bookings.add(booking);
        _mockStreamController?.add(List.from(_bookings));
        return;
      }
      await _firestore.collection('bookings').doc(booking.id).set(booking.toMap());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String id, String status) async {
    if (!isFirebaseInitialized) {
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        final b = _bookings[index];
        _bookings[index] = BookingModel(
          id: b.id,
          userId: b.userId,
          vehicleId: b.vehicleId,
          serviceId: b.serviceId,
          status: status,
          bookingDate: b.bookingDate,
          createdAt: b.createdAt,
          price: b.price,
        );
        _mockStreamController?.add(List.from(_bookings));
        notifyListeners();
      }
      return;
    }
    await _firestore.collection('bookings').doc(id).update({'status': status});
  }

  // Complete wash and add loyalty point
  Future<void> completeWash(BookingModel booking, {Map<String, double> requirements = const {}}) async {
    if (!isFirebaseInitialized) {
      await updateBookingStatus(booking.id, 'completed');
      return;
    }
    final batch = _firestore.batch();
    
    // Update booking status
    final bookingRef = _firestore.collection('bookings').doc(booking.id);
    batch.update(bookingRef, {'status': 'completed'});
    
    // Increment user loyalty points
    final userRef = _firestore.collection('users').doc(booking.userId);
    batch.update(userRef, {'loyaltyPoints': FieldValue.increment(1)});
    await batch.commit();
  }

  @override
  void dispose() {
    _mockStreamController?.close();
    super.dispose();
  }

  // Listen to user bookings and trigger notifications (simulated)
  void listenToUserBookings(String userId, Function(String title, String body) onNotify) {
    if (!isFirebaseInitialized) {
      // Mock logic: listen to local stream
      getTodayBookings().listen((list) {
        // This is simplified for demo; in real app it tracks changes
      });
      return;
    }
    _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final booking = BookingModel.fromMap(change.doc.data()!);
          if (booking.status == 'accepted') {
            onNotify('Booking Accepted!', 'Your car wash has been scheduled.');
          } else if (booking.status == 'completed') {
            onNotify('Car Ready!', 'Your car wash is complete. You earned 1 loyalty point!');
          }
        }
      }
    });
  }
}
