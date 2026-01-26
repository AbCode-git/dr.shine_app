class VehicleModel {
  final String id;
  final String ownerId;
  final String plateNumber;
  final String type; // Sedan, SUV, Pickup, Van
  final String? nickname;
  final String? color;
  final double? lastOilChangeMileage;
  final double? currentMileage;
  final String? recommendedOilType;

  VehicleModel({
    required this.id,
    required this.ownerId,
    required this.plateNumber,
    required this.type,
    this.nickname,
    this.color,
    this.lastOilChangeMileage,
    this.currentMileage,
    this.recommendedOilType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'plateNumber': plateNumber,
      'type': type,
      'nickname': nickname,
      'color': color,
      'lastOilChangeMileage': lastOilChangeMileage,
      'currentMileage': currentMileage,
      'recommendedOilType': recommendedOilType,
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      plateNumber: map['plateNumber'] ?? '',
      type: map['type'] ?? 'Sedan',
      nickname: map['nickname'],
      color: map['color'],
      lastOilChangeMileage: map['lastOilChangeMileage'] != null ? (map['lastOilChangeMileage'] as num).toDouble() : null,
      currentMileage: map['currentMileage'] != null ? (map['currentMileage'] as num).toDouble() : null,
      recommendedOilType: map['recommendedOilType'],
    );
  }
}
