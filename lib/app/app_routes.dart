import 'package:flutter/material.dart';
import 'package:dr_shine_app/features/home/screens/home_screen.dart';
import 'package:dr_shine_app/features/auth/screens/phone_input_screen.dart';
import 'package:dr_shine_app/features/booking/screens/quick_entry_screen.dart';
import 'package:dr_shine_app/features/admin/screens/admin_dashboard_screen.dart';
import 'package:dr_shine_app/features/admin/screens/wash_reports_screen.dart';
import 'package:dr_shine_app/features/admin/screens/super_admin_dashboard_screen.dart';
import 'package:dr_shine_app/features/admin/screens/staff_list_screen.dart';
import 'package:dr_shine_app/features/admin/screens/service_management_screen.dart';
import 'package:dr_shine_app/features/admin/screens/package_management_screen.dart';
import 'package:dr_shine_app/features/admin/screens/branch_management_screen.dart';
import 'package:dr_shine_app/features/booking/screens/booking_details_screen.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/features/auth/screens/pin_setup_screen.dart';
import 'package:dr_shine_app/features/auth/screens/pin_login_screen.dart';
import 'package:dr_shine_app/features/auth/screens/profile_screen.dart';
import 'package:dr_shine_app/features/inventory/screens/inventory_list_screen.dart';
import 'package:dr_shine_app/features/inventory/screens/inventory_item_form_screen.dart';
import 'package:dr_shine_app/features/inventory/screens/inventory_analytics_screen.dart';
import 'package:dr_shine_app/features/inventory/models/inventory_item_model.dart';
import 'package:dr_shine_app/features/admin/screens/duty_roster_screen.dart';
import 'package:dr_shine_app/features/admin/screens/performance_analytics_screen.dart';
import 'package:dr_shine_app/features/admin/screens/app_config_screen.dart';
import 'package:dr_shine_app/features/admin/screens/loyalty_analytics_screen.dart';
import 'package:dr_shine_app/features/auth/screens/register_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String auth = '/auth';
  static const String bookingDetails = '/booking-details';
  static const String admin = '/admin';
  static const String superAdmin = '/super-admin';
  static const String staffManagement = '/staff-management';
  static const String servicePricing = '/service-pricing';
  static const String packagePricing = '/package-pricing';
  static const String pinSetup = '/pin-setup';
  static const String pinLogin = '/pin-login';
  static const String profile = '/profile';
  static const String inventory = '/inventory';
  static const String inventoryForm = '/inventory-form';
  static const String inventoryAnalytics = '/inventory-analytics';
  static const String dutyRoster = '/duty-roster';
  static const String performanceAnalytics = '/performance-analytics';
  static const String appConfig = '/app-config';
  static const String loyaltyAnalytics = '/loyalty-analytics';
  static const String quickEntry = '/quick-entry';
  static const String washReports = '/wash-reports';
  static const String branchManagement = '/branch-management';
  static const String register = '/register';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case auth:
        return MaterialPageRoute(builder: (_) => const PhoneInputScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case bookingDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BookingDetailsScreen(
            booking: args['booking'] as BookingModel,
            serviceName: args['serviceName'] as String,
            vehicleInfo: args['vehicleInfo'] as String,
          ),
        );
      case admin:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case superAdmin:
        return MaterialPageRoute(
            builder: (_) => const SuperAdminDashboardScreen());
      case staffManagement:
        return MaterialPageRoute(builder: (_) => const StaffListScreen());
      case servicePricing:
        return MaterialPageRoute(
            builder: (_) => const ServiceManagementScreen());
      case packagePricing:
        return MaterialPageRoute(
            builder: (_) => const PackageManagementScreen());
      case pinSetup:
        return MaterialPageRoute(builder: (_) => const PinSetupScreen());
      case pinLogin:
        final phone = settings.arguments as String? ?? '';
        return MaterialPageRoute(
            builder: (_) => PinLoginScreen(phoneNumber: phone));
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case inventory:
        return MaterialPageRoute(builder: (_) => const InventoryListScreen());
      case inventoryForm:
        final item = settings.arguments as InventoryItem?;
        return MaterialPageRoute(
            builder: (_) => InventoryItemFormScreen(item: item));
      case inventoryAnalytics:
        return MaterialPageRoute(
            builder: (_) => const InventoryAnalyticsScreen());
      case dutyRoster:
        return MaterialPageRoute(builder: (_) => const DutyRosterScreen());
      case performanceAnalytics:
        return MaterialPageRoute(
            builder: (_) => const PerformanceAnalyticsScreen());
      case appConfig:
        return MaterialPageRoute(builder: (_) => const AppConfigScreen());
      case loyaltyAnalytics:
        return MaterialPageRoute(
            builder: (_) => const LoyaltyAnalyticsScreen());
      case quickEntry:
        return MaterialPageRoute(builder: (_) => const QuickEntryScreen());
      case washReports:
        return MaterialPageRoute(builder: (_) => const WashReportsScreen());
      case branchManagement:
        return MaterialPageRoute(
            builder: (_) => const BranchManagementScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
