import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // Dr. Shine Location (Addis Ababa - Sample coordinates)
  static const LatLng _center = LatLng(9.0192, 38.7525);
  
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('dr_shine'),
      position: _center,
      infoWindow: InfoWindow(
        title: 'Dr. Shine Car Wash',
        snippet: 'Addis Ababa, Ethiopia',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact & Location')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: _center,
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                ),
                // Overlay for Web development notice
                if (identical(0, 0.0)) // Local check for Web
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Note: Real Google Maps require a valid API key in index.html',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.r24),
          topRight: Radius.circular(AppSizes.r24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Dr. Shine Car Wash',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bole Road, Near Friendship Mall\nAddis Ababa, Ethiopia',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  icon: Icons.phone,
                  label: 'Call',
                  color: AppColors.primary,
                  onTap: () {
                    // Implement call logic (url_launcher)
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildContactButton(
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  color: AppColors.success,
                  onTap: () {
                    // Implement WhatsApp logic (url_launcher)
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
