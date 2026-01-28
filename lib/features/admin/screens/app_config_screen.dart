import 'package:flutter/material.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class AppConfigScreen extends StatefulWidget {
  const AppConfigScreen({super.key});

  @override
  State<AppConfigScreen> createState() => _AppConfigScreenState();
}

class _AppConfigScreenState extends State<AppConfigScreen> {
  bool _maintenanceMode = false;
  bool _bookingsOpen = true;
  String _supportPhone = '+251911234567';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Configuration')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p20),
        children: [
          _buildSectionHeader('SYSTEM STATUS'),
          const SizedBox(height: 12),
          _buildToggleTile(
            'Maintenance Mode',
            'Take the app offline for maintenance',
            Icons.construction,
            _maintenanceMode,
            (val) => setState(() => _maintenanceMode = val),
          ),
          const SizedBox(height: 12),
          _buildToggleTile(
            'Accepting Bookings',
            'Global toggle for taking new wash requests',
            Icons.calendar_today,
            _bookingsOpen,
            (val) => setState(() => _bookingsOpen = val),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('SUPPORT & CONTACT'),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone, color: AppColors.primary),
              title: const Text('Support Contact Number'),
              subtitle: Text(_supportPhone),
              trailing: const Icon(Icons.edit, size: 16),
              onTap: () {
                // Show edit dialog
              },
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('MARKETING'),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.campaign, color: Colors.orange),
              title: const Text('Dashboard Banner Message'),
              subtitle: const Text('Welcome to Dr. Shine! Book your wash now.'),
              trailing: const Icon(Icons.edit, size: 16),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuration saved successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: AppColors.primary,
            ),
            child: const Text('SAVE CHANGES'),
          ),
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

  Widget _buildToggleTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white38)),
        secondary: Icon(icon, color: AppColors.primary),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
