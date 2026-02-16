import 'package:dr_shine_app/features/booking/repositories/booking_repository.dart';
import 'package:dr_shine_app/features/booking/repositories/mock_booking_repository.dart';
import 'package:dr_shine_app/features/booking/repositories/firebase_booking_repository.dart';

import 'package:dr_shine_app/features/auth/repositories/user_repository.dart';
import 'package:dr_shine_app/features/auth/repositories/mock_user_repository.dart';
import 'package:dr_shine_app/features/auth/repositories/firebase_user_repository.dart';

import 'package:dr_shine_app/features/inventory/repositories/inventory_repository.dart';
import 'package:dr_shine_app/features/inventory/repositories/mock_inventory_repository.dart';
import 'package:dr_shine_app/features/inventory/repositories/firebase_inventory_repository.dart';

import 'package:dr_shine_app/features/status/repositories/status_repository.dart';
import 'package:dr_shine_app/features/status/repositories/mock_status_repository.dart';
import 'package:dr_shine_app/features/status/repositories/firebase_status_repository.dart';

import 'package:dr_shine_app/features/auth/repositories/auth_repository.dart';
import 'package:dr_shine_app/features/auth/repositories/mock_auth_repository.dart';
import 'package:dr_shine_app/features/auth/repositories/firebase_auth_repository.dart';

import 'package:dr_shine_app/bootstrap.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final IBookingRepository bookingRepository;
  late final IUserRepository userRepository;

  late final IInventoryRepository inventoryRepository;
  late final IStatusRepository statusRepository;
  late final IAuthRepository authRepository;

  void setup() {
    if (isFirebaseInitialized) {
      bookingRepository = FirebaseBookingRepository();
      userRepository = FirebaseUserRepository();

      inventoryRepository = FirebaseInventoryRepository();
      statusRepository = FirebaseStatusRepository();
      authRepository = FirebaseAuthRepository();
    } else {
      bookingRepository = MockBookingRepository();
      userRepository = MockUserRepository();

      inventoryRepository = MockInventoryRepository();
      statusRepository = MockStatusRepository();
      authRepository = MockAuthRepository();
    }
  }
}

final locator = ServiceLocator();
