import 'package:flutter/material.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class LoyaltyAnalyticsScreen extends StatelessWidget {
  const LoyaltyAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loyalty Program Stats')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatGrid(),
            const SizedBox(height: 32),
            _buildSectionHeader('TOP LOYAL CUSTOMERS'),
            const SizedBox(height: 16),
            _buildLoyaltyLeaderboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('Total Points', '12,450', Icons.stars, Colors.orange),
        _buildMetricCard('Redeemed', '2,100', Icons.card_giftcard, Colors.green),
        _buildMetricCard('Active Users', '142', Icons.people, AppColors.primary),
        _buildMetricCard('Avg per User', '87', Icons.analytics, Colors.purple),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.r20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.white24, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: Colors.white24,
      ),
    );
  }

  Widget _buildLoyaltyLeaderboard() {
    final topCustomers = [
      {'name': 'Dawit Kassahun', 'points': 850},
      {'name': 'Sara Tesfaye', 'points': 720},
      {'name': 'Abebe Bikila', 'points': 640},
      {'name': 'Mina Lulseged', 'points': 590},
    ];

    return Column(
      children: topCustomers.map((customer) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                (topCustomers.indexOf(customer) + 1).toString(),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(customer['name'] as String),
            trailing: Text(
              '${customer['points']} Pts',
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }
}
