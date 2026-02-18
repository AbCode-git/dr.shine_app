class BookingModel {
  final String id;
  final String? tenantId; // Multi-tenancy support
  final String userId;
  final String vehicleId;
  final String? serviceId; // Nullable if packageId is present
  final String? packageId; // New: Support for packages
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
  final String? paymentMethod; // New: cash, telebirr, cbe

  BookingModel({
    required this.id,
    this.tenantId,
    required this.userId,
    required this.vehicleId,
    this.serviceId,
    this.packageId,
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
    this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'userId': userId,
      'vehicleId': vehicleId,
      'serviceId': serviceId,
      'packageId': packageId,
      'status': status,
      'booking_date': bookingDate.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'price': price,
      'mileage': mileage,
      'customer_phone': customerPhone,
      'car_brand': carBrand,
      'car_model': carModel,
      'plate_number': plateNumber,
      'washerStaffId': washerStaffId,
      'washerStaffName': washerStaffName,
      'payment_method': paymentMethod,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      tenantId: map['tenant_id'],
      userId: map['userId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      serviceId: map['serviceId'],
      packageId: map['packageId'],
      status: map['status'] ?? 'pending',
      bookingDate: DateTime.parse(map['booking_date'] ?? map['bookingDate']),
      createdAt: DateTime.parse(map['created_at'] ?? map['createdAt']),
      price: (map['price'] as num).toDouble(),
      mileage:
          map['mileage'] != null ? (map['mileage'] as num).toDouble() : null,
      customerPhone: map['customer_phone'] ?? map['customerPhone'],
      carBrand: map['car_brand'] ?? map['carBrand'],
      carModel: map['car_model'] ?? map['carModel'],
      plateNumber: map['plate_number'] ?? map['plateNumber'],
      washerStaffId: map['washerStaffId'],
      washerStaffName: map['washerStaffName'],
      paymentMethod: map['payment_method'],
    );
  }

  // Helper method to create a copy with updated fields
  BookingModel copyWith({
    String? id,
    String? tenantId,
    String? userId,
    String? vehicleId,
    String? serviceId,
    String? packageId,
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
    String? paymentMethod,
  }) {
    return BookingModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceId: serviceId ?? this.serviceId,
      packageId: packageId ?? this.packageId,
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
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
