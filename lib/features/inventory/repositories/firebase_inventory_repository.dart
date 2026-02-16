import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_shine_app/features/inventory/models/inventory_item_model.dart';
import 'package:dr_shine_app/features/inventory/repositories/inventory_repository.dart';
import 'package:dr_shine_app/core/error/app_exceptions.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class FirebaseInventoryRepository implements IInventoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<InventoryItem>> getInventoryStream() {
    return _firestore
        .collection('inventory')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data()))
            .toList())
        .handleError((e) {
      LoggerService.error('Inventory stream error', e);
      throw DatabaseException('Failed to sync inventory');
    });
  }

  @override
  Future<void> updateStock(String itemId, double newQuantity) async {
    try {
      await _firestore
          .collection('inventory')
          .doc(itemId)
          .update({'currentStock': newQuantity});
    } catch (e) {
      LoggerService.error('Failed to update stock', e);
      throw DatabaseException('Stock update failed');
    }
  }

  @override
  Future<void> saveInventoryItem(InventoryItem item) async {
    try {
      await _firestore.collection('inventory').doc(item.id).set(item.toMap());
    } catch (e) {
      LoggerService.error('Failed to save inventory item', e);
      throw DatabaseException('Failed to save item');
    }
  }
}
