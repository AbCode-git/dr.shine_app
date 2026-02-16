import 'package:dr_shine_app/features/inventory/models/inventory_item_model.dart';

abstract class IInventoryRepository {
  Stream<List<InventoryItem>> getInventoryStream();
  Future<void> updateStock(String itemId, double newQuantity);
  Future<void> saveInventoryItem(InventoryItem item);
}
