import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/providers/user_provider.dart';
import 'package:dr_shine_app/features/booking/providers/booking_provider.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class PerformanceAnalyticsScreen extends StatelessWidget {
  const PerformanceAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final staff = userProvider.staff;
    final allBookings = bookingProvider.bookings;

    return Scaffold(
      appBar: AppBar(title: const Text('Performance Analytics')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: staff.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final member = staff[index];
          // Mocking some data since we don't have staff assignment in BookingModel yet
          final completedJobs = (index * 3 + 5) % 15; 
          final rating = 4.5 + (index % 5) * 0.1;

          return InkWell(
            onTap: () => _showStaffDetails(context, member, completedJobs),
            borderRadius: BorderRadius.circular(AppSizes.r24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.r24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member.displayName ?? 'Staff', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Text('Lead detailer', style: TextStyle(color: Colors.white24, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 14),
                            const SizedBox(width: 4),
                            Text(rating.toStringAsFixed(1), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
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
                      _buildStat('Jobs', completedJobs.toString(), Icons.local_car_wash, Colors.blue),
                      _buildStat('Efficiency', '92%', Icons.speed, Colors.green),
                      _buildStat('Points', (completedJobs * 10).toString(), Icons.military_tech, Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showStaffDetails(BuildContext context, dynamic member, int jobCount) {
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
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Job History: ${member.displayName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Showing last $jobCount completed jobs',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: jobCount,
                separatorBuilder: (_, __) => const Divider(height: 32, color: Colors.white10),
                itemBuilder: (context, i) {
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Premium Wash #${1024 - i}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Text('Toyota Corolla (Plate: 2AA12345)', style: TextStyle(fontSize: 12, color: Colors.white38)),
                          ],
                        ),
                      ),
                      Text(
                        'Jan ${28 - (i % 5)}',
                        style: const TextStyle(fontSize: 12, color: Colors.white24),
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

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.5), size: 18),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white24, letterSpacing: 1)),
      ],
    );
  }
}
