import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: AppSizes.p32),
            _buildInfoSection(
              title: 'Account Information',
              items: [
                _buildInfoTile(Icons.phone_iphone, 'Phone Number', user?.phoneNumber ?? 'N/A'),
                _buildInfoTile(Icons.verified_user, 'Role', user?.role.toUpperCase() ?? 'CUSTOMER'),
                _buildInfoTile(Icons.calendar_today, 'Member Since', 'Jan 2026'),
              ],
            ),
            const SizedBox(height: AppSizes.p24),
            _buildInfoSection(
              title: 'Security',
              items: [
                ListTile(
                  leading: const Icon(Icons.pin, color: AppColors.primary),
                  title: const Text('Update Security PIN'),
                  trailing: const Icon(Icons.chevron_right, size: 16),
                  onTap: () => Navigator.pushNamed(context, '/pin-setup'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p40),
            _buildLogoutButton(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.person, size: 50, color: AppColors.primary),
        ),
        const SizedBox(height: AppSizes.p16),
        Text(
          user?.displayName ?? 'Valued Customer',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        if (user?.role == 'customer') ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${user?.loyaltyPoints ?? 0} Loyalty Points',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Card(
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      trailing: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return OutlinedButton.icon(
      onPressed: () {
        auth.logout();
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      },
      icon: const Icon(Icons.logout, size: 18),
      label: const Text('Log Out'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.redAccent,
        side: const BorderSide(color: Colors.redAccent),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r12)),
      ),
    );
  }
}
