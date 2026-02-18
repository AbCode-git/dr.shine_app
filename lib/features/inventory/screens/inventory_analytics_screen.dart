import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/inventory/providers/inventory_provider.dart';
import 'package:dr_shine_app/features/inventory/models/inventory_item_model.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/core/widgets/responsive_layout.dart';

class InventoryAnalyticsScreen extends StatelessWidget {
  const InventoryAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();
    final items = inventoryProvider.items;

    // Calculate real stats
    double totalValue = 0;
    for (var item in items) {
      totalValue += item.currentStock * item.costPerUnit;
    }

    final lowStockItems = items.where((i) => i.isLowStock).toList();
    final needsReorderItems = items.where((i) => i.needsReorder).toList();

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
              _buildSummaryRow(totalValue, items.length),
              const SizedBox(height: AppSizes.p24),
              _buildAlertBox(
                'REORDER SUGGESTIONS',
                needsReorderItems.isEmpty
                    ? 'All items are above reorder levels.'
                    : '${needsReorderItems.length} items are below reorder level. Click to manage.',
                Icons.history_edu,
                isWarning: needsReorderItems.isNotEmpty,
              ),
              if (lowStockItems.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildAlertBox(
                  'CRITICAL LOW STOCK',
                  '${lowStockItems.length} items are critically low or empty!',
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  isWarning: true,
                ),
              ],
              const SizedBox(height: AppSizes.p24),
              _buildCostAnalysis(items),
              const SizedBox(height: AppSizes.p24),
              _buildUsageTrends(items),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(double totalValue, int totalItems) {
    return Row(
      children: [
        Expanded(
          child: _buildValueCard(
            'Total Value',
            totalValue > 1000
                ? '${(totalValue / 1000).toStringAsFixed(1)}k'
                : totalValue.toStringAsFixed(0),
            'ETB',
            Icons.account_balance_wallet,
            Colors.greenAccent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildValueCard(
            'Supplies',
            totalItems.toString(),
            'Items',
            Icons.inventory_2,
            AppColors.primary,
          ),
        ),
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

  Widget _buildUsageTrends(List<InventoryItem> items) {
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
          _buildSubtitle('CURRENT STOCK LEVELS'),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text('No data to display',
                style: TextStyle(color: Colors.white24))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.take(10).map((item) {
                final progress = (item.currentStock / 100).clamp(0.0, 1.0);
                return Column(
                  children: [
                    Container(
                      width: 8,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 50 * progress,
                        decoration: BoxDecoration(
                          color: _getStockColor(item),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(item.name.substring(0, 1),
                        style: const TextStyle(fontSize: 8)),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Color _getStockColor(InventoryItem item) {
    if (item.isLowStock) return Colors.redAccent;
    if (item.needsReorder) return Colors.orangeAccent;
    return Colors.greenAccent;
  }

  Widget _buildCostAnalysis(List<InventoryItem> items) {
    final sortedItems = List<InventoryItem>.from(items)
      ..sort((a, b) => b.costPerUnit.compareTo(a.costPerUnit));

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
          _buildSubtitle('TOP EXPENSIVE ITEMS'),
          const SizedBox(height: 16),
          if (sortedItems.isEmpty)
            const Text('No items found',
                style: TextStyle(color: Colors.white24))
          else
            ...sortedItems.take(5).map((item) => _buildCostRow(
                item.name, '${item.costPerUnit.toStringAsFixed(0)} ETB')),
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

  Widget _buildAlertBox(String title, String msg, IconData icon,
      {bool isWarning = false, Color? color}) {
    final themeColor = color ?? (isWarning ? Colors.orangeAccent : Colors.blue);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.r24),
        border: Border.all(color: themeColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: themeColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: themeColor,
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
