class TenantModel {
  final String id;
  final String name;
  final DateTime createdAt;

  TenantModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TenantModel.fromMap(Map<String, dynamic> map) {
    return TenantModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}
