import 'package:flutter/material.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/app/app_routes.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Executive Governance'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'PLATFORM OVERVIEW',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricsGrid(),
            const SizedBox(height: AppSizes.p32),
            _buildModuleHub(context),
            const SizedBox(height: AppSizes.p32),
            const Row(
              children: [
                Text(
                  'SYSTEM HEALTH',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white24),
                ),
                Spacer(),
                Icon(Icons.check_circle_rounded,
                    size: 12, color: AppColors.success),
                SizedBox(width: 4),
                Text('OPERATING NORMAL',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.success)),
              ],
            ),
            const SizedBox(height: 12),
            _buildDailyReportPreview(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildGlassMetric('Total Revenue', 'ETB 45.2K', Icons.payments_rounded,
            AppColors.success),
        _buildGlassMetric('Volume', '124 Cars', Icons.local_car_wash_rounded,
            AppColors.primary),
        _buildGlassMetric(
            'Efficiency', '94%', Icons.speed_rounded, Colors.orangeAccent),
        _buildGlassMetric(
            'Incidents', '0', Icons.gavel_rounded, AppColors.secondary),
      ],
    );
  }

  Widget _buildGlassMetric(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const Spacer(),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.white24,
                    letterSpacing: 1),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleHub(BuildContext context) {
    return Column(
      children: [
        _buildModuleSection(
          context,
          title: 'Staff & Operations',
          icon: Icons.groups_2_rounded,
          items: [
            {
              'label': 'Service Performance',
              'val': 'Wash Reports Dashboard',
              'icon': Icons.insights_rounded
            },
            {
              'label': 'Labor Registry',
              'val': 'Manage Staff',
              'icon': Icons.badge_rounded
            },
            {
              'label': 'Inventory Vault',
              'val': 'Inventory Management',
              'icon': Icons.storage_rounded
            },
          ],
        ),
        const SizedBox(height: 20),
        _buildModuleSection(
          context,
          title: 'System Settings',
          icon: Icons.terminal_rounded,
          items: [
            {
              'label': 'Rate Config',
              'val': 'Update Service Pricing',
              'icon': Icons.price_change_rounded
            },
            {
              'label': 'Security Matrix',
              'val': 'Edit Admin Settings',
              'icon': Icons.security_rounded
            },
          ],
        ),
      ],
    );
  }

  Widget _buildModuleSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 18),
                const SizedBox(width: 12),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white70),
                ),
              ],
            ),
          ),
          ...items.map((item) => _buildModuleItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildModuleItem(BuildContext context, Map<String, dynamic> item) {
    return ListTile(
      onTap: () => _handleHubNavigation(context, item['val']),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(item['icon'], color: Colors.white24, size: 20),
      title: Text(
        item['label'],
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: Colors.white10, size: 18),
    );
  }

  void _handleHubNavigation(BuildContext context, String itemValue) {
    if (itemValue == 'Manage Staff') {
      Navigator.pushNamed(context, AppRoutes.staffManagement);
    } else if (itemValue == 'Inventory Management') {
      Navigator.pushNamed(context, AppRoutes.inventory);
    } else if (itemValue == 'Wash Reports Dashboard') {
      Navigator.pushNamed(context, AppRoutes.washReports);
    } else if (itemValue == 'Update Service Pricing') {
      Navigator.pushNamed(context, AppRoutes.servicePricing);
    } else if (itemValue == 'Edit Admin Settings') {
      Navigator.pushNamed(context, AppRoutes.appConfig);
    }
  }

  Widget _buildDailyReportPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DAILY JOB REPORT',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  Text(
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} • AUTOMATED',
                      style:
                          const TextStyle(fontSize: 9, color: Colors.white24)),
                ],
              ),
              const Spacer(),
              _buildReportSparkLine(),
            ],
          ),
          const SizedBox(height: 24),
          _buildReportRow('Average Wash Time', '32 Min', AppColors.info),
          const SizedBox(height: 12),
          _buildReportRow('Peak Staff Utilization', '89%', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value, Color color) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.white70)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildReportSparkLine() {
    return Row(
      children: List.generate(
          5,
          (index) => Container(
                margin: const EdgeInsets.only(left: 3),
                width: 4,
                height: (index * 4 + 8).toDouble(),
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withValues(alpha: 0.3 + (index * 0.1)),
                  borderRadius: BorderRadius.circular(2),
                ),
              )),
    );
  }
}
