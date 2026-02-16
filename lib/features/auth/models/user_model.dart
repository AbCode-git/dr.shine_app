class UserModel {
  final String id;
  final String phoneNumber;
  final String? displayName;
  final String role; // 'customer' or 'admin'
  final String? pin; // 4-digit security code
  final int loyaltyPoints;
  final bool isOnDuty;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.displayName,
    required this.role,
    this.pin,
    this.loyaltyPoints = 0,
    this.isOnDuty = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'role': role,
      'pin': pin,
      'loyaltyPoints': loyaltyPoints,
      'isOnDuty': isOnDuty,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      displayName: map['displayName'],
      role: map['role'] ?? 'customer',
      pin: map['pin'],
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
      isOnDuty: map['isOnDuty'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? displayName,
    String? phoneNumber,
    bool? isOnDuty,
    int? loyaltyPoints,
    String? pin,
  }) {
    return UserModel(
      id: id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      role: role,
      pin: pin ?? this.pin,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      isOnDuty: isOnDuty ?? this.isOnDuty,
      createdAt: createdAt,
    );
  }
}
