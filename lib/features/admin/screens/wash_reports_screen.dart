import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/features/booking/providers/booking_provider.dart';
import 'package:dr_shine_app/features/admin/providers/service_provider.dart';
import 'package:dr_shine_app/features/admin/providers/package_provider.dart'; // Added Import
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/features/admin/models/package_model.dart'; // Added Import
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:intl/intl.dart';

import 'package:dr_shine_app/core/widgets/responsive_layout.dart';

class WashReportsScreen extends StatefulWidget {
  const WashReportsScreen({super.key});

  @override
  State<WashReportsScreen> createState() => _WashReportsScreenState();
}

class _WashReportsScreenState extends State<WashReportsScreen> {
  String _selectedPeriod = 'today';

  DateTime get _startDate {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'today':
        return DateTime(now.year, now.month, now.day);
      case 'week':
        return now.subtract(Duration(days: now.weekday - 1));
      case 'month':
        return DateTime(now.year, now.month, 1);
      default:
        return DateTime(now.year, now.month, now.day);
    }
  }

  DateTime get _endDate {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'today':
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case 'week':
        return now;
      case 'month':
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      default:
        return now;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final packageProvider =
        context.watch<PackageProvider>(); // Added PackageProvider

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wash Analytics Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report export started...')),
              );
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        child: StreamBuilder<List<BookingModel>>(
          stream: bookingProvider.getBookingsByDateRange(_startDate, _endDate),
          builder: (context, snapshot) {
            final washes = snapshot.data ?? [];

            return Column(
              children: [
                // Period Selector Bar
                _buildPeriodSelectorBar(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Overview Metric Row
                        _buildEnhancedOverview(washes),
                        const SizedBox(height: AppSizes.p20),

                        // Service Distribution (Visual Chart)
                        _buildServiceMetrics(
                            washes, serviceProvider, packageProvider),
                        const SizedBox(height: AppSizes.p20),

                        // Staff Performance Table
                        _buildStaffPerformanceRow(washes),
                        const SizedBox(height: AppSizes.p20),

                        // Detailed History Section
                        _buildActivityLog(
                            washes, serviceProvider, packageProvider),
                        const SizedBox(height: AppSizes.p32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPeriodSelectorBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          _buildPeriodButton('Today', 'today'),
          const SizedBox(width: 8),
          _buildPeriodButton('Week', 'week'),
          const SizedBox(width: 8),
          _buildPeriodButton('Month', 'month'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedOverview(List<BookingModel> washes) {
    // Only count completed/ready washes for revenue and performance metrics
    final completedWashes = washes
        .where((w) => w.status == 'completed' || w.status == 'ready')
        .toList();

    final totalRevenue =
        completedWashes.fold<double>(0, (sum, w) => sum + w.price);
    final totalCars = completedWashes.length;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: 'Total Revenue',
            value: '${totalRevenue.toStringAsFixed(0)} ETB',
            icon: Icons.payments_rounded,
            color: Colors.green,
            subtitle: 'Realized Income',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            label: 'Cars Washed',
            value: totalCars.toString(),
            icon: Icons.directions_car_rounded,
            color: Colors.blue,
            subtitle: 'Completed Jobs',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceMetrics(List<BookingModel> washes,
      ServiceProvider provider, PackageProvider packageProvider) {
    // Only count completed/ready washes for distribution
    final completedWashes = washes
        .where((w) => w.status == 'completed' || w.status == 'ready')
        .toList();

    final Map<String, int> serviceData = {};
    for (var w in completedWashes) {
      final id = w.serviceId ?? w.packageId ?? 'unknown';
      serviceData[id] = (serviceData[id] ?? 0) + 1;
    }

    final total = completedWashes.length;

    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SERVICE DISTRIBUTION (COMPLETED)',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.white38),
          ),
          const SizedBox(height: 16),
          if (total == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                  child: Text('No completed services yet',
                      style: TextStyle(color: Colors.white24, fontSize: 12))),
            )
          else
            ...serviceData.entries.map((entry) {
              String name = 'Unknown';

              // Try to find service first
              try {
                final service =
                    provider.services.firstWhere((s) => s.id == entry.key);
                name = service.name;
              } catch (_) {
                // If not service, try package
                try {
                  final pkg = packageProvider.packages
                      .firstWhere((p) => p.id == entry.key);
                  name = pkg.name;
                } catch (_) {}
              }
              final percent = total > 0 ? entry.value / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                        Text(
                            '${entry.value} (${(percent * 100).toStringAsFixed(0)}%)',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent.toDouble(),
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStaffPerformanceRow(List<BookingModel> washes) {
    // Only count completed/ready washes for staff stats
    final completedWashes = washes
        .where((w) => w.status == 'completed' || w.status == 'ready')
        .toList();

    final Map<String, _StaffStats> staffMap = {};
    for (var w in completedWashes) {
      if (w.washerStaffId != null) {
        final stats = staffMap[w.washerStaffId!] ??
            _StaffStats(name: w.washerStaffName ?? 'Unknown');
        stats.washCount++;
        stats.revenue += w.price;
        staffMap[w.washerStaffId!] = stats;
      }
    }

    final sortedStaff = staffMap.values.toList()
      ..sort((a, b) => b.washCount.compareTo(a.washCount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WASHER PERFORMANCE',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: Colors.white38),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: sortedStaff.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                      child: Text('No performance data available',
                          style:
                              TextStyle(color: Colors.white24, fontSize: 12))),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedStaff.length,
                  separatorBuilder: (_, __) => Divider(
                      height: 1, color: Colors.white.withValues(alpha: 0.03)),
                  itemBuilder: (context, index) {
                    final staff = sortedStaff[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary),
                        ),
                      ),
                      title: Text(staff.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          '${staff.revenue.toStringAsFixed(0)} ETB generated',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${staff.washCount} Cars',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildActivityLog(List<BookingModel> washes, ServiceProvider provider,
      PackageProvider packageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DETAILED ACTIVITY LOG',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: Colors.white38),
        ),
        const SizedBox(height: 12),
        if (washes.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: const Text('No activity found for this period',
                style: TextStyle(color: Colors.white24)),
          )
        else
          ...washes.map((wash) {
            final serviceId = wash.serviceId;
            final packageId = wash.packageId;
            String itemName = 'Unknown';

            if (serviceId != null) {
              final service = provider.services.firstWhere(
                  (s) => s.id == serviceId,
                  orElse: () => ServiceModel(
                      id: 'unknown',
                      name: 'Unknown Service',
                      price: 0,
                      description: ''));
              itemName = service.name;
            } else if (packageId != null) {
              final pkg = packageProvider.packages.firstWhere(
                  (p) => p.id == packageId,
                  orElse: () => PackageModel(
                      id: 'unknown',
                      name: 'Unknown Package',
                      description: '',
                      price: 0,
                      includedServiceIds: []));
              itemName = pkg.name;
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      wash.plateNumber
                              ?.split('-')
                              .last
                              .characters
                              .take(3)
                              .toString() ??
                          'WSH',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white38),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${wash.plateNumber ?? "N/A"} • ${wash.carBrand ?? "Unknown"}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '$itemName • By ${wash.washerStaffName ?? "Staff"}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white24),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${wash.price.toStringAsFixed(0)} ETB',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.success),
                      ),
                      Text(
                        DateFormat('h:mm a').format(wash.createdAt),
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white24),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _StaffStats {
  final String name;
  int washCount = 0;
  double revenue = 0;
  _StaffStats({required this.name});
}
