import 'package:flutter/material.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/core/widgets/responsive_layout.dart';

class InventoryAnalyticsScreen extends StatelessWidget {
  const InventoryAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Analytics'),
      ),
      body: ResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummaryRow(),
              const SizedBox(height: AppSizes.p24),
              _buildChartSection(
                  'Usage Trends (Mock)', 'Weekly consumption of soap and oil.'),
              const SizedBox(height: AppSizes.p24),
              _buildCostAnalysis(),
              const SizedBox(height: AppSizes.p24),
              _buildAlertBox(
                  'REORDER SUGGESTIONS',
                  '3 items are below reorder level. Click to restock.',
                  Icons.history_edu),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
            child: _buildValueCard('Total Value', '42.5k', 'ETB',
                Icons.account_balance_wallet, Colors.greenAccent)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildValueCard('Utilization', '82%', 'Cap.',
                Icons.trending_up, AppColors.primary)),
      ],
    );
  }

  Widget _buildValueCard(
      String title, String val, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(val,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(unit,
                    style:
                        const TextStyle(fontSize: 10, color: Colors.white24)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubtitle(title),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.white24, fontSize: 11)),
          const SizedBox(height: 24),
          // Mock Chart Bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) => _buildBar(i * 15.0 + 30, i == 4)),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, bool isHighlighted) {
    return Container(
      width: 12,
      height: height,
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primary : Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildCostAnalysis() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubtitle('COST PER SERVICE (AVG)'),
          const SizedBox(height: 16),
          _buildCostRow('Full Car Wash', '85 ETB'),
          _buildCostRow('Oil Change (Standard)', '2,800 ETB'),
          _buildCostRow('Engine Wash', '45 ETB'),
        ],
      ),
    );
  }

  Widget _buildCostRow(String title, String cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 13, color: Colors.white70)),
          Text(cost,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent)),
        ],
      ),
    );
  }

  Widget _buildAlertBox(String title, String msg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.orangeAccent,
                        letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(msg,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.white38));
  }
}
