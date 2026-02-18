class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? icon;
  final Map<String, double> inventoryRequirements;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.icon,
    this.inventoryRequirements = const {},
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      icon: map['icon'],
      inventoryRequirements:
          Map<String, double>.from(map['inventory_requirements'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'icon': icon,
      'inventory_requirements': inventoryRequirements,
    };
  }
}

// Sample data for MVP
final List<ServiceModel> defaultServices = [
  ServiceModel(
    id: 'exterior',
    name: 'Exterior Wash',
    description: 'Thorough outside cleaning including wheels and tires.',
    price: 150.0,
    inventoryRequirements: {'soap': 1.0},
  ),
  ServiceModel(
    id: 'interior',
    name: 'Interior Cleaning',
    description: 'Vacuuming, dashboard wiping, and glass cleaning.',
    price: 200.0,
    inventoryRequirements: {'soap': 0.5},
  ),
  ServiceModel(
    id: 'full',
    name: 'Full Wash',
    description: 'Complete exterior and interior care package.',
    price: 300.0,
    inventoryRequirements: {'soap': 2.0, 'wax': 0.5},
  ),
  ServiceModel(
    id: 'oil_standard',
    name: 'Oil Change (Standard)',
    description: 'Conventional oil change with multi-point inspection.',
    price: 3500.0,
    inventoryRequirements: {'5W-30': 4.5, 'filter': 1.0},
  ),
  ServiceModel(
    id: 'oil_synthetic',
    name: 'Oil Change (Synthetic)',
    description: 'Full synthetic oil for maximum engine protection.',
    price: 6500.0,
    inventoryRequirements: {'5W-30': 4.5, 'filter': 1.0},
  ),
];
