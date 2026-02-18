import 'package:dr_shine_app/shared/models/service_model.dart';
// If ServiceModel is not found there, check features/admin/models/service_model.dart

class PackageModel {
  final String id;
  final String name;
  final String description; // e.g., "Save 50 ETB"
  final double price;
  final List<String> includedServiceIds;
  final String savings;
  final bool isActive;

  PackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.includedServiceIds,
    this.savings = '',
    this.isActive = true,
  });

  // Calculate total value of individual services
  double calculateTotalValue(List<ServiceModel> allServices) {
    double total = 0;
    for (var serviceId in includedServiceIds) {
      try {
        final service = allServices.firstWhere((s) => s.id == serviceId);
        total += service.price;
      } catch (e) {
        // Service might have been deleted
      }
    }
    return total;
  }

  double calculateSavings(List<ServiceModel> allServices) {
    return calculateTotalValue(allServices) - price;
  }

  PackageModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    List<String>? includedServiceIds,
    String? savings,
    bool? isActive,
  }) {
    return PackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      includedServiceIds: includedServiceIds ?? this.includedServiceIds,
      savings: savings ?? this.savings,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'included_service_ids': includedServiceIds,
      'savings': savings,
      'is_active': isActive,
    };
  }

  factory PackageModel.fromMap(Map<String, dynamic> map) {
    return PackageModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      includedServiceIds: List<String>.from(map['included_service_ids'] ?? []),
      savings: map['savings'] ?? '',
      isActive: map['is_active'] ?? true,
    );
  }
}
