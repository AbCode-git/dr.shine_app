import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/booking/providers/booking_provider.dart';
import 'package:dr_shine_app/features/inventory/providers/inventory_provider.dart';
import 'package:dr_shine_app/features/inventory/models/inventory_item_model.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/app/app_routes.dart';

import 'package:dr_shine_app/core/widgets/responsive_layout.dart';

import 'package:dr_shine_app/features/admin/providers/service_provider.dart';
import 'package:dr_shine_app/features/admin/providers/package_provider.dart'; // Added Import
import 'package:dr_shine_app/features/admin/models/package_model.dart'; // Added Import
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final packageProvider =
        context.watch<PackageProvider>(); // Added PackageProvider
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.currentUser?.role ?? 'customer';
    final isAdmin = role == 'admin' || role == 'superadmin';
    final isStaff = role == 'staff';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mekina Wash Pro Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: ResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Analytics Overview Hub
              if (isAdmin) ...[
                _buildAnalyticsOverview(bookingProvider),
                const SizedBox(height: 16),
              ],

              // Duty & Team Status
              _buildStaffSummary(bookingProvider),
              const SizedBox(height: 16),

              // Washer Performance Leaderboard
              _buildWasherPerformance(bookingProvider),
              const SizedBox(height: 16),

              // Operational Alerts
              _buildOperationalAlerts(inventoryProvider),
              const SizedBox(height: 16),

              // Primary Command CTAs
              _buildActionGrid(context, isAdmin: isAdmin, isStaff: isStaff),
              const SizedBox(height: 16),

              // Live Wash TrackerSection
              _buildLiveWashTracker(bookingProvider, serviceProvider,
                  packageProvider), // Pass provider
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsOverview(BookingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: "TODAY'S REVENUE",
                value: '${provider.totalRevenueToday.toStringAsFixed(0)} ETB',
                icon: Icons.account_balance_wallet_rounded,
              ),
              _buildStatItem(
                label: 'COMPLETED',
                value: provider.completedCountToday.toString(),
                icon: Icons.check_circle_rounded,
              ),
              _buildStatItem(
                label: 'ACTIVE',
                value: provider.activeWashesCount.toString(),
                icon: Icons.local_car_wash_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStaffSummary(BookingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TEAM SIZE',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.textTertiary,
                letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people_alt_rounded,
                  size: 18, color: AppColors.info),
              const SizedBox(width: 8),
              Text(
                '${provider.washerPerformanceToday.length} Workers',
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWasherPerformance(BookingProvider provider) {
    final performance = provider.washerPerformanceToday;
    if (performance.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WASHER PERFORMANCE (TODAY)',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: AppColors.textTertiary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: performance.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        entry.key[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value} WASHES',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context,
      {required bool isAdmin, required bool isStaff}) {
    // Determine available actions based on role
    final actions = <Widget>[];

    // 1. Quick Entry (Everyone)
    actions.add(_buildActionCard(
      context,
      label: 'Quick Entry',
      icon: Icons.bolt_rounded,
      color: AppColors.primary,
      onTap: () => Navigator.pushNamed(context, AppRoutes.quickEntry),
    ));

    // 2. Inventory (Admin & Staff)
    if (isAdmin || isStaff) {
      actions.add(_buildActionCard(
        context,
        label: 'Inventory',
        icon: Icons.layers_rounded,
        color: Colors.orangeAccent,
        onTap: () => Navigator.pushNamed(context, AppRoutes.inventory),
      ));
    }

    // 3. Admin Only Actions
    if (isAdmin) {
      actions.add(_buildActionCard(
        context,
        label: 'Staff',
        icon: Icons.badge_rounded,
        color: AppColors.info,
        onTap: () => Navigator.pushNamed(context, AppRoutes.staffManagement),
      ));

      actions.add(_buildActionCard(
        context,
        label: 'Reports',
        icon: Icons.bar_chart_rounded,
        color: AppColors.success,
        onTap: () => Navigator.pushNamed(context, AppRoutes.washReports),
      ));

      actions.add(_buildActionCard(
        context,
        label: 'Services',
        icon: Icons.diamond_rounded,
        color: Colors.blueAccent,
        onTap: () => Navigator.pushNamed(context, AppRoutes.servicePricing),
      ));

      actions.add(_buildActionCard(
        context,
        label: 'Packages',
        icon: Icons.card_giftcard_rounded,
        color: Colors.amber,
        onTap: () => Navigator.pushNamed(context, AppRoutes.packagePricing),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CORE OPERATIONS',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: AppColors.textTertiary),
        ),
        const SizedBox(height: 16),
        // Use a Wrap for dynamic number of items without forced rows
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: actions.map((widget) {
            // Calculate width based on screen size (handled by LayoutBuilder in parent usually,
            // but here we can just make them expand to fill space using SizedBox)
            // For simplicity in Wrap, we'll give them a fixed min-width or use LayoutBuilder
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 48 - 12) /
                  2, // 2 columns accounting for padding (20*2) + gap (12) roughly
              child: widget,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalAlerts(InventoryProvider provider) {
    return StreamBuilder<List<InventoryItem>>(
      stream: provider.getInventoryStream(),
      builder: (context, snapshot) {
        final lowStock =
            (snapshot.data ?? []).where((i) => i.isLowStock).toList();
        if (lowStock.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.redAccent, size: 20),
              const SizedBox(width: 12),
              Text(
                'ALERT: ${lowStock.length} SUPPLIES LOW',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.redAccent),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.inventory),
                child: const Text('MANAGE',
                    style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveWashTracker(BookingProvider bookingProvider,
      ServiceProvider serviceProvider, PackageProvider packageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'LIVE WASH TRACKER',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: AppColors.textTertiary),
            ),
            Spacer(),
            Icon(Icons.live_tv_rounded, size: 14, color: Colors.redAccent),
            SizedBox(width: 4),
            Text('LIVE',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            final washes = bookingProvider.bookings;
            if (washes.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text('Standing by for new jobs...',
                      style: TextStyle(color: AppColors.textTertiary)),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: washes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final wash = washes[index];
                return _buildWashCard(context, wash, bookingProvider,
                    serviceProvider, packageProvider);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildWashCard(
      BuildContext context,
      BookingModel wash,
      BookingProvider bookingProvider,
      ServiceProvider serviceProvider,
      PackageProvider packageProvider) {
    // Resolve Service or Package Name
    String serviceName = 'Unknown Service';
    // Price is already on the booking, so we just need the name for display

    if (wash.serviceId != null) {
      final service = serviceProvider.services.firstWhere(
        (s) => s.id == wash.serviceId,
        orElse: () => ServiceModel(
          id: 'unknown',
          name: 'Unknown Service',
          description: '',
          price: 0,
        ),
      );
      serviceName = service.name;
    } else if (wash.packageId != null) {
      final pkg = packageProvider.packages.firstWhere(
        (p) => p.id == wash.packageId,
        orElse: () => PackageModel(
          id: 'unknown',
          name: 'Unknown Package',
          description: '',
          price: 0,
          includedServiceIds: [],
        ),
      );
      serviceName = pkg.name; // Use package name instead
    }

    final statusColor = _getStatusColor(wash.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    wash.plateNumber?.characters.take(3).toString() ?? 'WSH',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${wash.plateNumber ?? "No Plate"} • ${wash.carBrand ?? "Unknown"}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      Text(
                        '$serviceName • Assigned: ${wash.washerStaffName ?? "General"}',
                        style: const TextStyle(
                            color: AppColors.textTertiary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(wash.status, statusColor),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildWashActions(context, wash, bookingProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildWashActions(
      BuildContext context, BookingModel wash, BookingProvider provider) {
    Future<void> handleUpdate(Future<void> action, String successMsg) async {
      try {
        await action;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMsg),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    switch (wash.status) {
      case 'pending':
        return _buildLargeActionButton(
          label: 'ACCEPT JOB',
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
          onPressed: () => handleUpdate(
            provider.updateBookingStatus(wash.id, 'accepted'),
            'Job accepted!',
          ),
        );
      case 'accepted':
        return _buildLargeActionButton(
          label: 'START WASHING',
          icon: Icons.play_arrow_rounded,
          color: AppColors.primary,
          onPressed: () => handleUpdate(
            provider.updateBookingStatus(wash.id, 'washing'),
            'Wash started!',
          ),
        );
      case 'washing':
        return _buildLargeActionButton(
          label: 'MARK AS READY',
          icon: Icons.done_all_rounded,
          color: AppColors.info,
          onPressed: () => handleUpdate(
            provider.updateBookingStatus(wash.id, 'ready'),
            'Vehicle is ready for pickup!',
          ),
        );
      case 'ready':
        return _buildLargeActionButton(
          label: 'FINALIZE & RELEASE',
          icon: Icons.flag_rounded,
          color: AppColors.success,
          onPressed: () async {
            final paymentMethod = await _showPaymentSelection(context);
            if (paymentMethod != null) {
              handleUpdate(
                provider.completeWash(wash, paymentMethod: paymentMethod),
                'Wash finalized via ${paymentMethod.toUpperCase()}!',
              );
            }
          },
        );
      default:
        return const SizedBox(height: 8);
    }
  }

  Future<String?> _showPaymentSelection(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SELECT PAYMENT METHOD',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildPaymentOption(
              context,
              label: 'CASH',
              method: 'cash',
              icon: Icons.money_rounded,
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              context,
              label: 'TELEBIRR',
              method: 'telebirr',
              icon: Icons.phone_android_rounded,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              context,
              label: 'CBE',
              method: 'cbe',
              icon: Icons.account_balance_rounded,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required String label,
    required String method,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context, method),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.2)),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.info;
      case 'washing':
        return AppColors.primary;
      case 'ready':
        return Colors.orangeAccent;
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textTertiary;
    }
  }
}
