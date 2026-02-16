import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dr_shine_app/features/status/repositories/status_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

enum BusyStatus { notBusy, busy, veryBusy }

class StatusProvider extends ChangeNotifier {
  final IStatusRepository _repository;

  BusyStatus _currentStatus = BusyStatus.notBusy;
  StreamSubscription? _statusSubscription;

  BusyStatus get currentStatus => _currentStatus;

  StatusProvider(this._repository) {
    _listenToStatus();
  }

  void _listenToStatus() {
    _statusSubscription = _repository.getStatusStream().listen(
      (status) {
        _currentStatus = status;
        notifyListeners();
      },
      onError: (e) => LoggerService.error('Status stream error in provider', e),
    );
  }

  // Update status (Admin only)
  Future<void> updateStatus(BusyStatus status) async {
    try {
      await _repository.updateStatus(status);
    } catch (e) {
      LoggerService.error('Failed to update status in provider', e);
      rethrow;
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
}
