import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_shine_app/features/inventory/models/inventory_item_model.dart';
import 'package:dr_shine_app/bootstrap.dart';

class InventoryProvider extends ChangeNotifier {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  final List<InventoryItem> _items = [];
  bool _isLoading = false;
  StreamController<List<InventoryItem>>? _mockStreamController;

  InventoryProvider() {
    if (!isFirebaseInitialized) {
      _items.addAll([
        InventoryItem(
          id: 'i1',
          name: 'Premium Car Soap',
          category: InventoryCategory.carWash,
          currentStock: 45.5,
          minStockLevel: 10.0,
          reorderLevel: 20.0,
          unit: 'Liters',
          costPerUnit: 120.0,
          supplier: 'ShineSupplies Co.',
        ),
        InventoryItem(
          id: 'i2',
          name: 'Hydro-Wax Polish',
          category: InventoryCategory.carWash,
          currentStock: 8.2,
          minStockLevel: 5.0,
          reorderLevel: 10.0,
          unit: 'Liters',
          costPerUnit: 450.0,
          supplier: 'GlossMax',
        ),
        InventoryItem(
          id: 'i3',
          name: 'Synthetix 5W-30',
          category: InventoryCategory.oilChange,
          currentStock: 120.0,
          minStockLevel: 30.0,
          reorderLevel: 50.0,
          unit: 'Liters',
          costPerUnit: 350.0,
          viscosityGrade: '5W-30',
          brand: 'Synthetix',
        ),
        InventoryItem(
          id: 'i4',
          name: 'Oil Filter (Standard)',
          category: InventoryCategory.oilChange,
          currentStock: 15.0,
          minStockLevel: 10.0,
          reorderLevel: 25.0,
          unit: 'Pieces',
          costPerUnit: 800.0,
        ),
      ]);
    }
  }

  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;

  Stream<List<InventoryItem>> getInventoryStream() {
    if (!isFirebaseInitialized) {
      _mockStreamController ??= StreamController<List<InventoryItem>>.broadcast();
      Future.delayed(Duration.zero, () {
        _mockStreamController?.add(List.from(_items));
      });
      return _mockStreamController!.stream;
    }
    return _firestore
        .collection('inventory')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data()))
            .toList());
  }

  Future<void> deductStock(Map<String, double> requirements) async {
    for (var entry in requirements.entries) {
      final itemId = entry.key;
      final amount = entry.value;

      if (!isFirebaseInitialized) {
        final index = _items.indexWhere((i) => i.id == itemId || i.name.toLowerCase().contains(itemId.toLowerCase()));
        if (index != -1) {
          _items[index] = _items[index].copyWith(
            currentStock: _items[index].currentStock - amount,
          );
        }
      } else {
        await _firestore.collection('inventory').doc(itemId).update({
          'currentStock': FieldValue.increment(-amount),
        });
      }
    }
    _mockStreamController?.add(List.from(_items));
    notifyListeners();
  }

  Future<void> restockItem(String id, double amount) async {
    if (!isFirebaseInitialized) {
      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(
          currentStock: _items[index].currentStock + amount,
          lastRestocked: DateTime.now(),
        );
      }
    } else {
      await _firestore.collection('inventory').doc(id).update({
        'currentStock': FieldValue.increment(amount),
        'lastRestocked': DateTime.now().toIso8601String(),
      });
    }
    _mockStreamController?.add(List.from(_items));
    notifyListeners();
  }

  @override
  void dispose() {
    _mockStreamController?.close();
    super.dispose();
  }
}
