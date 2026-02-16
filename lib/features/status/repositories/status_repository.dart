import 'package:dr_shine_app/features/status/providers/status_provider.dart';

abstract class IStatusRepository {
  Stream<BusyStatus> getStatusStream();
  Future<void> updateStatus(BusyStatus status);
}
