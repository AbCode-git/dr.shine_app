import 'package:dr_shine_app/features/auth/models/user_model.dart';

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
}
