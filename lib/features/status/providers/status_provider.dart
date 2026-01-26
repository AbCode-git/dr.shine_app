import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_shine_app/bootstrap.dart';

enum BusyStatus { notBusy, busy, veryBusy }

class StatusProvider extends ChangeNotifier {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  
  BusyStatus _currentStatus = BusyStatus.notBusy;

  BusyStatus get currentStatus => _currentStatus;

  StatusProvider() {
    _listenToStatus();
  }

  void _listenToStatus() {
    if (!isFirebaseInitialized) return;
    _firestore.collection('status').doc('current').snapshots().listen((doc) {
      if (doc.exists) {
        final statusStr = doc.data()?['value'] ?? 'notBusy';
        _currentStatus = _parseStatus(statusStr);
        notifyListeners();
      }
    });
  }

  BusyStatus _parseStatus(String status) {
    switch (status) {
      case 'busy':
        return BusyStatus.busy;
      case 'veryBusy':
        return BusyStatus.veryBusy;
      default:
        return BusyStatus.notBusy;
    }
  }

  String _statusToString(BusyStatus status) {
    switch (status) {
      case BusyStatus.busy:
        return 'busy';
      case BusyStatus.veryBusy:
        return 'veryBusy';
      default:
        return 'notBusy';
    }
  }

  // Update status (Admin only)
  Future<void> updateStatus(BusyStatus status) async {
    if (!isFirebaseInitialized) {
      _currentStatus = status;
      notifyListeners();
      return;
    }
    await _firestore.collection('status').doc('current').set({'value': _statusToString(status)});
  }
}
