import 'dart:async';
import 'package:dr_shine_app/features/status/providers/status_provider.dart';
import 'package:dr_shine_app/features/status/repositories/status_repository.dart';

class MockStatusRepository implements IStatusRepository {
  BusyStatus _currentStatus = BusyStatus.notBusy;
  final _streamController = StreamController<BusyStatus>.broadcast();

  @override
  Stream<BusyStatus> getStatusStream() {
    _streamController.add(_currentStatus);
    return _streamController.stream;
  }

  @override
  Future<void> updateStatus(BusyStatus status) async {
    _currentStatus = status;
    _streamController.add(_currentStatus);
  }
}
