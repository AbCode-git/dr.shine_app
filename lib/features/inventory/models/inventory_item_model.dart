enum InventoryCategory {
  carWash,
  oilChange,
  tools,
  other
}

class InventoryItem {
  final String id;
  final String name;
  final InventoryCategory category;
  final double currentStock;
  final double minStockLevel;
  final double reorderLevel;
  final String unit; // liters, pieces, kg
  final double costPerUnit;
  final DateTime? lastRestocked;
  final String? supplier;
  // Oil specific
  final String? viscosityGrade; // e.g., 5W-30
  final String? brand;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minStockLevel,
    required this.reorderLevel,
    required this.unit,
    required this.costPerUnit,
    this.lastRestocked,
    this.supplier,
    this.viscosityGrade,
    this.brand,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'currentStock': currentStock,
      'minStockLevel': minStockLevel,
      'reorderLevel': reorderLevel,
      'unit': unit,
      'costPerUnit': costPerUnit,
      'lastRestocked': lastRestocked?.toIso8601String(),
      'supplier': supplier,
      'viscosityGrade': viscosityGrade,
      'brand': brand,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: InventoryCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => InventoryCategory.other,
      ),
      currentStock: (map['currentStock'] as num).toDouble(),
      minStockLevel: (map['minStockLevel'] as num).toDouble(),
      reorderLevel: (map['reorderLevel'] as num).toDouble(),
      unit: map['unit'] ?? 'units',
      costPerUnit: (map['costPerUnit'] as num).toDouble(),
      lastRestocked: map['lastRestocked'] != null ? DateTime.parse(map['lastRestocked']) : null,
      supplier: map['supplier'],
      viscosityGrade: map['viscosityGrade'],
      brand: map['brand'],
    );
  }

  bool get isLowStock => currentStock <= minStockLevel;
  bool get needsReorder => currentStock <= reorderLevel;

  InventoryItem copyWith({
    double? currentStock,
    DateTime? lastRestocked,
    double? costPerUnit,
  }) {
    return InventoryItem(
      id: id,
      name: name,
      category: category,
      currentStock: currentStock ?? this.currentStock,
      minStockLevel: minStockLevel,
      reorderLevel: reorderLevel,
      unit: unit,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      lastRestocked: lastRestocked ?? this.lastRestocked,
      supplier: supplier,
      viscosityGrade: viscosityGrade,
      brand: brand,
    );
  }
}
