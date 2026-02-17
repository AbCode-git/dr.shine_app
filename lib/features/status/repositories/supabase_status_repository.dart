import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dr_shine_app/features/status/providers/status_provider.dart';
import 'package:dr_shine_app/features/status/repositories/status_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class SupabaseStatusRepository implements IStatusRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Stream<BusyStatus> getStatusStream() {
    return _client.from('status').stream(primaryKey: ['id']).map((data) {
      if (data.isEmpty) return BusyStatus.notBusy;
      final statusStr = data.first['status'] as String;
      return BusyStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => BusyStatus.notBusy,
      );
    });
  }

  @override
  Future<void> updateStatus(BusyStatus status) async {
    try {
      // Logic assumes a single status row per tenant
      // We upsert based on a fixed ID or tenant_id if RLS handles it
      await _client.from('status').upsert({
        'id': 'current_status', // Placeholder ID
        'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      LoggerService.error('Supabase updateStatus failed', e);
      rethrow;
    }
  }
}
