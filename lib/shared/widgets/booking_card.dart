import 'package:flutter/material.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/core/utils/formatters.dart';
import 'package:dr_shine_app/app/app_routes.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final String serviceName;
  final String vehicleInfo;

  const BookingCard({
    super.key,
    required this.booking,
    required this.serviceName,
    required this.vehicleInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'booking_${booking.id}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.bookingDetails,
              arguments: {
                'booking': booking,
                'serviceName': serviceName,
                'vehicleInfo': vehicleInfo,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      serviceName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    _buildStatusBadge(booking.status),
                  ],
                ),
                const SizedBox(height: AppSizes.p8),
                Text(vehicleInfo, style: const TextStyle(color: AppColors.textSecondary)),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppFormatters.formatDate(booking.bookingDate),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      AppFormatters.formatCurrency(booking.price),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
