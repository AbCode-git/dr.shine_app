import 'package:flutter/material.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/core/utils/formatters.dart';

class BookingDetailsScreen extends StatelessWidget {
  final BookingModel booking;
  final String serviceName;
  final String vehicleInfo;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
    required this.serviceName,
    required this.vehicleInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Header
            Hero(
              tag: 'booking_${booking.id}',
              child: Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    booking.status == 'completed' ? Icons.check_circle_outline : Icons.local_car_wash,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        serviceName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      _buildStatusBadge(booking.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    vehicleInfo,
                    style: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 48),
                  
                  _buildDetailRow(Icons.calendar_today, 'Date', AppFormatters.formatDate(booking.bookingDate)),
                  const SizedBox(height: 24),
                  _buildDetailRow(Icons.payments, 'Price', AppFormatters.formatCurrency(booking.price)),
                  const SizedBox(height: 24),
                  _buildDetailRow(Icons.info_outline, 'Booking ID', booking.id),
                  
                  if (booking.status == 'completed') ...[
                    const SizedBox(height: 48),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.star_outline),
                        label: const Text('Rate this Service'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'accepted':
        color = AppColors.info;
        break;
      case 'completed':
        color = AppColors.success;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      default:
        color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }
}
