import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/providers/user_provider.dart';
import 'package:dr_shine_app/features/booking/providers/booking_provider.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/features/admin/providers/service_provider.dart';
import 'package:dr_shine_app/features/admin/providers/package_provider.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/features/admin/models/package_model.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/widgets/responsive_layout.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class PerformanceAnalyticsScreen extends StatelessWidget {
  const PerformanceAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final packageProvider = context.watch<PackageProvider>();

    final staff = userProvider.staff;
    final performance = bookingProvider.washerPerformanceToday;

    return Scaffold(
      appBar: AppBar(title: const Text('Performance Analytics')),
      body: ResponsiveLayout(
        child: staff.isEmpty
            ? const Center(
                child: Text('No staff found',
                    style: TextStyle(color: Colors.white24)))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSizes.p16),
                itemCount: staff.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final member = staff[index];
                  final completedJobs =
                      performance[member.displayName ?? 'Unassigned'] ?? 0;

                  // For real analytics we would need more data, for now we show real job count
                  final rating = 5.0; // Placeholder for future rating system

                  return InkWell(
                    onTap: () => _showStaffDetails(
                      context,
                      member,
                      bookingProvider.bookings,
                      serviceProvider,
                      packageProvider,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.r24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.r24),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(Icons.person,
                                    color: AppColors.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(member.displayName ?? 'Staff',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Text(member.role.toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white24,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.orange, size: 14),
                                    const SizedBox(width: 4),
                                    Text(rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStat('Jobs Today', completedJobs.toString(),
                                  Icons.local_car_wash, Colors.blue),
                              _buildStat('Efficiency', '100%', Icons.speed,
                                  Colors.green),
                              _buildStat(
                                  'Points',
                                  (completedJobs * 10).toString(),
                                  Icons.military_tech,
                                  Colors.purple),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showStaffDetails(
    BuildContext context,
    dynamic member,
    List<BookingModel> allBookings,
    ServiceProvider serviceProvider,
    PackageProvider packageProvider,
  ) {
    final name = member.displayName ?? 'Unassigned';
    final staffBookings = allBookings
        .where((b) =>
            b.washerStaffName == name &&
            (b.status == 'completed' || b.status == 'ready'))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Job History: $name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Showing ${staffBookings.length} completed jobs for today',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: staffBookings.isEmpty
                  ? const Center(
                      child: Text('No jobs completed yet today',
                          style: TextStyle(color: Colors.white24)))
                  : ListView.separated(
                      itemCount: staffBookings.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 32, color: Colors.white10),
                      itemBuilder: (context, i) {
                        final booking = staffBookings[i];

                        // Resolve Service/Package Name
                        String realServiceName = 'Unknown Service';
                        if (booking.serviceId != null) {
                          final s = serviceProvider.services.firstWhere(
                            (src) => src.id == booking.serviceId,
                            orElse: () => ServiceModel(
                                id: '',
                                name: 'Unknown Service',
                                description: '',
                                price: 0),
                          );
                          realServiceName = s.name;
                        } else if (booking.packageId != null) {
                          final p = packageProvider.packages.firstWhere(
                            (pkg) => pkg.id == booking.packageId,
                            orElse: () => PackageModel(
                                id: '',
                                name: 'Unknown Package',
                                description: '',
                                price: 0,
                                includedServiceIds: []),
                          );
                          realServiceName = p.name;
                        }

                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check,
                                  color: AppColors.primary, size: 16),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(realServiceName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      '${booking.carBrand} ${booking.carModel} (Plate: ${booking.plateNumber})',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white38)),
                                ],
                              ),
                            ),
                            Text(
                              _formatTime(booking.createdAt),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white24),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.5), size: 18),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: Colors.white24, letterSpacing: 1)),
      ],
    );
  }
}
