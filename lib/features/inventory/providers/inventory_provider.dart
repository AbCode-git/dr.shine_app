import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dr_shine_app/features/inventory/models/inventory_item_model.dart';
import 'package:dr_shine_app/features/inventory/repositories/inventory_repository.dart';
import 'package:dr_shine_app/core/services/logger_service.dart';

class InventoryProvider extends ChangeNotifier {
  final IInventoryRepository _repository;

  final List<InventoryItem> _items = [];
  final bool _isLoading = false;
  StreamSubscription? _inventorySubscription;

  InventoryProvider(this._repository) {
    _init();
  }

  void _init() {
    _inventorySubscription = _repository.getInventoryStream().listen(
      (list) {
        _items.clear();
        _items.addAll(list);
        notifyListeners();
      },
      onError: (e) =>
          LoggerService.error('Inventory stream error in provider', e),
    );
  }

  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;

  Stream<List<InventoryItem>> getInventoryStream() {
    return _repository.getInventoryStream();
  }

  Future<void> deductStock(Map<String, double> requirements) async {
    try {
      for (var entry in requirements.entries) {
        final itemId = entry.key;
        final amount = entry.value;

        // Find item to get current stock
        final item = _items.firstWhere((i) =>
            i.id == itemId ||
            i.name.toLowerCase().contains(itemId.toLowerCase()));
        await _repository.updateStock(item.id, item.currentStock - amount);
      }
    } catch (e) {
      LoggerService.error('Failed to deduct stock', e);
      rethrow;
    }
  }

  Future<void> restockItem(String id, double amount) async {
    try {
      final item = _items.firstWhere((i) => i.id == id);
      await _repository.updateStock(id, item.currentStock + amount);
    } catch (e) {
      LoggerService.error('Restock failed', e);
      rethrow;
    }
  }

  Future<void> addItem(InventoryItem item) async {
    try {
      await _repository.saveInventoryItem(item);
    } catch (e) {
      LoggerService.error('Add item failed', e);
      rethrow;
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    try {
      await _repository.saveInventoryItem(item);
    } catch (e) {
      LoggerService.error('Update item failed', e);
      rethrow;
    }
  }

  @override
  void dispose() {
    _inventorySubscription?.cancel();
    super.dispose();
  }
}
