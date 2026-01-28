import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/status/providers/status_provider.dart';
import 'package:dr_shine_app/features/booking/providers/booking_provider.dart';
import 'package:dr_shine_app/features/vehicle/providers/vehicle_provider.dart';
import 'package:dr_shine_app/features/vehicle/models/vehicle_model.dart';
import 'package:dr_shine_app/features/inventory/providers/inventory_provider.dart';
import 'package:dr_shine_app/features/inventory/models/inventory_item_model.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/features/admin/widgets/status_toggle.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statusProvider = context.watch<StatusProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Update Busy Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p12),
            _buildStatusToggle(statusProvider),
            const SizedBox(height: AppSizes.p24),
            _buildSuppliesCheck(inventoryProvider),
            const SizedBox(height: AppSizes.p24),
            const Text('Today\'s Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p12),
            StreamBuilder(
              stream: bookingProvider.getTodayBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final bookings = snapshot.data ?? [];
                if (bookings.isEmpty) {
                  return const Card(child: Padding(padding: EdgeInsets.all(AppSizes.p20), child: Text('No bookings for today.')));
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final service = defaultServices.firstWhere(
                      (s) => s.id == booking.serviceId,
                      orElse: () => defaultServices.first,
                    );
                    
                    return FutureBuilder<VehicleModel?>(
                      future: context.read<VehicleProvider>().getVehicleById(booking.vehicleId),
                      builder: (context, vehicleSnapshot) {
                        final vehicle = vehicleSnapshot.data;
                        final vehicleInfo = vehicle != null 
                            ? '${vehicle.type} - ${vehicle.color ?? ""} (${vehicle.plateNumber})'
                            : 'Loading vehicle...';

                        return ListTile(
                          tileColor: AppColors.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r12)),
                          title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(vehicleInfo, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('Status: ${booking.status.toUpperCase()}', style: TextStyle(fontSize: 12, color: _getStatusColor(booking.status))),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (booking.status == 'pending')
                                IconButton(
                                  tooltip: 'Accept Booking',
                                  icon: const Icon(Icons.check, color: AppColors.success),
                                  onPressed: () => bookingProvider.updateBookingStatus(booking.id, 'accepted'),
                                ),
                              if (booking.status == 'accepted')
                                IconButton(
                                  tooltip: 'Start Washing',
                                  icon: const Icon(Icons.play_circle_fill, color: AppColors.primary),
                                  onPressed: () => bookingProvider.updateBookingStatus(booking.id, 'washing'),
                                ),
                              if (booking.status == 'washing')
                                IconButton(
                                  tooltip: 'Mark as Ready',
                                  icon: const Icon(Icons.done_all, color: AppColors.info),
                                  onPressed: () => bookingProvider.updateBookingStatus(booking.id, 'ready'),
                                ),
                              if (booking.status == 'ready')
                                IconButton(
                                  tooltip: 'Finalize / Picked Up',
                                  icon: const Icon(Icons.flag_circle, color: AppColors.success),
                                  onPressed: () {
                                    bookingProvider.completeWash(booking);
                                    inventoryProvider.deductStock(service.inventoryRequirements);
                                  },
                                ),
                              if (booking.status == 'completed')
                                const Icon(Icons.verified, color: AppColors.success, size: 24),
                            ],
                          ),
                        );
                      }
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusToggle(StatusProvider provider) {
    return StatusToggle(
      currentStatus: provider.currentStatus,
      onStatusChanged: (status) => provider.updateStatus(status),
    );
  }

  Widget _buildSuppliesCheck(InventoryProvider provider) {
    return StreamBuilder<List<InventoryItem>>(
      stream: provider.getInventoryStream(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final lowStockItems = items.where((i) => i.isLowStock).toList();

        return InkWell(
          onTap: () => Navigator.pushNamed(context, '/inventory'),
          borderRadius: BorderRadius.circular(AppSizes.r12),
          child: Container(
            padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: lowStockItems.isNotEmpty ? Colors.redAccent.withOpacity(0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.r12),
            border: Border.all(color: lowStockItems.isNotEmpty ? Colors.redAccent.withOpacity(0.3) : Colors.white10),
          ),
          child: Row(
            children: [
              Icon(
                lowStockItems.isNotEmpty ? Icons.warning_rounded : Icons.inventory_2_outlined,
                color: lowStockItems.isNotEmpty ? Colors.redAccent : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lowStockItems.isNotEmpty ? 'LOW SUPPLIES ALERT' : 'SUPPLIES STATUS',
                      style: TextStyle(
                        fontSize: 11, 
                        fontWeight: FontWeight.bold, 
                        color: lowStockItems.isNotEmpty ? Colors.redAccent : Colors.white38,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lowStockItems.isNotEmpty 
                          ? '${lowStockItems.length} items are critically low!' 
                          : 'All essential supplies are stocked.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted': return AppColors.info;
      case 'washing': return AppColors.primary;
      case 'ready': return Colors.orangeAccent;
      case 'completed': return AppColors.success;
      case 'pending': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }
}
