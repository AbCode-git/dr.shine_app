import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/booking/providers/booking_provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/shared/widgets/booking_card.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/features/vehicle/providers/vehicle_provider.dart';
import 'package:dr_shine_app/core/widgets/shimmer_loading.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  @override
  void initState() {
    super.initState();
    // In a real app, we'd fetch bookings for the specific user here.
    // For MVP, we'll rely on the provider having the data or simple mock.
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final vehicleProvider = context.watch<VehicleProvider>();
    
    // Filter bookings for current user (simulated logic for MVP)
    final authProvider = context.read<AuthProvider>();
    final userBookings = bookingProvider.bookings.where((b) => b.userId == authProvider.currentUser?.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookingProvider.isLoading
          ? ListView.separated(
              padding: const EdgeInsets.all(AppSizes.p16),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => const ShimmerLoading(
                width: double.infinity,
                height: 100,
                borderRadius: 12,
              ),
            )
          : userBookings.isEmpty
              ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.p16),
              itemCount: userBookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = userBookings[index];
                final service = defaultServices.firstWhere((s) => s.id == booking.serviceId, 
                  orElse: () => defaultServices.first);
                final vehicle = vehicleProvider.vehicles.firstWhere((v) => v.id == booking.vehicleId, 
                  orElse: () => throw Exception('Vehicle not found'));
                
                return BookingCard(
                  booking: booking,
                  serviceName: service.name,
                  vehicleInfo: '${vehicle.nickname ?? vehicle.type} (${vehicle.plateNumber})',
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_note_outlined, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text('No booking history', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
