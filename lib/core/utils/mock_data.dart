import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/vehicle/models/vehicle_model.dart';

class MockData {
  static final adminUser = UserModel(
    id: 'admin_123',
    phoneNumber: '+251911223344',
    displayName: 'Abebe (Admin)',
    role: 'admin',
    pin: '1111',
    createdAt: DateTime.now(),
  );

  static final superAdminUser = UserModel(
    id: 'super_admin_000',
    phoneNumber: '+251911223300',
    displayName: 'Manager (Super Admin)',
    role: 'super_admin',
    pin: '1111',
    createdAt: DateTime.now(),
  );

  static final customerUser = UserModel(
    id: 'customer_456',
    phoneNumber: '+251988776655',
    displayName: 'Kebe-de',
    role: 'customer',
    pin: '1111',
    loyaltyPoints: 3,
    createdAt: DateTime.now(),
  );

  static final newCustomerUser = UserModel(
    id: 'new_customer_789',
    phoneNumber: '+251977665544',
    displayName: 'New User',
    role: 'customer',
    pin: null, // No PIN yet
    createdAt: DateTime.now(),
  );

  static final vehicles = [
    VehicleModel(
      id: 'v1',
      ownerId: 'customer_456',
      plateNumber: 'AA-12345',
      type: 'Sedan',
      nickname: 'Work Commuter',
      color: 'Silver',
    ),
    VehicleModel(
      id: 'v2',
      ownerId: 'customer_456',
      plateNumber: 'ETH-9876',
      type: 'Compact',
      nickname: 'Daily Driver',
      color: 'Blue',
    ),
  ];
}
