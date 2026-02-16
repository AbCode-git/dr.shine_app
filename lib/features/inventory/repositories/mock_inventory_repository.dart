import 'dart:async';
import 'package:dr_shine_app/features/inventory/models/inventory_item_model.dart';
import 'package:dr_shine_app/features/inventory/repositories/inventory_repository.dart';

class MockInventoryRepository implements IInventoryRepository {
  final List<InventoryItem> _items = [
    InventoryItem(
        id: 'item1',
        name: 'Premium Wax',
        currentStock: 45.5,
        unit: 'Liters',
        category: InventoryCategory.carWash,
        minStockLevel: 10,
        reorderLevel: 20,
        costPerUnit: 15.0),
    InventoryItem(
        id: 'item2',
        name: 'Engine Oil 5W-30',
        currentStock: 12.0,
        unit: 'Gallons',
        category: InventoryCategory.oilChange,
        minStockLevel: 5,
        reorderLevel: 10,
        viscosityGrade: '5W-30',
        costPerUnit: 25.0),
  ];

  final _streamController = StreamController<List<InventoryItem>>.broadcast();

  @override
  Stream<List<InventoryItem>> getInventoryStream() {
    _emit();
    return _streamController.stream;
  }

  @override
  Future<void> updateStock(String itemId, double newQuantity) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(currentStock: newQuantity);
      _emit();
    }
  }

  @override
  Future<void> saveInventoryItem(InventoryItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
    } else {
      _items.add(item);
    }
    _emit();
  }

  void _emit() => _streamController.add(List.from(_items));
}
