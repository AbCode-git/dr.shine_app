import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/features/auth/screens/phone_input_screen.dart';
import 'package:dr_shine_app/features/home/screens/customer_home_screen.dart';
import 'package:dr_shine_app/features/admin/screens/admin_dashboard_screen.dart';
import 'package:dr_shine_app/features/admin/screens/super_admin_dashboard_screen.dart';
import 'package:dr_shine_app/features/auth/screens/pin_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // 0. Show loading during initialization
    if (!authProvider.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 1. If not authenticated, show login
    if (!authProvider.isAuthenticated) {
      return const PhoneInputScreen();
    }

    // 2. If authenticated but no PIN set, go to PIN setup
    final user = authProvider.currentUser;
    if (user != null && user.pin == null) {
      return const PinSetupScreen();
    }

    // 3. Route based on role
    if (user?.role == 'super_admin') {
      return const SuperAdminDashboardScreen();
    } else if (user?.role == 'admin') {
      return const AdminDashboardScreen();
    } else {
      return const CustomerHomeScreen();
    }
  }
}
