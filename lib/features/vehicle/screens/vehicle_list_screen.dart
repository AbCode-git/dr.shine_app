import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/vehicle/providers/vehicle_provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/shared/widgets/vehicle_card.dart';
import 'package:dr_shine_app/features/vehicle/screens/add_vehicle_screen.dart';
import 'package:dr_shine_app/core/widgets/shimmer_loading.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      context.read<VehicleProvider>().fetchVehicles(authProvider.currentUser!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Vehicles')),
      body: vehicleProvider.isLoading
          ? ListView.separated(
              padding: const EdgeInsets.all(AppSizes.p16),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => const ShimmerLoading(
                width: double.infinity,
                height: 80,
                borderRadius: 12,
              ),
            )
          : vehicleProvider.vehicles.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  itemCount: vehicleProvider.vehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return VehicleCard(vehicle: vehicleProvider.vehicles[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_car_filled_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text('No vehicles found', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
            ),
            child: const Text('Add your first vehicle'),
          ),
        ],
      ),
    );
  }
}
