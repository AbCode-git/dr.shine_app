class ServiceRecord {
  final String id;
  final String vehicleId;
  final String serviceType; // car_wash, oil_change
  final DateTime completedDate;
  final double mileage;
  final DateTime nextServiceDue;
  final Map<String, double> itemsUsed; // itemId -> amount
  final double totalCost;
  final String performedBy;

  ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.completedDate,
    required this.mileage,
    required this.nextServiceDue,
    required this.itemsUsed,
    required this.totalCost,
    required this.performedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'serviceType': serviceType,
      'completedDate': completedDate.toIso8601String(),
      'mileage': mileage,
      'nextServiceDue': nextServiceDue.toIso8601String(),
      'itemsUsed': itemsUsed,
      'totalCost': totalCost,
      'performedBy': performedBy,
    };
  }

  factory ServiceRecord.fromMap(Map<String, dynamic> map) {
    return ServiceRecord(
      id: map['id'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      serviceType: map['serviceType'] ?? '',
      completedDate: DateTime.parse(map['completedDate']),
      mileage: (map['mileage'] as num).toDouble(),
      nextServiceDue: DateTime.parse(map['nextServiceDue']),
      itemsUsed: Map<String, double>.from(map['itemsUsed'] ?? {}),
      totalCost: (map['totalCost'] as num).toDouble(),
      performedBy: map['performedBy'] ?? '',
    );
  }
}
