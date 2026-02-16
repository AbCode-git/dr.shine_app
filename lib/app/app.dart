import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/features/booking/providers/booking_provider.dart';
import 'package:dr_shine_app/features/status/providers/status_provider.dart';
import 'package:dr_shine_app/features/auth/providers/user_provider.dart';
import 'package:dr_shine_app/features/inventory/providers/inventory_provider.dart';
import 'package:dr_shine_app/app/app_routes.dart';
import 'package:dr_shine_app/app/app_theme.dart';
import 'package:dr_shine_app/core/services/service_locator.dart';

class DrShineApp extends StatelessWidget {
  const DrShineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider(locator.authRepository)),
        ChangeNotifierProvider(
            create: (_) => BookingProvider(locator.bookingRepository)),
        ChangeNotifierProvider(
            create: (_) => StatusProvider(locator.statusRepository)),
        ChangeNotifierProvider(
            create: (_) => UserProvider(locator.userRepository)),
        ChangeNotifierProvider(
            create: (_) => InventoryProvider(locator.inventoryRepository)),
      ],
      child: MaterialApp(
        title: 'Dr. Shine Car Wash',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
