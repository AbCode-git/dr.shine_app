class BookingModel {
  final String id;
  final String userId;
  final String vehicleId;
  final String serviceId;
  final String status; // pending, accepted, completed, cancelled
  final DateTime bookingDate; // Today or Tomorrow
  final DateTime createdAt;
  final double price;
  final double? mileage;

  BookingModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.serviceId,
    required this.status,
    required this.bookingDate,
    required this.createdAt,
    required this.price,
    this.mileage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'serviceId': serviceId,
      'status': status,
      'bookingDate': bookingDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'price': price,
      'mileage': mileage,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      status: map['status'] ?? 'pending',
      bookingDate: DateTime.parse(map['bookingDate']),
      createdAt: DateTime.parse(map['createdAt']),
      price: (map['price'] as num).toDouble(),
      mileage: map['mileage'] != null ? (map['mileage'] as num).toDouble() : null,
    );
  }
}
