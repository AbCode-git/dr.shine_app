import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dr_shine_app/features/inventory/models/inventory_item_model.dart';
import 'package:dr_shine_app/features/inventory/repositories/inventory_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class SupabaseInventoryRepository implements IInventoryRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Stream<List<InventoryItem>> getInventoryStream() {
    return _client.from('inventory').stream(primaryKey: ['id']).map(
        (data) => data.map((json) => InventoryItem.fromMap(json)).toList());
  }

  @override
  Future<void> updateStock(String itemId, double newQuantity) async {
    try {
      await _client
          .from('inventory')
          .update({'currentStock': newQuantity}).eq('id', itemId);
    } catch (e) {
      LoggerService.error('Supabase updateStock failed', e);
      rethrow;
    }
  }

  @override
  Future<void> saveInventoryItem(InventoryItem item) async {
    try {
      await _client.from('inventory').upsert(item.toMap());
    } catch (e) {
      LoggerService.error('Supabase saveInventoryItem failed', e);
      rethrow;
    }
  }
}
