import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/status/providers/status_provider.dart';
import 'package:dr_shine_app/features/booking/providers/booking_provider.dart';
import 'package:dr_shine_app/features/inventory/providers/inventory_provider.dart';
import 'package:dr_shine_app/features/inventory/models/inventory_item_model.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/app/app_routes.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statusProvider = context.watch<StatusProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff Command Center'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Duty Status Hub
            _buildDutyHub(statusProvider),
            const SizedBox(height: AppSizes.p24),

            // Primary Command CTAs
            _buildActionGrid(context),
            const SizedBox(height: AppSizes.p24),

            // Operational Alerts
            _buildOperationalAlerts(inventoryProvider),
            const SizedBox(height: AppSizes.p32),

            // Live Wash Tracker Section
            _buildLiveWashTracker(bookingProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildDutyHub(StatusProvider provider) {
    final isBusy = provider.currentStatus == BusyStatus.busy;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: (isBusy ? Colors.redAccent : AppColors.success)
                .withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isBusy ? Colors.redAccent : AppColors.success)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBusy
                  ? Icons.notifications_paused_rounded
                  : Icons.sensors_rounded,
              color: isBusy ? Colors.redAccent : AppColors.success,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STATION STATUS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                Text(
                  isBusy ? 'BUSY / NO ADMISSIONS' : 'ON-DUTY / READY',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: !isBusy,
            activeColor: AppColors.success,
            onChanged: (val) => provider
                .updateStatus(val ? BusyStatus.notBusy : BusyStatus.busy),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            label: 'Quick Entry',
            icon: Icons.add_rounded,
            color: AppColors.primary,
            onTap: () => Navigator.pushNamed(context, AppRoutes.quickEntry),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            context,
            label: 'Wash Reports',
            icon: Icons.analytics_rounded,
            color: AppColors.success,
            onTap: () => Navigator.pushNamed(context, AppRoutes.washReports),
          ),
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
            const SizedBox(height: 16),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white),
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

  Widget _buildLiveWashTracker(BookingProvider provider) {
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
                  color: Colors.white38),
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
        StreamBuilder<List<BookingModel>>(
          stream: provider.getTodayBookings(),
          builder: (context, snapshot) {
            final washes = snapshot.data ?? [];
            if (washes.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text('Standing by for new jobs...',
                      style: TextStyle(color: Colors.white24)),
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
                return _buildWashCard(context, wash, provider);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildWashCard(
      BuildContext context, BookingModel wash, BookingProvider provider) {
    final service = defaultServices.firstWhere((s) => s.id == wash.serviceId,
        orElse: () => defaultServices.first);
    final statusColor = _getStatusColor(wash.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
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
                        color: Colors.white38),
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
                        '${service.name} • Assigned: ${wash.washerStaffName ?? "General"}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(wash.status, statusColor),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.03)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildWashActions(context, wash, provider),
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
    switch (wash.status) {
      case 'pending':
        return _buildLargeActionButton(
          label: 'ACCEPT JOB',
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
          onPressed: () => provider.updateBookingStatus(wash.id, 'accepted'),
        );
      case 'accepted':
        return _buildLargeActionButton(
          label: 'START WASHING',
          icon: Icons.play_arrow_rounded,
          color: AppColors.primary,
          onPressed: () => provider.updateBookingStatus(wash.id, 'washing'),
        );
      case 'washing':
        return _buildLargeActionButton(
          label: 'MARK AS READY',
          icon: Icons.done_all_rounded,
          color: AppColors.info,
          onPressed: () => provider.updateBookingStatus(wash.id, 'ready'),
        );
      case 'ready':
        return _buildLargeActionButton(
          label: 'FINALIZE & RELEASE',
          icon: Icons.flag_rounded,
          color: AppColors.success,
          onPressed: () => provider.completeWash(wash),
        );
      default:
        return const SizedBox(height: 8);
    }
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
        return Colors.white24;
    }
  }
}
