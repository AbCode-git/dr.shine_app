class BookingModel {
  final String id;
  final String? tenantId; // Multi-tenancy support
  final String userId;
  final String vehicleId;
  final String serviceId;
  final String
      status; // pending, accepted, washing, ready, completed, cancelled
  final DateTime bookingDate; // Today or Tomorrow
  final DateTime createdAt;
  final double price;
  final double? mileage;

  // New fields for car wash tracking
  final String? customerPhone; // Required for walk-in customers
  final String? carBrand; // e.g., Toyota, Honda
  final String? carModel; // e.g., Corolla, Civic
  final String? plateNumber; // License plate
  final String? washerStaffId; // ID of staff who washed the car
  final String? washerStaffName; // Name of staff for quick display
  final DateTime? completedAt; // When wash was completed

  BookingModel({
    required this.id,
    this.tenantId,
    required this.userId,
    required this.vehicleId,
    required this.serviceId,
    required this.status,
    required this.bookingDate,
    required this.createdAt,
    required this.price,
    this.mileage,
    this.customerPhone,
    this.carBrand,
    this.carModel,
    this.plateNumber,
    this.washerStaffId,
    this.washerStaffName,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'userId': userId,
      'vehicleId': vehicleId,
      'serviceId': serviceId,
      'status': status,
      'bookingDate': bookingDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'price': price,
      'mileage': mileage,
      'customerPhone': customerPhone,
      'carBrand': carBrand,
      'carModel': carModel,
      'plateNumber': plateNumber,
      'washerStaffId': washerStaffId,
      'washerStaffName': washerStaffName,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      tenantId: map['tenant_id'],
      userId: map['userId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      status: map['status'] ?? 'pending',
      bookingDate: DateTime.parse(map['bookingDate']),
      createdAt: DateTime.parse(map['createdAt']),
      price: (map['price'] as num).toDouble(),
      mileage:
          map['mileage'] != null ? (map['mileage'] as num).toDouble() : null,
      customerPhone: map['customerPhone'],
      carBrand: map['carBrand'],
      carModel: map['carModel'],
      plateNumber: map['plateNumber'],
      washerStaffId: map['washerStaffId'],
      washerStaffName: map['washerStaffName'],
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }

  // Helper method to create a copy with updated fields
  BookingModel copyWith({
    String? id,
    String? tenantId,
    String? userId,
    String? vehicleId,
    String? serviceId,
    String? status,
    DateTime? bookingDate,
    DateTime? createdAt,
    double? price,
    double? mileage,
    String? customerPhone,
    String? carBrand,
    String? carModel,
    String? plateNumber,
    String? washerStaffId,
    String? washerStaffName,
    DateTime? completedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceId: serviceId ?? this.serviceId,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      createdAt: createdAt ?? this.createdAt,
      price: price ?? this.price,
      mileage: mileage ?? this.mileage,
      customerPhone: customerPhone ?? this.customerPhone,
      carBrand: carBrand ?? this.carBrand,
      carModel: carModel ?? this.carModel,
      plateNumber: plateNumber ?? this.plateNumber,
      washerStaffId: washerStaffId ?? this.washerStaffId,
      washerStaffName: washerStaffName ?? this.washerStaffName,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
