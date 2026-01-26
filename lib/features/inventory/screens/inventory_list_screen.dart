import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/inventory/providers/inventory_provider.dart';
import 'package:dr_shine_app/features/inventory/models/inventory_item_model.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/app/app_routes.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.inventoryAnalytics),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Washes'),
            Tab(text: 'Oil'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.inventoryForm),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<InventoryItem>>(
        stream: inventoryProvider.getInventoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No inventory items found.'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildInventoryList(items),
              _buildInventoryList(items.where((i) => i.category == InventoryCategory.carWash).toList()),
              _buildInventoryList(items.where((i) => i.category == InventoryCategory.oilChange).toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInventoryList(List<InventoryItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.p16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final statusColor = item.currentStock <= item.minStockLevel 
            ? Colors.redAccent 
            : item.currentStock <= item.reorderLevel 
                ? Colors.orangeAccent 
                : Colors.greenAccent;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: _buildStockIndicator(item, statusColor),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${item.category.name.toUpperCase()} • ${item.unit}', style: const TextStyle(fontSize: 12, color: Colors.white38)),
                if (item.viscosityGrade != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item.viscosityGrade!, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${item.currentStock.toStringAsFixed(1)} ${item.unit}', style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
                const Text('Instock', style: TextStyle(fontSize: 10, color: Colors.white24)),
              ],
            ),
            onTap: () => Navigator.pushNamed(context, AppRoutes.inventoryForm, arguments: item),
          ),
        );
      },
    );
  }

  Widget _buildStockIndicator(InventoryItem item, Color color) {
    final progress = (item.currentStock / 100.0).clamp(0.0, 1.0); // Simplified scale for demo
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 3,
          ),
          Icon(item.category == InventoryCategory.oilChange ? Icons.oil_barrel : Icons.science, size: 16, color: color),
        ],
      ),
    );
  }
}
