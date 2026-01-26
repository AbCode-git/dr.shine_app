import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/app/app_routes.dart';
import 'package:dr_shine_app/features/booking/providers/booking_provider.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Management'),
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
            _buildOverviewCards(),
            const SizedBox(height: AppSizes.p24),
            _buildManagementSection(
              context,
              title: 'Staff Management',
              icon: Icons.people_alt,
              items: [
                'Manage Staff Accounts',
                'Duty Roster',
                'Performance Analytics',
              ],
            ),
            const SizedBox(height: AppSizes.p20),
            _buildManagementSection(
              context,
              title: 'Platform Settings',
              icon: Icons.settings_applications,
              items: [
                'Update Service Pricing',
                'Manage Wash Services',
                'Inventory Management',
                'App Configurations',
              ],
            ),
            const SizedBox(height: AppSizes.p20),
            _buildManagementSection(
              context,
              title: 'Customer Insights',
              icon: Icons.analytics,
              items: [
                'Customer Directory',
                'Loyalty Program Stats',
                'Feedback & Reviews',
              ],
            ),
            const SizedBox(height: AppSizes.p32),
            _buildDailyReport(context),
            const SizedBox(height: AppSizes.p40),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyReport(BuildContext context) {
    final bookingProvider = context.read<BookingProvider>();
    
    return StreamBuilder<List<BookingModel>>(
      stream: bookingProvider.getTodayBookings(),
      builder: (context, snapshot) {
        final bookings = snapshot.data ?? [];
        final completedBookings = bookings.where((b) => b.status == 'completed').toList();
        
        final totalJobs = completedBookings.length;
        final totalRevenue = completedBookings.fold<double>(0, (sum, b) => sum + b.price);
        final avgPrice = totalJobs > 0 ? totalRevenue / totalJobs : 0;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DAILY JOB REPORT',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.r24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMiniStat('Jobs', totalJobs.toString(), Icons.local_car_wash, Colors.blue),
                      _buildMiniStat('Revenue', '${totalRevenue.toStringAsFixed(0)} ETB', Icons.payments, Colors.green),
                      _buildMiniStat('Avg.', '${avgPrice.toStringAsFixed(0)} ETB', Icons.leaderboard, Colors.orange),
                    ],
                  ),
                  if (completedBookings.isNotEmpty) ...[
                    const Divider(height: 40, color: Colors.white10),
                    const Text(
                      'COMPLETED TODAY',
                      style: TextStyle(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...completedBookings.take(5).map((booking) {
                      final service = defaultServices.firstWhere(
                        (s) => s.id == booking.serviceId,
                        orElse: () => defaultServices.first,
                      );
                      return _buildReportRow(
                        service.name,
                        '${booking.price.toStringAsFixed(0)} ETB',
                        '${booking.createdAt.hour}:${booking.createdAt.minute.toString().padLeft(2, '0')}',
                      );
                    }),
                  ] else ...[
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'No completed jobs today',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
      ],
    );
  }

  Widget _buildReportRow(String service, String price, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(service, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Text(price, style: const TextStyle(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Text(time, style: const TextStyle(fontSize: 11, color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Total Sales', '12.5k ETB', Icons.payments, Colors.green),
        ),
        const SizedBox(width: AppSizes.p12),
        Expanded(
          child: _buildStatCard('Active Jobs', '8', Icons.local_car_wash, AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection(BuildContext context,
      {required String title, required IconData icon, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: items.map((itemValue) => ListTile(
              title: Text(itemValue),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () {
                if (itemValue == 'Manage Staff Accounts') {
                  Navigator.pushNamed(context, AppRoutes.staffManagement);
                } else if (itemValue == 'Customer Directory') {
                  Navigator.pushNamed(context, AppRoutes.customerDirectory);
                } else if (itemValue == 'Update Service Pricing') {
                  Navigator.pushNamed(context, AppRoutes.servicePricing);
                } else if (itemValue == 'Inventory Management') {
                  Navigator.pushNamed(context, AppRoutes.inventory);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$itemValue details coming soon!')),
                  );
                }
              },
            )).toList(),
          ),
        ),
      ],
    );
  }
}
