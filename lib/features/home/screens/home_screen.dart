import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/features/auth/screens/phone_input_screen.dart';
import 'package:dr_shine_app/features/admin/screens/admin_dashboard_screen.dart';
import 'package:dr_shine_app/features/admin/screens/super_admin_dashboard_screen.dart';
import 'package:dr_shine_app/features/auth/screens/pin_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('HomeScreen: Building...');
    final authProvider = context.watch<AuthProvider>();
    debugPrint(
        'HomeScreen: authProvider.isInitialized = ${authProvider.isInitialized}');
    debugPrint(
        'HomeScreen: authProvider.isAuthenticated = ${authProvider.isAuthenticated}');

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

    // 3. Route based on role (admin/super_admin only)
    if (user?.role == 'superadmin') {
      debugPrint('HomeScreen: Routing to SuperAdminDashboard');
      return const SuperAdminDashboardScreen();
    } else if (['admin', 'staff'].contains(user?.role)) {
      debugPrint('HomeScreen: Routing to AdminDashboard (Role: ${user?.role})');
      return const AdminDashboardScreen();
    } else {
      debugPrint('HomeScreen: Access Denied (Role: ${user?.role})');
      // No customer access - show error message
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('This app is for staff use only.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => authProvider.logout(),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
