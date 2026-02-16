import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_shine_app/features/status/providers/status_provider.dart';
import 'package:dr_shine_app/features/status/repositories/status_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';
import 'package:dr_shine_app/core/error/app_exceptions.dart';

class FirebaseStatusRepository implements IStatusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<BusyStatus> getStatusStream() {
    return _firestore
        .collection('status')
        .doc('current')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return BusyStatus.notBusy;
      final statusStr = doc.data()?['value'] ?? 'notBusy';
      return _parseStatus(statusStr);
    }).handleError((e) {
      LoggerService.error('Status stream error', e);
      throw DatabaseException('Failed to sync status');
    });
  }

  @override
  Future<void> updateStatus(BusyStatus status) async {
    try {
      await _firestore
          .collection('status')
          .doc('current')
          .set({'value': _statusToString(status)});
    } catch (e) {
      LoggerService.error('Failed to update status', e);
      throw DatabaseException('Status update failed');
    }
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
}
